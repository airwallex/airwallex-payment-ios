Pod::Spec.new do |s|
  s.name                    = "Airwallex"
  s.version                 = "6.1.2"
  s.summary                 = "Integrate Airwallex into your iOS app"
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage                = "https://www.airwallex.com/docs/#overview"
  s.authors                 = { 'Airwallex' => 'pa_mobile_sdk@airwallex.com' }
  s.source                  = { :git => "https://github.com/airwallex/airwallex-payment-ios.git", :tag => "#{s.version}" }
  s.platform                = :ios
  s.ios.deployment_target   = '13.0'
  s.static_framework        = true
  s.swift_versions          = '5.0'
  s.default_subspec         = 'AirwallexPaymentSheet'
  
  s.subspec 'AirwallexPaymentSheet' do |plugin|
    plugin.source_files = 'Airwallex/AirwallexPaymentSheet/Sources/**/*.{swift,h,m}'
    plugin.public_header_files = 'Airwallex/AirwallexPaymentSheet/Sources/*.h'
    plugin.resource_bundle = {
        'AirwallexPaymentSheet' => 'Airwallex/AirwallexPaymentSheet/Resources/**/*'
    }
    plugin.dependency 'Airwallex/AirwallexPayment'
  end

  s.subspec 'AirwallexPayment' do |plugin|
    plugin.source_files = 'Airwallex/AirwallexPayment/Sources/**/*.{swift,h,m}'
    plugin.public_header_files = 'Airwallex/AirwallexPayment/Sources/*.h'
    plugin.resource_bundle = {
        'AirwallexPayment' => 'Airwallex/AirwallexPayment/Resources/**/*'
    }
    plugin.dependency 'Airwallex/AirwallexCore'
  end
  
  s.subspec 'AirwallexCore' do |plugin|
    plugin.source_files = [ 'Airwallex/Airwallex/Airwallex.h', 'Airwallex/AirwallexCore/Sources/**/*.{swift,h,m}']
    plugin.public_header_files = [
      'Airwallex/Airwallex/Airwallex.h',
      'Airwallex/AirwallexCore/Sources/*.h',
      'Airwallex/AirwallexCore/Sources/Card/*.h',
      'Airwallex/AirwallexCore/Sources/Redirect/*.h',
      'Airwallex/AirwallexCore/Sources/ApplePay/*.h',
      'Airwallex/AirwallexCore/Sources/UI/*.h',
      'Airwallex/AirwallexCore/Sources/Model/*.h',
      'Airwallex/AirwallexCore/Sources/Logging/*.h',
      'Airwallex/AirwallexCore/Sources/Network/*.h'
    ]
    plugin.resource_bundle = {
        'AirwallexCore' => 'Airwallex/AirwallexCore/Resources/**/*'
    }
    plugin.vendored_frameworks = 'Frameworks/AirTracker.xcframework', 'Frameworks/AirwallexRisk.xcframework'
  end
  
  s.subspec 'AirwallexWeChatPay' do |plugin|
    plugin.dependency 'Airwallex/AirwallexCore'
    plugin.source_files = 'Airwallex/AirwallexWeChatPay/**/*.{h,m}'
    plugin.public_header_files = 'Airwallex/AirwallexWeChatPay/*.h'
    plugin.vendored_frameworks = 'Frameworks/WechatOpenSDKDynamic.xcframework'
  end
  
end
