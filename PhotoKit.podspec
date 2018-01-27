Pod::Spec.new do |s|
  s.name             = 'PhotoKit'
  s.version          = "1.0.0"
  s.summary          = "An elegant image picker for iOS"
  s.homepage         = "https://github.com/Meniny/PhotoKit"
  s.license          = { :type => "MIT", :file => "LICENSE.md" }
  s.author           = 'Elias Abel'
  s.source           = { :git => "https://github.com/Meniny/PhotoKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://meniny.cn/'
  s.source_files     = "PhotoKit/**/*.swift"
  s.resources        = ['PhotoKit/Assets.xcassets', 'PhotoKit/**/*.xib']
  s.requires_arc     = true
  s.ios.deployment_target = "9.0"
  s.description      = "PhotoKit is an elegant image picker for iOS"
  s.module_name      = 'PhotoKit'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  s.dependency         "JustLayout"
end
