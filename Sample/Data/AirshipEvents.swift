//
//  AirshipEvents.swift
//  Sample
//
//

import Foundation
import CoreLocation
import WoosmapGeofencingCore
#if canImport(AirshipCore)
  import AirshipCore
#endif

public class AirshipEvents: AirshipEventsDelegate {
    
    public init() {}
    
    public func regionEnterEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        print("AirshipEvents regionEnterEvent")
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func regionExitEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        print("AirshipEvents regionExitEvent")
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func visitEvent(visitEvent: Dictionary<String, Any>, eventName: String) {
        print("AirshipEvents visitEvent")
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = visitEvent
            event.track()
        #endif
    }
    
    public func poiEvent(POIEvent: Dictionary<String, Any>, eventName: String) {
        print("AirshipEvents poiEvent")
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = POIEvent
            event.track()
        #endif
    }
    
    public func ZOIclassifiedEnter(regionEvent: Dictionary<String, Any>, eventName: String) {
        print("AirshipEvents ZOIclassifiedEnter")
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func ZOIclassifiedExit(regionEvent: Dictionary<String, Any>, eventName: String) {
        print("AirshipEvents ZOIclassifiedExit")
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
}
    
    
