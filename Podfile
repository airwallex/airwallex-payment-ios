source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'

inhibit_all_warnings!

ENV['SWIFT_VERSION'] = '5'

workspace 'Airwallex.xcworkspace'

target 'Airwallex' do
  project './Airwallex/Airwallex.xcodeproj'
end

target 'AirwallexTests' do
  project './Airwallex/Airwallex.xcodeproj'
end

target 'WeChatPay' do
  project './Airwallex/Airwallex.xcodeproj'
  pod 'WechatOpenSDK', '1.8.7.1'
end

target 'Card' do
  project './Airwallex/Airwallex.xcodeproj'
  pod 'AirwallexBehavioralBiometrics', '6.1.55'
  pod 'AirwallexProfiling', '6.1.55'
  pod 'AirwallexProfilingConnections', '6.1.55'
end

target 'Redirect' do
  project './Airwallex/Airwallex.xcodeproj'
end

def shared_example_pods
  pod 'WechatOpenSDK', '1.8.7.1'
  pod 'AirwallexBehavioralBiometrics', '6.1.55'
  pod 'AirwallexProfiling', '6.1.55'
  pod 'AirwallexProfilingConnections', '6.1.55'
end

target 'Examples-Demo' do
  project './Examples/Examples.xcodeproj'
  shared_example_pods
end

target 'Examples-Staging' do
  project './Examples/Examples.xcodeproj'
  shared_example_pods
end

target 'Examples-Production' do
  project './Examples/Examples.xcodeproj'
  shared_example_pods
end
