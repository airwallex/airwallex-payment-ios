platform :ios, '11.0'

inhibit_all_warnings!

ENV['SWIFT_VERSION'] = '5'

workspace 'Airwallex.xcworkspace'

def shared_sdk_pods
  pod 'AirwallexBehavioralBiometrics', '6.1.1'
  pod 'AirwallexProfiling', '6.1.1'
  pod 'AirwallexProfilingConnections', '6.1.1'
  pod 'AirwallexCardinalMobile', '2.2.3'
end

target 'Airwallex' do
  project './Airwallex/Airwallex.xcodeproj'
  shared_sdk_pods
end

target 'AirwallexTests' do
  project './Airwallex/Airwallex.xcodeproj'
  shared_sdk_pods
end

def shared_example_pods
  pod 'AlipaySDK-iOS', '15.7.9'
  pod 'WechatOpenSDK', '1.8.7.1'
end

target 'Examples-Demo' do
  project './Examples/Examples.xcodeproj'
  shared_sdk_pods
  shared_example_pods
end

target 'Examples-Staging' do
  project './Examples/Examples.xcodeproj'
  shared_sdk_pods
  shared_example_pods
end

target 'Examples-Production' do
  project './Examples/Examples.xcodeproj'
  shared_sdk_pods
  shared_example_pods
end
