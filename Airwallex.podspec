Pod::Spec.new do |s|
  s.name                    = "Airwallex"
  s.version                 = "5.7.0"
  s.summary                 = "Integrate Airwallex into your iOS app"
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage                = "https://www.airwallex.com/docs/#overview"
  s.authors                 = { 'Airwallex' => 'pa_mobile_sdk@airwallex.com' }
  s.source                  = { :git => "https://github.com/airwallex/airwallex-payment-ios.git", :tag => "#{s.version}" }
  s.platform                = :ios
  s.ios.deployment_target   = '13.0'
  s.static_framework        = true
  s.swift_versions          = '5.0'
  s.default_subspecs        = 'Payment'
  
  s.subspec 'Payment' do |plugin|
    plugin.source_files = 'Airwallex/Payment/Sources/**/*.{swift,h,m}'
    plugin.public_header_files = 'Airwallex/Payment/Sources/*.h'
    plugin.resource_bundle = {
        'AirwallexPayment' => 'Airwallex/Payment/Resources/**/*'
    }
    plugin.dependency 'Airwallex/Core'
    plugin.dependency 'Airwallex/Card'
    plugin.dependency 'Airwallex/Redirect'
    plugin.dependency 'Airwallex/ApplePay'
  end
  
  s.subspec 'Core' do |plugin|
    plugin.source_files = 'Airwallex/Core/Sources/**/*.{swift,h,m}'
    plugin.public_header_files = 'Airwallex/Core/Sources/*.h'
    plugin.resource_bundle = {
        'AirwallexCore' => 'Airwallex/Core/Resources/**/*'
    }
    plugin.vendored_frameworks = 'Frameworks/AirTracker.xcframework', 'Frameworks/AirwallexRisk.xcframework'
  end
  
  s.subspec 'WeChatPay' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = 'Airwallex/WeChatPay/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/WeChatPay/*.h'
    plugin.frameworks =  'Security', 'UIKit', 'CoreGraphics', 'WebKit'
    plugin.vendored_frameworks = 'Frameworks/WechatOpenSDK.xcframework'
    plugin.libraries = 'z', 'sqlite3.0', 'c++'
    plugin.pod_target_xcconfig = {
        'OTHER_LDFLAGS' => '-ObjC -all_load'
      }
  end
  
  s.subspec 'Card' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = ['Airwallex/Card/**/*.{swift,h,m}', 'Airwallex/Airwallex.h']
    plugin.public_header_files = ['Airwallex/Card/*.h', 'Airwallex/Airwallex.h']
  end
  
  s.subspec 'Redirect' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = ['Airwallex/Redirect/**/*.{swift,h,m}', 'Airwallex/Airwallex.h']
    plugin.public_header_files = ['Airwallex/Redirect/*.h', 'Airwallex/Airwallex.h']
  end
  
  s.subspec 'ApplePay' do |plugin|
    plugin.dependency 'Airwallex/Core'
    plugin.source_files = 'Airwallex/ApplePay/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/ApplePay/*.h'
  end
end
