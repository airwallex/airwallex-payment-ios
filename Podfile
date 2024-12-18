source 'https://cdn.cocoapods.org/'
platform :ios, '13.0'

use_frameworks!
inhibit_all_warnings!

workspace 'Airwallex.xcworkspace'

target 'WeChatPay' do
  project './Airwallex/Airwallex.xcodeproj'
end

target 'CoreTests' do
  project './Airwallex/Airwallex.xcodeproj'
  pod 'OCMock'
end

target 'CardTests' do
  project './Airwallex/Airwallex.xcodeproj'
  pod 'OCMock'
end

target 'ApplePayTests' do
  project './Airwallex/Airwallex.xcodeproj'
  pod 'OCMock'
end

target 'RedirectTests' do
  project './Airwallex/Airwallex.xcodeproj'
  pod 'OCMock'
end

target 'Examples' do
  project './Examples/Examples.xcodeproj'
  pod 'Airwallex', :path => './'
end
