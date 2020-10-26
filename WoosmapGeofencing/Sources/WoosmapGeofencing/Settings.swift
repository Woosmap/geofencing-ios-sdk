//
//  settings.swift
//  WoosmapGeofencing
//
//

import Foundation

//Woosmap SearchAPI Key
public var searchWoosmapKey = ""
public var searchWoosmapAPI = "http://api.woosmap.com/stores/search/?private_key=\(searchWoosmapKey)&lat=%@&lng=%@&stores_by_page=1"

//Location filters
public var currentLocationDistanceFilter = 0.0
public var currentLocationTimeFilter = 0

//API filters
public var searchAPIDistanceFilter = 0.0
public var searchAPITimeFilter = 0

//Active visit
public var visitEnable = true
public var accuracyVisitFilter = 50.0

// Distance detection threshold for visits
public var distanceDetectionThresholdVisits = 50.0

//Active Classification
public var classificationEnable = true

// delay for obsolote notification
public var outOfTimeDelay = 300

//Google Map Static Key
public var GoogleStaticMapKey = ""

//Google Map static API
public let GoogleMapStaticAPIBaseURL = "http://maps.google.com/maps/api/staticmap"
public let GoogleMapStaticAPIOneMark = GoogleMapStaticAPIBaseURL + "?markers=color:blue|%@,%@&zoom=15&size=400x400&sensor=true&key=\(GoogleStaticMapKey)"
public let GoogleMapStaticAPITwoMark = GoogleMapStaticAPIBaseURL + "?markers=color:red|%@,%@&markers=color:blue|%@,%@&zoom=14&size=400x400&sensor=true&key=\(GoogleStaticMapKey)"





