//
//  settings.swift
//  WoosmapGeofencing
//
//

import Foundation

//Profil
public enum ConfigurationProfile: String {
    case liveTracking
    case passiveTracking
    case visitsTracking
}

// Tracking
public var trackingEnable = true

// Woosmap SearchAPI Key
public var WoosmapAPIKey = ""
public var searchWoosmapAPI = "https://api.woosmap.com/stores/search/?private_key=\(WoosmapAPIKey)&lat=%@&lng=%@&stores_by_page=5"

// Woosmap Distance provider
public enum DistanceProvider: String {
  case woosmapTraffic
  case woosmapDistance
}

public var distanceProvider = DistanceProvider.woosmapDistance

// Woosmap Distance mode
public enum DistanceMode: String {
  case driving
  case cycling
  case walking
  case truck
}

public var distanceMode = DistanceMode.driving // cycling,walking

public var distanceWoosmapAPI = "https://api.woosmap.com/distance/distancematrix/json?mode=%@&units=%@&language=%@&origins=%@,%@&destinations=%@&private_key=\(WoosmapAPIKey)&elements=duration_distance"


public enum TrafficDistanceRouting: String {
  case fastest
  case balanced
}

public enum DistanceUnits: String {
  case metric
  case imperial
}

public var trafficDistanceRouting = TrafficDistanceRouting.fastest
public var distanceUnits = DistanceUnits.metric
public var distanceLanguage = "en"

public var trafficDistanceWoosmapAPI = "https://api.woosmap.com/traffic/distancematrix/json?mode=%@&units=%@&routing=%@&language=%@&departure_time=now&origins=%@,%@&destinations=%@&private_key=\(WoosmapAPIKey)"

//Distance filters
public var distanceMaxAirDistanceFilter = 1000000
public var distanceTimeFilter = 0

// Location filters
public var currentLocationDistanceFilter = 0.0
public var currentLocationTimeFilter = 0
public var modeHighfrequencyLocation = false

// Search API filters
public var searchAPIRequestEnable = true
public var searchAPIDistanceFilter = 0.0
public var searchAPITimeFilter = 0
public var searchAPIRefreshDelayDay = 1
public var searchAPICreationRegionEnable = true
public var searchAPILastRequestTimeStamp = 0.0

// Distance API filters
public var distanceAPIRequestEnable = true

// Active visit
public var visitEnable = true
public var accuracyVisitFilter = 50.0

// Active creation of ZOI
public var creationOfZOIEnable = false

// Active Classification
public var classificationEnable = false
public var radiusDetectionClassifiedZOI = 100.0

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

// Parameter for SearchAPI request
public var searchAPIParameters : [String: String] = [:]

// filter for user_properties data
public var userPropertiesFilter : [String] = []

// credentials SFMC
public var SFMCCredentials : [String: String] = [:]
public var SFMCAccesToken = ""

public var poiRadius:Any = ""

// Forcing ETA refresh when the user doesn't use the expected travel mode, Default: true
public var optimizeDistanceRequest: Bool = true

