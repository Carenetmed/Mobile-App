param([string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
$androidNamespace = 'http://schemas.android.com/apk/res/android'
$domains = @('root', 'file', 'database', 'sharedpref', 'external',
    'device_root', 'device_file', 'device_database', 'device_sharedpref')

function Assert-BackupPolicy([xml]$Manifest, [xml]$Rules) {
    $application = $Manifest.SelectSingleNode('/manifest/application')
    if ($null -eq $application -or
        $application.GetAttribute('allowBackup', $androidNamespace) -cne 'false' -or
        $application.GetAttribute('fullBackupContent', $androidNamespace) -cne 'false' -or
        $application.GetAttribute('dataExtractionRules', $androidNamespace) -cne '@xml/carenet_data_extraction_rules') {
        throw 'Android backup manifest policy is missing or weakened.'
    }
    if ($Rules.DocumentElement.Name -ne 'data-extraction-rules' -or
        $Rules.SelectNodes('//include').Count -ne 0) {
        throw 'Android backup rules must exclude all application data.'
    }
    foreach ($mode in @('cloud-backup', 'device-transfer')) {
        $sections = $Rules.SelectNodes("/data-extraction-rules/$mode")
        if ($sections.Count -ne 1) { throw "Missing or duplicate $mode policy." }
        foreach ($domain in $domains) {
            $exclusions = $sections[0].SelectNodes("exclude[@domain='$domain' and @path='.']")
            if ($exclusions.Count -ne 1) { throw "Missing $mode exclusion for $domain." }
        }
    }
}

[xml]$manifest = Get-Content -LiteralPath (Join-Path $RepositoryRoot 'android/app/src/main/AndroidManifest.xml') -Raw
[xml]$rules = Get-Content -LiteralPath (Join-Path $RepositoryRoot 'android/app/src/main/res/xml/carenet_data_extraction_rules.xml') -Raw
Assert-BackupPolicy $manifest $rules

# Prove the guard rejects policy regressions rather than merely parsing XML.
$probes = 0
foreach ($mode in @('cloud-backup', 'device-transfer')) {
    foreach ($domain in $domains) {
        [xml]$weakened = $rules.CloneNode($true)
        $node = $weakened.SelectSingleNode("/data-extraction-rules/$mode/exclude[@domain='$domain']")
        [void]$node.ParentNode.RemoveChild($node)
        $rejected = $false
        try { Assert-BackupPolicy $manifest $weakened } catch { $rejected = $true }
        if (-not $rejected) { throw "Guard accepted missing $mode/$domain exclusion." }
        $probes++
    }
    [xml]$weakened = $rules.CloneNode($true)
    $node = $weakened.SelectSingleNode("/data-extraction-rules/$mode")
    [void]$node.ParentNode.RemoveChild($node)
    $rejected = $false
    try { Assert-BackupPolicy $manifest $weakened } catch { $rejected = $true }
    if (-not $rejected) { throw "Guard accepted missing $mode section." }
    $probes++
    [xml]$weakened = $rules.CloneNode($true)
    $include = $weakened.CreateElement('include')
    $include.SetAttribute('domain', 'sharedpref')
    $include.SetAttribute('path', '.')
    [void]$weakened.SelectSingleNode("/data-extraction-rules/$mode").AppendChild($include)
    $rejected = $false
    try { Assert-BackupPolicy $manifest $weakened } catch { $rejected = $true }
    if (-not $rejected) { throw "Guard accepted include rules in $mode." }
    $probes++
}
foreach ($attribute in @('allowBackup', 'fullBackupContent', 'dataExtractionRules')) {
    [xml]$weakened = $manifest.CloneNode($true)
    $weakened.SelectSingleNode('/manifest/application').SetAttribute($attribute, $androidNamespace, 'true') | Out-Null
    $rejected = $false
    try { Assert-BackupPolicy $weakened $rules } catch { $rejected = $true }
    if (-not $rejected) { throw "Guard accepted weakened $attribute." }
    $probes++
}
Write-Output "Android backup policy passed; $probes negative regression probes passed."
