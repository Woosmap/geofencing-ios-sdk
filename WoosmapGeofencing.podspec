Pod::Spec.new do |s|
  s.name = 'WoosmapGeofencing'
  s.version = '1.7'
  s.license = 'MIT'
  s.summary = 'Geofencing in Swift'
  s.homepage = 'https://github.com/woosmap/woosmap-geofencing-ios-sdk'
  s.authors = { 'Web Geo Services' => 'https://developers.woosmap.com/support/contact/'}
  s.documentation_url = 'https://github.com/woosmap/woosmap-geofencing-ios-sdk'

  s.ios.deployment_target = '12.0'

  s.swift_versions = ['5.1', '5.2']
  s.source       = { :git => "https://github.com/Woosmap/woosmap-geofencing-ios-sdk/deploy/package/" }
  s.public_header_files = "WoosmapGeofencing.framework/Headers/*.h"
  s.source_files = "WoosmapGeofencing.xcframework/*.h"
  s.vendored_frameworks = "WoosmapGeofencing.xcframework"
  s.dependency 'Realm'
  s.dependency 'RealmSwift'
  s.dependency 'RealmSwift'
  s.dependency 'Surge'
  s.dependency 'JSONSchema'
  
end
