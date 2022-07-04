//
//  MarketingCloudEvents.swift
//  Sample
//
//
import Foundation
import CoreLocation
import WoosmapGeofencingCore

public class MarketingCloudEvents: MarketingCloudEventsDelegate {
    
    public init() {}
    
    public func regionEnterEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add your data in the dictonnary
        print("MarketingCloudEvents regionEnterEvent")
    }
    
    public func regionExitEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add your data in the dictonnary
        print("MarketingCloudEvents regionExitEvent")
    }
    
    public func visitEvent(visitEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add your data in the dictonnary
        print("MarketingCloudEvents visitEvent")
    }
    
    public func poiEvent(POIEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add your data in the dictonnary
        print("MarketingCloudEvents poiEvent")
    }
    
    public func ZOIclassifiedEnter(regionEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add your data in the dictonnary
        print("MarketingCloudEvents ZOIclassifiedEnter")
    }
    
    public func ZOIclassifiedExit(regionEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add your data in the dictonnary
        print("MarketingCloudEvents ZOIclassifiedExit")
    }
}
    
    
