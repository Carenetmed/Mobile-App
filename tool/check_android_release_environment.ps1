param([string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
$stagingApp = '1:599365440227:android:fb589a833cd2e8b251abd6'
$productionApp = '1:599365440227:android:7fbb7d5e3784327751abd6'
$valid = @{
    CARENET_ENVIRONMENT = 'staging'
    CARENET_API_BASE_URL = 'https://carenet-staging-mobile-gateway-7ncephib.uc.gateway.dev'
    CARENET_FIREBASE_PROJECT_ID = 'project-a96784ee-811c-46ab-a7b'
    CARENET_FIREBASE_APP_ID = $stagingApp
    CARENET_FIREBASE_MESSAGING_SENDER_ID = '599365440227'
    CARENET_FIREBASE_API_KEY = 'AIza' + ('x' * 35)
    GOOGLE_SIGN_IN_SERVER_CLIENT_ID = '599365440227-fixture.apps.googleusercontent.com'
}
$count = 0
function Invoke-Gradle([string[]]$Arguments) {
    Push-Location (Join-Path $RepositoryRoot 'android')
    try {
        $output = if ($IsWindows) { & .\gradlew.bat @Arguments 2>&1 } else { & bash ./gradlew @Arguments 2>&1 }
        return @{ Code = $LASTEXITCODE; Output = ($output -join "`n") }
    } finally { Pop-Location }
}
function Encode-Defines([hashtable]$Values) {
    return (($Values.Keys | Sort-Object | ForEach-Object {
        [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("$_=$($Values[$_])"))
    }) -join ',')
}
function Assert-Configuration([string]$Encoded, [bool]$Success, [string]$Label, [string]$Flavor = 'Staging') {
    $arguments = @("validate${Flavor}ReleaseEnvironment", '--console=plain', "-Pdart-defines=$Encoded")
    $result = Invoke-Gradle $arguments
    if (($result.Code -eq 0) -ne $Success) { throw "Release environment regression failed: $Label" }
    if (-not $Success -and $result.Output -notmatch 'Release runtime configuration|Release configuration|Release environment|Release Firebase|Release provider|Release API|Production API host|Staging API host|Production cannot') {
        throw "Configuration probe missed the expected validator: $Label"
    }
    $script:count++
    Write-Output "Environment probe passed: $Label"
}

Assert-Configuration (Encode-Defines $valid) $true 'canonical staging fixture'
Assert-Configuration '' $false 'missing configuration'
foreach ($key in @($valid.Keys)) {
    $missing = $valid.Clone()
    [void]$missing.Remove($key)
    Assert-Configuration (Encode-Defines $missing) $false "missing $key"
}
foreach ($entry in @{
    CARENET_ENVIRONMENT = 'production'
    CARENET_API_BASE_URL = 'http://staging.example.invalid'
    CARENET_FIREBASE_PROJECT_ID = 'carenet-175b7'
    CARENET_FIREBASE_APP_ID = $productionApp
    CARENET_FIREBASE_MESSAGING_SENDER_ID = '123'
    CARENET_FIREBASE_API_KEY = 'wrong-format'
    GOOGLE_SIGN_IN_SERVER_CLIENT_ID = 'wrong-format'
}.GetEnumerator()) {
    $wrong = $valid.Clone()
    $wrong[$entry.Key] = $entry.Value
    Assert-Configuration (Encode-Defines $wrong) $false "invalid $($entry.Key)"
}
$whitespace = $valid.Clone()
$whitespace.CARENET_FIREBASE_API_KEY = ' ' + $whitespace.CARENET_FIREBASE_API_KEY
Assert-Configuration (Encode-Defines $whitespace) $false 'provider whitespace'
Assert-Configuration 'not-base64' $false 'malformed encoding'
$duplicate = (Encode-Defines $valid) + ',' + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('CARENET_ENVIRONMENT=staging'))
Assert-Configuration $duplicate $false 'duplicate define'
foreach ($url in @('https://user:password@example.invalid', 'https://example.invalid?token=fixture', 'https://example.invalid#fragment')) {
    $wrong = $valid.Clone()
    $wrong.CARENET_API_BASE_URL = $url
    Assert-Configuration (Encode-Defines $wrong) $false 'unsafe URL structure'
}
$production = $valid.Clone()
$production.CARENET_ENVIRONMENT = 'production'
$production.CARENET_FIREBASE_APP_ID = $productionApp
$production.CARENET_API_BASE_URL = 'https://api.example.invalid'
Assert-Configuration (Encode-Defines $production) $false 'production blocked until canonical host is registered' 'Production'
foreach ($url in @('http://carenet-staging-mobile-gateway-7ncephib.uc.gateway.dev', 'https://staging.attacker.example')) {
    $wrong = $valid.Clone()
    $wrong.CARENET_API_BASE_URL = $url
    Assert-Configuration (Encode-Defines $wrong) $false 'staging rejects untrusted API host' 'Staging'
}
foreach ($url in @('https://carenet-staging-mobile-gateway-7ncephib.uc.gateway.dev', 'https://localhost', 'https://127.0.0.1', 'https://[::1]', 'https://api.local')) {
    $wrong = $production.Clone()
    $wrong.CARENET_API_BASE_URL = $url
    Assert-Configuration (Encode-Defines $wrong) $false 'production rejects unregistered API host' 'Production'
}
foreach ($flavor in @('Staging', 'Production')) {
    foreach ($task in @("assemble${flavor}Release", "bundle${flavor}Release", "package${flavor}Release", "package${flavor}ReleaseBundle")) {
        $result = Invoke-Gradle @($task, '--dry-run', '--console=plain')
        if ($result.Code -ne 0 -or $result.Output -notmatch ":app:validate${flavor}ReleaseEnvironment" -or
            $result.Output -notmatch ':app:validateReleaseSigning') {
            throw "Release packaging is missing an environment or signing gate: $task."
        }
    }
}
$lint = Invoke-Gradle @('lintStagingRelease', '--dry-run', '--console=plain')
$debug = Invoke-Gradle @('assembleStagingDebug', '--dry-run', '--console=plain')
if ($lint.Code -ne 0 -or $debug.Code -ne 0 -or
    $lint.Output -match ':app:validate\w+ReleaseEnvironment' -or
    $debug.Output -match ':app:validate\w+ReleaseEnvironment') {
    throw 'Debug or lint incorrectly requires release configuration.'
}
Write-Output "$count release configuration probes passed; eight packaging graphs and debug/lint independence verified."
