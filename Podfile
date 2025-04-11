source 'https://cdn.cocoapods.org/'
platform :ios, '13.0'

use_frameworks!
inhibit_all_warnings!

workspace 'Airwallex.xcworkspace'

target 'AirwallexCoreTests' do
  project './Airwallex/Airwallex.xcodeproj'
  pod 'OCMock'
end

target 'Examples' do
  project './Examples/Examples.xcodeproj'
  # if you need to support wechatpay, you will need to include AirwallexWeChatPay explicitly
  pod 'Airwallex', :path => './', :subspecs => ['AirwallexPaymentSheet', "AirwallexWeChatPay"]
#  pod 'Airwallex', :path => './'
end
