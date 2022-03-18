source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

inhibit_all_warnings!

workspace 'Airwallex.xcworkspace'

target 'WeChatPay' do
  project './Airwallex/Airwallex.xcodeproj'
  pod 'WechatOpenSDK', '1.8.7.1'
end

target 'Examples' do
  project './Examples/Examples.xcodeproj'
  pod 'Airwallex', :path => './'
  pod 'WechatOpenSDK', '1.8.7.1'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
