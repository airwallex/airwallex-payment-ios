Pod::Spec.new do |s|
  s.name                    = "Airwallex"
  s.version                 = "4.0.1"
  s.summary                 = "Integrate Airwallex into your iOS app"
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage                = "https://www.airwallex.com/docs/#overview"
  s.authors                 = { 'Airwallex' => 'pa_mobile_sdk@airwallex.com' }
  s.source                  = { :git => "https://github.com/airwallex/airwallex-payment-ios.git", :tag => "#{s.version}" }
  s.platform                = :ios
  s.ios.deployment_target   = '11.0'
  s.static_framework        = true
  s.default_subspecs        = 'Core', 'WeChatPay', 'Card', 'Redirect'
  s.pod_target_xcconfig     = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig    = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  s.subspec 'Core' do |plugin|
    plugin.source_files = 'Airwallex/Core/Sources/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/Core/Sources/*.h'
    plugin.resources    = ['Airwallex/Core/Resources/AirwallexCore.bundle']
  end
  
  s.subspec 'WeChatPay' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.dependency 'WechatOpenSDK'
    plugin.source_files = 'Airwallex/WeChatPay/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/WeChatPay/*.h'
  end
  
  s.subspec 'Card' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = 'Airwallex/Card/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/Card/*.h'
    plugin.vendored_frameworks = 'TrustDefender/*.xcframework'
  end
  
  s.subspec 'Redirect' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = 'Airwallex/Redirect/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/Redirect/*.h'
  end
  
  s.subspec 'ApplePay' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = 'Airwallex/ApplePay/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/ApplePay/*.h'
  end
end
