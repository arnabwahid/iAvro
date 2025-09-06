source 'https://cdn.cocoapods.org/'

platform :osx, '10.13'

target 'Avro Keyboard' do
  pod 'RegexKitLite', '~> 4.0'
  pod 'FMDB', '~> 2.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |c|
      c.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.13'
    end
  end
end
