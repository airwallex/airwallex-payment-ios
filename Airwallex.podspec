Pod::Spec.new do |s|
  s.name         				= "Airwallex"
  s.version      				= "3.0.0"
  s.summary      				= "Integrate Airwallex into your iOS app"
  s.license						= { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     				= "https://www.airwallex.com/docs/#overview"
  s.authors      				= { 'Airwallex' => 'pa_mobile_sdk@airwallex.com' }
  s.source       				= { :git => "https://github.com/airwallex/airwallex-payment-ios.git", :tag => "#{s.version}" }
  s.platform   					= :ios
  s.ios.deployment_target		= '11.0'
  s.resources					= ['Airwallex/Airwallex/Resources/**/*']
  s.source_files				= 'Airwallex/Airwallex/Sources/*.{h,m}', 'Airwallex/Airwallex/Sources/UI/*.{h,m}', 'Airwallex/Airwallex/Sources/API/*.{h,m}', 'Airwallex/Airwallex/Sources/Tools/*.{h,m}', 'Airwallex/Airwallex/Sources/Models/*.{h,m}'
  s.static_framework			= true
  s.dependency					'SVProgressHUD'
  s.dependency					'AirwallexBehavioralBiometrics'
  s.dependency                  'AirwallexProfiling'
  s.dependency                  'AirwallexProfilingConnections'
  s.dependency					'AirwallexCardinalMobile'

  # s.resource_bundles = {
  #   'AirwallexSDK' => ['Airwallex/Airwallex/Resources/**/*.{lproj,storyboard,xib,xcassets,json,imageset,png}']
  # }
end
