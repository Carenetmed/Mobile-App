#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint media_compress_kit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'media_compress_kit'
  s.version          = '0.1.0'
  s.summary          = 'Image and video compression with AVFoundation and ImageIO.'
  s.description      = <<-DESC
Compresses images and videos with the platform's own encoders.
                       DESC
  s.homepage         = 'https://github.com/parthbhensdadiya226/media_compress_kit'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Parth Bhensdadiya' => 'parthbhensdadiya7@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'media_compress_kit/Sources/media_compress_kit/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'media_compress_kit_privacy' => ['media_compress_kit/Sources/media_compress_kit/PrivacyInfo.xcprivacy']}
end
