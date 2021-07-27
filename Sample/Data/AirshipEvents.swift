//
//  AirshipEvents.swift
//  Sample
//
//

import Foundation
import CoreLocation
import WoosmapGeofencing
import MarketingCloudSDK
#if canImport(AirshipCore)
  import AirshipCore
#endif

public class AirshipEvents: AirshipEventsDelegate {
    
    public init() {}
    
    public func regionEnterEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        NSLog("regionEnterEvent : " + regionEvent.description)
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
        SFMCEvent.customEvent(withName:"leo", withAttributes: ["leo":"leo"])
    }
    
    public func regionExitEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func visitEvent(visitEvent: Dictionary<String, Any>, eventName: String) {
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = visitEvent
            event.track()
        #endif
    }
    
    public func poiEvent(POIEvent: Dictionary<String, Any>, eventName: String) {
        NSLog("Airship.poiEvent : " + POIEvent.description)
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = POIEvent
            event.track()
        #endif
        SFMCEvent.customEvent(withName:"leo", withAttributes: ["leo":"leo"])

    }
    
    public func ZOIclassifiedEnter(regionEvent: Dictionary<String, Any>, eventName: String) {
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func ZOIclassifiedExit(regionEvent: Dictionary<String, Any>, eventName: String) {
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
}
    
    
