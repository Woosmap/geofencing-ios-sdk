Pod::Spec.new do |s|
  s.name = 'WoosmapGeofencing'
  s.version = '1.1.5'
  s.license = 'MIT'
  s.summary = 'Geofencing in Swift'
  s.homepage = 'https://github.com/woosmap/woosmap-geofencing-ios-sdk'
  s.authors = { 'Web Geo Services' => 'https://developers.woosmap.com/support/contact/'}
  s.source = { :git => 'https://github.com/woosmap/woosmap-geofencing-ios-sdk.git', :tag => s.version }
  s.documentation_url = 'https://github.com/woosmap/woosmap-geofencing-ios-sdk'

  s.ios.deployment_target = '11.0'

  s.swift_versions = ['5.1', '5.2']
  s.source_files = 'WoosmapGeofencing/Sources/WoosmapGeofencing/*.swift', 'WoosmapGeofencing/Sources/WoosmapGeofencing/Business Logic/*.swift', 'WoosmapGeofencing/Sources/WoosmapGeofencing/Config/*.swift'
  s.resources = 'WoosmapGeofencing/Sources/WoosmapGeofencing/Config/*.json'
  s.dependency 'Surge', '~> 2.3.0'
  s.dependency 'RealmSwift'
  s.dependency 'Realm' 
end
