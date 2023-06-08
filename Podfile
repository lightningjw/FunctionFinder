# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'FunctionFinder' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'GoogleMaps'
  pod 'GooglePlaces'
#  pod 'GooglePlacePicker'
  pod 'GoogleUtilities'
  pod 'Appirater'
  pod 'SDWebImage'

  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'FirebaseCoreExtension'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Storage'

  # Pods for FunctionFinder
  
  post_install do |installer|
      installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                 end
            end
     end
  end

  target 'FunctionFinderTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FunctionFinderUITests' do
    # Pods for testing
  end

end
