# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'iOSProjectInit' do
  use_frameworks!
  
  pod 'Alamofire'
  pod 'SnapKit'
  pod 'TextAttributes'
  pod 'IQKeyboardManagerSwift', '7.0.0'
  pod 'Kingfisher'
  pod 'R.swift'
  pod 'CocoaLumberjack/Swift'
  pod 'KakaJSON'

  pod 'MJRefresh'
  pod 'DZNEmptyDataSet'
  pod 'TTTAttributedLabel'
  pod 'HBDNavigationBar', '~> 1.9.8'
  pod 'SKPhotoBrowser'
  
  pod 'JTAppleCalendar'
#  pod 'Charts'

  pod 'LookinServer', :configurations => ['Debug']
  
  post_install do |installer|
      installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
              end
          end
      end
  end
  
end
