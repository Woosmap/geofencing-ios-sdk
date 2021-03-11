//
//  AirshipEvents.swift
//  Sample
//
//

import Foundation
import CoreLocation
import WoosmapGeofencing
#if canImport(AirshipCore)
  import AirshipCore
#endif

public class AirshipEvents: AirshipEventsDelegate {
    
    public init() {}
    
    public func regionEnterEvent(regionEvent: Dictionary<String, Any>) {
        #if canImport(AirshipCore)
            let event = UACustomEvent(name: "geofence_entered_event", value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func regionExitEvent(regionEvent: Dictionary<String, Any>) {
        #if canImport(AirshipCore)
            let event = UACustomEvent(name: "geofence_exited_event", value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func visitEvent(visitEvent: Dictionary<String, Any>) {
        #if canImport(AirshipCore)
            let event = UACustomEvent(name: "visit_event", value: 1)
            event.properties = visitEvent
            event.track()
        #endif
    }
    
    public func poiEvent(POIEvent: Dictionary<String, Any>) {
        #if canImport(AirshipCore)
            let event = UACustomEvent(name: "poi_event", value: 1)
            event.properties = POIEvent
            event.track()
        #endif
    }
}
    
    
