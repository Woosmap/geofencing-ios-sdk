//
//  DataVisit.swift
//
//  WoosmapGeofencing
//
//
import Foundation
import CoreLocation
import WoosmapGeofencing

public class DataVisit: VisitServiceDelegate {

    public init() {}

    public func processVisit(visit: Visit) {
        NotificationCenter.default.post(name: .newVisitSaved, object: self, userInfo: ["Visit": visit])
    }

    public func readVisits() -> [Visit] {
        return Visits.getAll()
    }

    public func eraseVisits() {
        Visits.deleteAll()
    }
}

extension Notification.Name {
    static let newVisitSaved = Notification.Name("newVisitSaved")
}
