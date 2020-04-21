Pod::Spec.new do |s|
  s.name         				= "Airwallex"
  s.version      				= "1.0"
  s.summary      				= "Integrate Airwallex into your iOS app"
  s.license						= { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     				= "https://www.airwallex.com/docs/#overview"
  s.authors      				= { 'Airwallex' => 'pa_mobile_sdk@airwallex.com' }
  s.source       				= { :git => "https://github.com/airwallex/airwallex-payment-ios.git", :tag => "#{s.version}" }
  s.frameworks					= 'UIKit', 'Foundation', 'Security', 'WebKit'
  s.library						= 'z'
  s.platform   					= :ios
  s.ios.deployment_target		= '10.0'
  s.resources					= ['Airwallex/Airwallex/Resources/**/*']
  s.source_files				= 'Airwallex/Airwallex/Sources/*.{h,m}', 'Airwallex/Airwallex/Sources/UI/*.{h,m}', 'Airwallex/Airwallex/Sources/API/*.{h,m}', 'Airwallex/Airwallex/Sources/Tools/*.{h,m}', 'Airwallex/Airwallex/Sources/Models/*.{h,m}'
  s.dependency					'SVProgressHUD'

  # s.resource_bundles = {
  #   'AirwallexSDK' => ['Airwallex/Airwallex/Resources/**/*.{lproj,storyboard,xib,xcassets,json,imageset,png}']
  # }
end
