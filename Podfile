platform :ios, '11.0'
use_modular_headers!

target 'OktaLogger' do
    pod 'AppCenter', '~>4.1.1'
    pod 'Firebase/Crashlytics', '~>7.4.0'
    pod 'CocoaLumberjack/Swift', '~>3.6.0'
end

target 'OktaLoggerDemoApp' do
    pod 'OktaLogger', :path => '.'
    pod 'Firebase/Crashlytics', '~>7.4.0'

    target 'OktaLoggerTests' do
      inherit! :search_paths
    end
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
end
