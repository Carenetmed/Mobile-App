$ErrorActionPreference = 'Stop'

$projectPath = Join-Path $PSScriptRoot '../ios/Runner.xcodeproj/project.pbxproj'
$podfilePath = Join-Path $PSScriptRoot '../ios/Podfile'
$infoPath = Join-Path $PSScriptRoot '../ios/Runner/Info.plist'
$schemeDirectory = Join-Path $PSScriptRoot '../ios/Runner.xcodeproj/xcshareddata/xcschemes'
$project = Get-Content -Raw $projectPath
$podfile = Get-Content -Raw $podfilePath
$info = [xml](Get-Content -Raw $infoPath)

for ($id = 1; $id -le 18; $id++) {
  $objectId = 'A060000000000000000000{0:X2}' -f $id
  $occurrences = ([regex]::Matches($project, $objectId)).Count
  if ($occurrences -ne 2) {
    throw "Xcode configuration object $objectId is missing or duplicated."
  }
}

$expected = @{
  staging = @{
    bundle = 'com.carenet.app.staging'
    display = 'CareNet Staging'
    firebase = '1:599365440227:ios:6680baeffacc0ce051abd6'
  }
  production = @{
    bundle = 'com.carenet.app'
    display = 'CareNet'
    firebase = '1:599365440227:ios:fac1f0bd4f73677051abd6'
  }
}

foreach ($flavor in $expected.Keys) {
  $schemePath = Join-Path $schemeDirectory "$flavor.xcscheme"
  if (-not (Test-Path $schemePath)) { throw "Missing shared $flavor scheme." }
  [xml]$scheme = Get-Content -Raw $schemePath
  if (-not $scheme.Scheme.TestAction.customLLDBInitFile -or
      -not $scheme.Scheme.LaunchAction.customLLDBInitFile) {
    throw "$flavor scheme must load Flutter's LLDB init file for Run and Test."
  }
  $configurations = @(
    "Debug-$flavor",
    "Profile-$flavor",
    "Release-$flavor"
  )
  foreach ($configuration in $configurations) {
    if (-not $project.Contains("name = `"$configuration`"")) {
      throw "Xcode configuration $configuration is not defined."
    }
    if (-not $podfile.Contains("'$configuration'")) {
      throw "CocoaPods configuration $configuration is not mapped."
    }
  }

  $bundleOccurrences = ([regex]::Matches($project, [regex]::Escape($expected[$flavor].bundle))).Count
  if ($bundleOccurrences -lt 3) { throw "Expected app/test bundle IDs for $flavor are missing." }
  if (-not $project.Contains("APP_DISPLAY_NAME = `"$($expected[$flavor].display)`"")) {
    throw "Display name for $flavor is not configured."
  }

  $schemeConfigurations = @(
    $scheme.Scheme.TestAction.buildConfiguration,
    $scheme.Scheme.LaunchAction.buildConfiguration,
    $scheme.Scheme.ProfileAction.buildConfiguration,
    $scheme.Scheme.AnalyzeAction.buildConfiguration,
    $scheme.Scheme.ArchiveAction.buildConfiguration
  )
  foreach ($configuration in $schemeConfigurations) {
    if ($configuration -notin $configurations) {
      throw "$flavor scheme points at an unknown build configuration: $configuration"
    }
  }
}

if (-not $project.Contains('IPHONEOS_DEPLOYMENT_TARGET = 15.0;') -or
    -not $podfile.Contains("platform :ios, '15.0'")) {
  throw 'iOS deployment minimum must match the resolved Firebase SDK requirement.'
}

$displayNameKey = $info.plist.dict.key | Where-Object { $_ -eq 'CFBundleDisplayName' }
if (-not $displayNameKey) { throw 'Info.plist must use the flavor-specific display name.' }
if (-not $info.OuterXml.Contains('$(APP_DISPLAY_NAME)')) {
  throw 'Info.plist does not read APP_DISPLAY_NAME from the selected configuration.'
}

Write-Output 'iOS staging/production schemes, bundle IDs, display names, and CocoaPods mappings are consistent.'
