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

# DocC catalog is not part of the podspec; add it to the Airwallex pod target so
# `xcodebuild docbuild` works after a fresh `pod install` (local and CI).
post_install do |installer|
  docc_path = File.expand_path('Airwallex.docc', __dir__)
  next unless File.directory?(docc_path)

  installer.pods_project.targets.each do |target|
    next unless target.name == 'Airwallex'

    already_added = target.source_build_phase.files.any? do |build_file|
      ref = build_file.file_ref
      ref && (ref.path&.end_with?('Airwallex.docc') || ref.name == 'Airwallex.docc')
    end
    next if already_added

    docc_ref = installer.pods_project.new_file(docc_path)
    docc_ref.last_known_file_type = 'folder.documentationcatalog'
    target.source_build_phase.add_file_reference(docc_ref)
  end

  installer.pods_project.save
end
