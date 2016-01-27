# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'FriedChicken' do
  pod 'BrightFutures' # 非同期処理のFuture
  pod 'MRProgress' # プログレスダイアログ
  pod 'SCLAlertView' # AlertView
  pod 'Fabric' # Twitter Fabric
  pod 'Crashlytics' # Crash収集サービス
  pod 'RealmSwift' # Modileデータベース
  pod 'SSZipArchive' # Zip解凍ライブラリ
end


post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-FriedChicken/Pods-FriedChicken-acknowledgements.plist', 'FriedChicken/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
