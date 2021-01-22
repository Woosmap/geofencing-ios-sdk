//
//  DataLocation.swift
//  WoosmapGeofencing
//
//

import Foundation
import UIKit
import CoreLocation
import WoosmapGeofencing

public class DataLocation:LocationServiceDelegate  {
    
    public init() {}
    
    public func tracingLocation(location: Location) {
        NotificationCenter.default.post(name: .newLocationSaved, object: self,userInfo: ["Location": location])
    }
    
    public func tracingLocationDidFailWithError(error: Error) {
        NSLog("\(error)")
    }
    
    public func readLocations()-> [Location] {
        return Locations.getAll()
    }
    
    public func eraseLocations() {
        Locations.deleteAll()
    }
    
}

extension Notification.Name {
    static let newLocationSaved = Notification.Name("newLocationSaved")
}


