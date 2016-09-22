platform :ios, '9.0'
use_frameworks!
 
target 'Digg' do
  pod 'APIKit', :git => 'https://github.com/ishkawa/APIKit.git', :submodules => true
  pod 'Himotoki', '~> 3.0'
  pod 'Kingfisher', '~> 3.0'
  pod 'RealmSwift', '~> 1.1.0'
  pod 'NVActivityIndicatorView'
end

plugin 'cocoapods-keys', {
  :project => "Digg",
  :keys => [
    "LastfmAPIKey"
  ]
}

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

