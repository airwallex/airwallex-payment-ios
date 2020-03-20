platform :ios, '10.0'

use_frameworks!
inhibit_all_warnings!

ENV['SWIFT_VERSION'] = '5'

workspace 'Airwallex.xcworkspace'

def shared_pods
    pod 'SVProgressHUD', '2.2.5'
end

target 'Airwallex' do
    project './Airwallex/Airwallex.xcodeproj'
    shared_pods
end

target 'Examples' do
    project './Examples/Examples.xcodeproj'
    shared_pods
    pod 'WechatOpenSDK', '1.8.2'
    pod 'IQKeyboardManager', '6.5.4'
end
