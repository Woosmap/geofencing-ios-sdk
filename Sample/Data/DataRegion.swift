//
//  DataRegion.swift
//  Sample
//

import Foundation

import Foundation
import UIKit
import CoreLocation
import WoosmapGeofencing

public class DataRegion: RegionsServiceDelegate {

    public init() {}

    public func updateRegions(regions: Set<CLRegion>) {
        NotificationCenter.default.post(name: .updateRegions, object: self, userInfo: ["Regions": regions])
    }

    public func didEnterPOIRegion(POIregion: Region) {
        NotificationCenter.default.post(name: .didEventPOIRegion, object: self, userInfo: ["Region": POIregion])
        let content = UNMutableNotificationContent()
        content.title = "Region enter"
        content.body = "Region = " + POIregion.identifier!
        content.body += "Lat = " + String(format: "%f", POIregion.latitude) + " Lng = " + String(format: "%f", POIregion.longitude)
        content.body += "\n FromPositionDetection = " + String(POIregion.fromPositionDetection)
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: nil)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request)
    }

    public func didExitPOIRegion(POIregion: Region) {
        NotificationCenter.default.post(name: .didEventPOIRegion, object: self, userInfo: ["Region": POIregion])
        let content = UNMutableNotificationContent()
        content.title = "Region exit"
        content.body = "Region = " + POIregion.identifier!
        content.body += "Lat = " + String(format: "%f", POIregion.latitude) + " Lng = " + String(format: "%f", POIregion.longitude)
        content.body += "\n FromPositionDetection = " + String(POIregion.fromPositionDetection)
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: nil)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request)
    }
    
    public func workZOIEnter(classifiedRegion: Region) {
        NotificationCenter.default.post(name: .didEventPOIRegion, object: self, userInfo: ["Region": classifiedRegion])
    }
    
    public func homeZOIEnter(classifiedRegion: Region) {
        NotificationCenter.default.post(name: .didEventPOIRegion, object: self, userInfo: ["Region": classifiedRegion])
    }
    

    public func readRegions() -> [Region] {
        return Regions.getAll()
    }

    public func eraseRegions() {
        Regions.deleteAll()
    }
}

extension Notification.Name {
    static let updateRegions = Notification.Name("updateRegions")
    static let didEventPOIRegion = Notification.Name("didEventPOIRegion")

}
