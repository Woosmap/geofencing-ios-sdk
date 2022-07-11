//
//  EventDelegate.swift
//  WoosmapGeofencingCore
//
//  Created by WGS on 11/07/22.
//  Copyright © 2022 Web Geo Services. All rights reserved.
//

import Foundation

public protocol AirshipEventsDelegate: AnyObject {
    func poiEvent(POIEvent: Dictionary <String, Any>, eventName: String)
    func regionEnterEvent(regionEvent: Dictionary <String, Any>, eventName: String)
    func regionExitEvent(regionEvent: Dictionary <String, Any>, eventName: String)
    func visitEvent(visitEvent: Dictionary <String, Any>, eventName: String)
    func ZOIclassifiedEnter(regionEvent: Dictionary <String, Any>, eventName: String)
    func ZOIclassifiedExit(regionEvent: Dictionary <String, Any>, eventName: String)
}
