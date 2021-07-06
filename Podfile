platform :ios, '10.0'

inhibit_all_warnings!

ENV['SWIFT_VERSION'] = '5'

workspace 'Airwallex.xcworkspace'

def shared_sdk_pods
  pod 'SVProgressHUD', '2.2.5'
  pod 'AirwallexTrustDefender', '5.0.32'
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
  pod 'WechatOpenSDK', '1.8.2'
end

target 'Examples-Demo' do
  project './Examples/Examples.xcodeproj'
  shared_sdk_pods
  shared_example_pods
end

target 'Examples-Production' do
  project './Examples/Examples.xcodeproj'
  shared_sdk_pods
  shared_example_pods
end
