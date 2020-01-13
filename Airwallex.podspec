Pod::Spec.new do |spec|
  spec.name         = "Airwallex"
  spec.version      = "1.0"
  spec.summary      = "Integrate Airwallex into your iOS app"
  spec.homepage     = "https://github.com/airwallex/airwallex-payment-ios"
  
  spec.license      = "MIT"
  # spec.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  
  spec.author       = { "Airwallex" }
  
  # spec.platform   = :ios
  # spec.platform   = :ios, "10.0"

  #  When using multiple platforms
  # spec.ios.deployment_target = "10.0"
  # spec.osx.deployment_target = "10.15"
  # spec.watchos.deployment_target = "6.0"
  # spec.tvos.deployment_target = "13.0"
  
  spec.source       = { :git => "https://github.com/airwallex/airwallex-payment-ios", :tag => "#{spec.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "Airwallex/*.{h,m}"
  spec.public_header_files = "Airwallex/*.h"
  
  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.dependency "JSONKit", "~> 1.4"

end
