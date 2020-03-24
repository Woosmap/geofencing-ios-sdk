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


//Woosmap SearchAPI Key
let searchWoosmapKey = ""
let searchWoosmapAPI = "http://api.woosmap.com/stores/search/?private_key=\(searchWoosmapKey)&lat=%@&lng=%@&stores_by_page=1"


