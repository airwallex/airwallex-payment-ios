Pod::Spec.new do |s|
  s.name         				= "Airwallex"
  s.version      				= "3.0.3"
  s.summary      				= "Integrate Airwallex into your iOS app"
  s.license						= { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     				= "https://www.airwallex.com/docs/#overview"
  s.authors      				= { 'Airwallex' => 'pa_mobile_sdk@airwallex.com' }
  s.source       				= { :git => "https://github.com/airwallex/airwallex-payment-ios.git", :tag => "#{s.version}" }
  s.platform   					= :ios
  s.ios.deployment_target		= '11.0'
  s.static_framework			= true
  s.default_subspecs            = 'Core', 'WeChatPay', 'Card', 'Redirect'
  
  s.subspec 'Core' do |plugin|
    plugin.source_files = 'Airwallex/Airwallex/Sources/*.{h,m}'
  end
  
  s.subspec 'WeChatPay' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.dependency 'WechatOpenSDK'
    plugin.source_files = 'Airwallex/WeChatPay/*.{h,m}'
  end
  
  s.subspec 'Card' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.dependency 'AirwallexBehavioralBiometrics'
    plugin.dependency 'AirwallexProfiling'
    plugin.dependency 'AirwallexProfilingConnections'
    plugin.source_files = 'Airwallex/Card/*.{h,m}'
  end
  
  s.subspec 'Redirect' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = 'Airwallex/Redirect/*.{h,m}'
  end
  
  s.resources                    = ['Airwallex/Airwallex/Resources/**/*']

  # s.resource_bundles = {
  #   'AirwallexSDK' => ['Airwallex/Airwallex/Resources/**/*.{lproj,storyboard,xib,xcassets,json,imageset,png}']
  # }
end
