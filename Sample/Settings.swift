//
//  Settings.swift
//  Sample
//
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import Foundation


// delay for obsolote notification
let outOfTimeDelay = 300

//Google Map Static Key
let GoogleStaticMapKey = ""

//Google Map static API
let GoogleMapStaticAPIBaseURL = "http://maps.google.com/maps/api/staticmap"
let GoogleMapStaticAPIOneMark = GoogleMapStaticAPIBaseURL + "?markers=color:blue|%@,%@&zoom=15&size=400x400&sensor=true&key=\(GoogleStaticMapKey)"
let GoogleMapStaticAPITwoMark = GoogleMapStaticAPIBaseURL + "?markers=color:red|%@,%@&markers=color:blue|%@,%@&zoom=14&size=400x400&sensor=true&key=\(GoogleStaticMapKey)"

//Woosmap
let WoosmapKey = ""
let WoosmapURL = "http://api.woosmap.com"

//Woosmap SearchAPI Key
let searchWoosmapAPI = "\(WoosmapURL)/stores/search/?private_key=\(WoosmapKey)&lat=%@&lng=%@&stores_by_page=1"

//Woosmap DistanceAPI
let drivingModeDistance = "driving"
let cyclingModeDistance = "cycling"
let walkingModeDistance = "walking"
public var modeDistance = drivingModeDistance
let distanceWoosmapAPI = "\(WoosmapURL)/distance/distancematrix/json?mode=\(modeDistance)&units=metric&origins=%@,%@&destinations=%@&private_key=\(WoosmapKey)&elements=duration_distance"


//Delay of Duration data
public var dataDurationDelay = 30// number of day


