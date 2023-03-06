Pod::Spec.new do |s|
  s.name                    = "Airwallex"
  s.version                 = "5.3.1"
  s.summary                 = "Integrate Airwallex into your iOS app"
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage                = "https://www.airwallex.com/docs/#overview"
  s.authors                 = { 'Airwallex' => 'pa_mobile_sdk@airwallex.com' }
  s.source                  = { :git => "https://github.com/airwallex/airwallex-payment-ios.git", :tag => "#{s.version}" }
  s.platform                = :ios
  s.ios.deployment_target   = '11.0'
  s.static_framework        = true
  s.default_subspecs        = 'Core', 'WeChatPay', 'Card', 'Redirect', 'ApplePay'
  
  s.subspec 'Security' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = 'Airwallex/Security/*.{h,m}'
    plugin.public_header_files = 'Airwallex/Security/*.h'
    plugin.vendored_frameworks = 'TrustDefender/*.xcframework'
  end
  
  s.subspec 'Core' do |plugin|
    plugin.source_files = 'Airwallex/Core/Sources/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/Core/Sources/*.h'
    plugin.resources = ['Airwallex/Core/Resources/AirwallexCore.bundle']
  end
  
  s.subspec 'WeChatPay' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.dependency 'WechatOpenSDK', '1.9.7'
    plugin.source_files = 'Airwallex/WeChatPay/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/WeChatPay/*.h'
    plugin.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    plugin.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end
  
  s.subspec 'Card' do |plugin|
    plugin.dependency 'Airwallex/Security'
    plugin.source_files = 'Airwallex/Card/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/Card/*.h'
  end
  
  s.subspec 'Redirect' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = 'Airwallex/Redirect/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/Redirect/*.h'
  end
  
  s.subspec 'ApplePay' do |plugin|
    plugin.dependency 'Airwallex/Security'
    plugin.source_files = 'Airwallex/ApplePay/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/ApplePay/*.h'
  end
end
