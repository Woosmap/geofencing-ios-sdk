//
//  settings.swift
//  WoosmapGeofencing
//
//

import Foundation

// Tracking
public var trackingEnable = true

// Woosmap SearchAPI Key
public var WoosmapAPIKey = ""
public var searchWoosmapAPI = "https://api.woosmap.com/stores/search/?private_key=\(WoosmapAPIKey)&lat=%@&lng=%@&stores_by_page=1"

// Woosmap DistanceAPI
public enum DistanceMode: String {
  case driving
  case cycling
  case walking
}
public var distanceMode = DistanceMode.driving // cycling,walking
public var distanceWoosmapAPI = "https://api.woosmap.com/distance/distancematrix/json?mode=\(distanceMode)&units=metric&origins=%@,%@&destinations=%@&private_key=\(WoosmapAPIKey)&elements=duration_distance"

// Location filters
public var currentLocationDistanceFilter = 0.0
public var currentLocationTimeFilter = 0

// Search API filters
public var searchAPIRequestEnable = true
public var searchAPIDistanceFilter = 0.0
public var searchAPITimeFilter = 0
public var searchAPICreationRegionEnable = true
public var firstSearchAPIRegionRadius = 100.0
public var secondSearchAPIRegionRadius = 200.0
public var thirdSearchAPIRegionRadius = 300.0

// Distance API filters
public var distanceAPIRequestEnable = true

// Active visit
public var visitEnable = true
public var accuracyVisitFilter = 50.0

// Active creation of ZOI
public var creationOfZOIEnable = true

// Active Classification
public var classificationEnable = true

// Delay of Duration data
public var dataDurationDelay = 30// number of day

// delay for obsolote notification
public var outOfTimeDelay = 300

// Google Map Static Key
public var GoogleStaticMapKey = ""

// Google Map static API
public let GoogleMapStaticAPIBaseURL = "http://maps.google.com/maps/api/staticmap"
public let GoogleMapStaticAPIOneMark = GoogleMapStaticAPIBaseURL + "?markers=color:blue|%@,%@&zoom=15&size=400x400&sensor=true&key=\(GoogleStaticMapKey)"
public let GoogleMapStaticAPITwoMark = GoogleMapStaticAPIBaseURL + "?markers=color:red|%@,%@&markers=color:blue|%@,%@&zoom=14&size=400x400&sensor=true&key=\(GoogleStaticMapKey)"
