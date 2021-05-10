//
//  DataLocation.swift
//  WoosmapGeofencing
//
//

import Foundation
import UIKit
import CoreLocation
import WoosmapGeofencing

public class DataLocation: LocationServiceDelegate {

    public init() {}

    public func tracingLocation(location: Location) {
        NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: ["Location": location])
        
//        let content = UNMutableNotificationContent()
//        content.title = "Location update"
//        content.body = "Location = " + "Lat = " + String(format: "%f", location.latitude) + " Lng = " + String(format: "%f", location.longitude)
//        // Create the request
//        let uuidString = UUID().uuidString
//        let request = UNNotificationRequest(identifier: uuidString,
//                    content: content, trigger: nil)
//
//        // Schedule the request with the system.
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.add(request)
    }
   

    public func tracingLocationDidFailWithError(error: Error) {
        NSLog("\(error)")
    }

    public func readLocations() -> [Location] {
        return Locations.getAll()
    }

    public func eraseLocations() {
        Locations.deleteAll()
    }

}

extension Notification.Name {
    static let newLocationSaved = Notification.Name("newLocationSaved")
}
