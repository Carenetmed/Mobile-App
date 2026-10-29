$ErrorActionPreference = 'Stop'

$projectPath = Join-Path $PSScriptRoot '../ios/Runner.xcodeproj/project.pbxproj'
$podfilePath = Join-Path $PSScriptRoot '../ios/Podfile'
$infoPath = Join-Path $PSScriptRoot '../ios/Runner/Info.plist'
$schemeDirectory = Join-Path $PSScriptRoot '../ios/Runner.xcodeproj/xcshareddata/xcschemes'
$project = Get-Content -Raw $projectPath
$podfile = Get-Content -Raw $podfilePath
$info = [xml](Get-Content -Raw $infoPath)
$frameworkInfo = [xml](Get-Content -Raw (Join-Path $PSScriptRoot '../ios/Flutter/AppFrameworkInfo.plist'))

function Assert-OrientationContract([xml]$Plist, [string]$FlutterSource) {
  $calls = [regex]::Matches($FlutterSource, '(?s)SystemChrome\.setPreferredOrientations\(\s*\[(.*?)\]\s*\)')
  if ($calls.Count -ne 1) { throw 'Expected one explicit Flutter startup orientation list.' }
  $flutterOrientations = @([regex]::Matches($calls[0].Groups[1].Value, 'DeviceOrientation\.(\w+)') |
    ForEach-Object { $_.Groups[1].Value })
  if ($flutterOrientations.Count -ne 2 -or
      @($flutterOrientations | Sort-Object -Unique).Count -ne 2 -or
      'portraitUp' -cnotin $flutterOrientations -or 'portraitDown' -cnotin $flutterOrientations) {
    throw 'Flutter startup must retain the portraitUp/portraitDown contract.'
  }
  $nativeNames = @{ portraitUp = 'UIInterfaceOrientationPortrait'; portraitDown = 'UIInterfaceOrientationPortraitUpsideDown' }
  $expectedPhone = @($flutterOrientations | ForEach-Object { $nativeNames[$_] })
  $phoneArrays = $Plist.SelectNodes('/plist/dict/key[.="UISupportedInterfaceOrientations"]/following-sibling::*[1][self::array]')
  if ($phoneArrays.Count -ne 1) { throw 'Expected one iPhone orientation array.' }
  $phone = @($phoneArrays[0].SelectNodes('*') | ForEach-Object { $_.InnerText })
  if ($phone.Count -ne 2 -or @($phone | Sort-Object -Unique).Count -ne 2 -or
      @(Compare-Object $expectedPhone $phone -CaseSensitive).Count -ne 0) {
    throw 'iPhone native orientations must match Flutter startup portrait orientations.'
  }

  # iPad multitasking requires all orientations; do not opt out to enforce a phone-only lock.
  $ipadArrays = $Plist.SelectNodes('/plist/dict/key[.="UISupportedInterfaceOrientations~ipad"]/following-sibling::*[1][self::array]')
  if ($ipadArrays.Count -ne 1) { throw 'Expected one iPad orientation array.' }
  $ipad = @($ipadArrays[0].SelectNodes('*') | ForEach-Object { $_.InnerText })
  $expectedIpad = @($expectedPhone) + @('UIInterfaceOrientationLandscapeLeft', 'UIInterfaceOrientationLandscapeRight')
  if ($ipad.Count -ne 4 -or @($ipad | Sort-Object -Unique).Count -ne 4 -or
      @(Compare-Object $expectedIpad $ipad -CaseSensitive).Count -ne 0 -or
      $Plist.SelectSingleNode('/plist/dict/key[.="UIRequiresFullScreen"]/following-sibling::*[1][self::true]')) {
    throw 'Preserve all four iPad multitasking orientations without requiring full screen.'
  }
}

$flutterMain = Get-Content -Raw (Join-Path $PSScriptRoot '../lib/main.dart')
Assert-OrientationContract $info $flutterMain

# Exercise regressions in memory without changing native or Flutter source files.
$orientationProbes = 0
foreach ($key in @('UISupportedInterfaceOrientations', 'UISupportedInterfaceOrientations~ipad')) {
  [xml]$changed = $info.CloneNode($true)
  $array = $changed.SelectSingleNode("/plist/dict/key[.='$key']/following-sibling::*[1]")
  if ($key -eq 'UISupportedInterfaceOrientations') {
    $array.LastChild.InnerText = 'UIInterfaceOrientationLandscapeLeft'
  } else {
    [void]$array.RemoveChild($array.LastChild)
  }
  $rejected = $false
  try { Assert-OrientationContract $changed $flutterMain } catch { $rejected = $true }
  if (-not $rejected) { throw "Orientation guard accepted regressed $key." }
  $orientationProbes++
}
$rejected = $false
try {
  Assert-OrientationContract $info ($flutterMain.Replace('DeviceOrientation.portraitDown', 'DeviceOrientation.landscapeLeft'))
} catch { $rejected = $true }
if (-not $rejected) { throw 'Orientation guard accepted Flutter landscape drift.' }
$orientationProbes++
[xml]$changed = $info.CloneNode($true)
$fullScreenKey = $changed.CreateElement('key')
$fullScreenKey.InnerText = 'UIRequiresFullScreen'
[void]$changed.plist.dict.AppendChild($fullScreenKey)
[void]$changed.plist.dict.AppendChild($changed.CreateElement('true'))
$rejected = $false
try { Assert-OrientationContract $changed $flutterMain } catch { $rejected = $true }
if (-not $rejected) { throw 'Orientation guard accepted an iPad full-screen opt-out.' }
$orientationProbes++
Write-Output "iOS/Flutter orientation contract and $orientationProbes negative regression probes passed."

$flavorConfigurations = @(
  'Debug-staging', 'Profile-staging', 'Release-staging',
  'Debug-production', 'Profile-production', 'Release-production'
)
for ($index = 0; $index -lt $flavorConfigurations.Count; $index++) {
  $name = $flavorConfigurations[$index]
  $configurationId = 'A060000000000000000000{0:X2}' -f (13 + $index)
  $fileId = 'B060000000000000000000{0:X2}' -f (1 + $index)
  $configuration = [regex]::Match($project, "(?m)^\s*$configurationId /\*[^\r\n]+")
  if (-not $configuration.Success -or
      -not $configuration.Value.Contains("baseConfigurationReference = $fileId /* $name.xcconfig */")) {
    throw "$name must use its matching Flutter/CocoaPods configuration."
  }
  $configurationPath = Join-Path $PSScriptRoot "../ios/Flutter/$name.xcconfig"
  $content = Get-Content -Raw $configurationPath
  $podsName = $name.ToLowerInvariant()
  if (-not $content.Contains("Pods-Runner.$podsName.xcconfig") -or
      -not $content.Contains('#include "Generated.xcconfig"')) {
    throw "$name must include its own CocoaPods settings and Generated.xcconfig."
  }
}

foreach ($mode in @('Debug', 'Profile', 'Release')) {
  $content = Get-Content -Raw (Join-Path $PSScriptRoot "../ios/Flutter/$mode.xcconfig")
  if (-not $content.Contains("Pods-Runner.$($mode.ToLowerInvariant()).xcconfig")) {
    throw "$mode must include its matching CocoaPods configuration."
  }
}

for ($id = 1; $id -le 18; $id++) {
  $objectId = 'A060000000000000000000{0:X2}' -f $id
  $occurrences = ([regex]::Matches($project, $objectId)).Count
  if ($occurrences -ne 2) {
    throw "Xcode configuration object $objectId is missing or duplicated."
  }
}

foreach ($id in 7..18) {
  $objectId = 'A060000000000000000000{0:X2}' -f $id
  $configuration = [regex]::Match(
    $project,
    "(?s)$objectId.*?isa = XCBuildConfiguration;.*?buildSettings = \{(.*?)\};"
  )
  if (-not $configuration.Success -or
      -not $configuration.Groups[1].Value.Contains('CLANG_ENABLE_OBJC_ARC = YES;')) {
    throw "Flavor build configuration $objectId must enable Objective-C ARC."
  }
}

$expected = @{
  staging = @{
    bundle = 'com.carenet.app.staging'
    display = 'CareNet Staging'
    firebase = '1:599365440227:ios:6680baeffacc0ce051abd6'
    googleClient = '599365440227-kbjtm738r7gs46tir1tcohieqb931n97.apps.googleusercontent.com'
    googleScheme = 'com.googleusercontent.apps.599365440227-kbjtm738r7gs46tir1tcohieqb931n97'
  }
  production = @{
    bundle = 'com.carenet.app'
    display = 'CareNet'
    firebase = '1:599365440227:ios:fac1f0bd4f73677051abd6'
    googleClient = '599365440227-dct2dkdh0tj79an085ocmghpgv6dic82.apps.googleusercontent.com'
    googleScheme = 'com.googleusercontent.apps.599365440227-dct2dkdh0tj79an085ocmghpgv6dic82'
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
    $configurationFile = Join-Path $PSScriptRoot "../ios/Flutter/$configuration.xcconfig"
    $nativeConfig = Get-Content -Raw $configurationFile
    if (-not $nativeConfig.Contains("GOOGLE_SIGN_IN_IOS_CLIENT_ID = $($expected[$flavor].googleClient)") -or
        -not $nativeConfig.Contains("GOOGLE_SIGN_IN_IOS_REVERSED_CLIENT_ID = $($expected[$flavor].googleScheme)")) {
      throw "$configuration has a missing or mismatched Google iOS client/callback scheme."
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
    -not $podfile.Contains("platform :ios, '15.0'") -or
    $frameworkInfo.SelectSingleNode('//dict/key[.="MinimumOSVersion"]/following-sibling::string[1]').InnerText -ne '15.0') {
  throw 'iOS deployment minimum must match the resolved Firebase SDK requirement.'
}

$displayNameKey = $info.plist.dict.key | Where-Object { $_ -eq 'CFBundleDisplayName' }
if (-not $displayNameKey) { throw 'Info.plist must use the flavor-specific display name.' }
if (-not $info.OuterXml.Contains('$(APP_DISPLAY_NAME)')) {
  throw 'Info.plist does not read APP_DISPLAY_NAME from the selected configuration.'
}
if (-not $info.OuterXml.Contains('$(GOOGLE_SIGN_IN_IOS_CLIENT_ID)') -or
    -not $info.OuterXml.Contains('$(GOOGLE_SIGN_IN_IOS_REVERSED_CLIENT_ID)')) {
  throw 'Info.plist must read flavor-specific Google iOS client and callback values.'
}

Write-Output 'iOS staging/production schemes, bundle IDs, Google OAuth callbacks, display names, and CocoaPods mappings are consistent.'
