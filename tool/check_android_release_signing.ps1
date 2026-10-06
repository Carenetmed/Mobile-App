param([string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
$names = @('CARENET_UPLOAD_KEYSTORE_PATH', 'CARENET_UPLOAD_STORE_PASSWORD',
    'CARENET_UPLOAD_KEY_ALIAS', 'CARENET_UPLOAD_KEY_PASSWORD', 'CARENET_UPLOAD_CERT_SHA256')
$original = @{}
foreach ($name in $names) { $original[$name] = [Environment]::GetEnvironmentVariable($name) }
$temporary = Join-Path ([IO.Path]::GetTempPath()) ('carenet-signing-test-' + [Guid]::NewGuid())
[void][IO.Directory]::CreateDirectory($temporary)
$keytool = if ($env:JAVA_HOME) { Join-Path $env:JAVA_HOME 'bin/keytool' } else { 'keytool' }
if ($IsWindows -and $env:JAVA_HOME) { $keytool += '.exe' }

function Invoke-Gradle([string[]]$Arguments, [string]$Label) {
    $androidDirectory = Join-Path $RepositoryRoot 'android'
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = if ($IsWindows) { 'cmd.exe' } else { '/bin/bash' }
    $startInfo.WorkingDirectory = $androidDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    if ($IsWindows) {
        [void]$startInfo.ArgumentList.Add('/c')
        [void]$startInfo.ArgumentList.Add('.\gradlew.bat')
    } else {
        [void]$startInfo.ArgumentList.Add('./gradlew')
    }
    foreach ($argument in $Arguments) { [void]$startInfo.ArgumentList.Add($argument) }

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    Write-Host "Starting Gradle probe '$Label' (120-second limit)."
    try {
        if (-not $process.Start()) { throw "Could not start Gradle probe '$Label'." }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(120000)) {
            $process.Kill($true)
            $process.WaitForExit()
            throw "Gradle probe '$Label' exceeded its 120-second limit."
        }
        $process.WaitForExit()
        $output = @($stdout.GetAwaiter().GetResult(), $stderr.GetAwaiter().GetResult()) -join "`n"
        Write-Host "Finished Gradle probe '$Label' with exit code $($process.ExitCode)."
        return @{ Code = $process.ExitCode; Output = $output }
    } finally {
        $process.Dispose()
    }
}

function Assert-Gate([bool]$Success, [string]$Label) {
    $result = Invoke-Gradle @('validateReleaseSigning', '--console=plain', '--no-daemon') "signing gate: $Label"
    if (($result.Code -eq 0) -ne $Success) { throw "Release signing regression failed: $Label" }
    if (-not $Success -and $result.Output -notmatch 'Release signing is not configured|Protected release signing validation failed|upload keystore must exist outside') {
        throw "Signing probe did not reach the expected validator: $Label"
    }
    Write-Output "Signing probe passed: $Label"
}

try {
    foreach ($name in $names) { [Environment]::SetEnvironmentVariable($name, $null) }
    Assert-Gate $false 'missing credentials'
    $password = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
    $env:CARENET_UPLOAD_STORE_PASSWORD = $password
    $env:CARENET_UPLOAD_KEY_PASSWORD = $password
    $env:CARENET_UPLOAD_KEY_ALIAS = 'fixture'
    foreach ($kind in @('upload', 'debug')) {
        $store = Join-Path $temporary "$kind.p12"
        $subject = if ($kind -eq 'debug') { 'CN=Android Debug,O=Android,C=US' } else { 'CN=CareNet Disposable Signing Test' }
        $keyOutput = & $keytool -genkeypair -noprompt -storetype PKCS12 -keystore $store -alias fixture -keyalg RSA -keysize 2048 -validity 2 -dname $subject -storepass:env CARENET_UPLOAD_STORE_PASSWORD -keypass:env CARENET_UPLOAD_KEY_PASSWORD 2>&1
        if ($LASTEXITCODE -ne 0) { throw 'Disposable signing fixture generation failed.' }
        $certificate = Join-Path $temporary "$kind.cer"
        $keyOutput = & $keytool -exportcert -keystore $store -alias fixture -file $certificate -storepass:env CARENET_UPLOAD_STORE_PASSWORD 2>&1
        if ($LASTEXITCODE -ne 0) { throw 'Disposable signing certificate export failed.' }
        $env:CARENET_UPLOAD_KEYSTORE_PATH = $store
        $env:CARENET_UPLOAD_CERT_SHA256 = (Get-FileHash -LiteralPath $certificate -Algorithm SHA256).Hash
        Assert-Gate ($kind -eq 'upload') "$kind certificate"
        if ($kind -eq 'upload') {
            $approved = $env:CARENET_UPLOAD_CERT_SHA256
            $env:CARENET_UPLOAD_CERT_SHA256 = ('0' * 64)
            Assert-Gate $false 'fingerprint mismatch'
            $env:CARENET_UPLOAD_CERT_SHA256 = $approved
            $env:CARENET_UPLOAD_KEYSTORE_PATH = Join-Path $RepositoryRoot '.dart_tool/nonexistent-upload.p12'
            Assert-Gate $false 'repository keystore path'
        }
    }
    foreach ($name in $names) { [Environment]::SetEnvironmentVariable($name, $null) }
    foreach ($task in @('assembleStagingRelease', 'bundleStagingRelease', 'assembleProductionRelease', 'bundleProductionRelease')) {
        $result = Invoke-Gradle @($task, '--dry-run', '--console=plain', '--no-daemon') "release graph: $task"
        if ($result.Code -ne 0 -or $result.Output -notmatch ':app:validateReleaseSigning') {
            throw "Signing validation is absent from $task."
        }
    }
    $lint = Invoke-Gradle @('lintStagingRelease', '--dry-run', '--console=plain', '--no-daemon') 'lint graph: lintStagingRelease'
    if ($lint.Code -ne 0 -or $lint.Output -match ':app:validateReleaseSigning') {
        throw 'Release lint unexpectedly requires signing credentials.'
    }
    Write-Output 'Protected release signing checks passed; disposable fixtures only.'
} finally {
    foreach ($name in $names) { [Environment]::SetEnvironmentVariable($name, $original[$name]) }
    # Only the four known disposable files are removed, never a recursive target.
    foreach ($name in @('upload.p12', 'upload.cer', 'debug.p12', 'debug.cer')) {
        $file = Join-Path $temporary $name
        if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file -Force }
    }
    $password = $null
}
