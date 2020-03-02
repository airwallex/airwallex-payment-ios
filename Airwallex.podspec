Pod::Spec.new do |s|
  s.name         				= "Airwallex"
  s.version      				= "1.0"
  s.summary      				= "Integrate Airwallex into your iOS app"
  s.license						= { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     				= "https://www.airwallex.com/docs/#overview"
  s.authors      				= { 'Victor Zhu' => 'victor@interactivelabs.co' }
  s.source       				= { :git => "https://github.com/airwallex/airwallex-payment-ios.git", :tag => "#{s.version}" }
  s.frameworks					= 'UIKit', 'Foundation', 'Security', 'WebKit'
  s.platform   					= :ios
  s.ios.deployment_target		= '10.0'
  s.public_header_files			= "Airwallex/PublicHeaders/*.h"
  s.resources					= ['Airwallex/Resources/AirwallexSDK.bundle', 'Airwallex/Storyboards/**/*']
  s.source_files				= 'Airwallex/PublicHeaders/*.h', 'Airwallex/Sources/*.{h,m}', 'Airwallex/Sources/UI/*.{h,m}', 'Airwallex/Sources/API/*.{h,m}', 'Airwallex/Sources/Tools/*.{h,m}', 'Airwallex/Sources/Models/*.{h,m}'

  #  When using multiple platforms
  # s.ios.deployment_target 	= "10.0"
  # s.osx.deployment_target 	= "10.15"
  # s.watchos.deployment_target = "6.0"
  # s.tvos.deployment_target 	= "13.0"
end
