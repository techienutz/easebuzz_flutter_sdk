#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint easebuzz_flutter_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'easebuzz_flutter_sdk'
   s.version          = '0.0.1'
   s.summary          = 'CocoaPod implementation of Easebuzz Payment SDK.'
   s.description      = <<-DESC
                         'We are one of India’s leading payment solutions platform, serving more than 1,00,000 businesses with full-stack technology solutions to accept payments, send payouts & manage end-to-end financial operations with ease.....'
                         DESC
   s.homepage         = 'http://example.com'
   s.license          = { :file => '../LICENSE' }
   s.author           = { 'easebuzz' => 'info@easebuzz.in' }
   s.source           = { :path => '.' }
   s.source_files = 'Classes/**/*'
   s.dependency 'Flutter'
   s.platform = :ios, '12.0'
   s.dependency 'EasebuzzPaymentSDK-V2', '~> 1.3'

   # Flutter.framework does not contain a i386 slice.
   s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
   s.swift_version = '5.0'

   # If your plugin requires a privacy manifest, for example if it uses any
   # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
   # plugin's privacy impact, and then uncomment this line. For more information,
   # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
   # s.resource_bundles = {'easebuzz_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
 end
