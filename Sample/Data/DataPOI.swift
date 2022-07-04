//
//  DataSearchAPI.swift
//  WoosmapGeofencing
//
//

import Foundation
import CoreLocation
import WoosmapGeofencingCore

public class DataPOI: SearchAPIDelegate {
    public init() {}

    public func searchAPIResponse(poi: POI) {
        NotificationCenter.default.post(name: .newPOISaved, object: self, userInfo: ["POI": poi])
    }

    public func serachAPIError(error: String) {

    }

    public func readPOI() -> [POI] {
        return POIs.getAll()
    }

    func getPOIbyLocationID(locationId: String) -> POI? {
        return POIs.getPOIbyLocationID(locationId: locationId)
    }

    public func erasePOI() {
        POIs.deleteAll()
    }

}

extension Notification.Name {
    static let newPOISaved = Notification.Name("newPOISaved")
}
