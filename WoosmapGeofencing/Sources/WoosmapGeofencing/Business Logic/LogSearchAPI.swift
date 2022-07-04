//
//  LogSearchAPI.swift
//  WoosmapGeofencing
//
//  Created by Mac de Laurent on 10/03/2022.
//  Copyright © 2022 Web Geo Services. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

public class LogSearchAPI: Object {
    @objc public dynamic var date: Date?
    @objc public dynamic var latitude: Double = 0.0
    @objc public dynamic var longitude: Double = 0.0
    @objc public dynamic var lastSearchLocationLatitude: Double = 0.0
    @objc public dynamic var lastSearchLocationLongitude: Double = 0.0
    @objc public dynamic var lastPOI_distance: String?
    @objc public dynamic var distanceLimit: String?
    @objc public dynamic var locationDescription: String?
    @objc public dynamic var distanceTraveled: String?
    @objc public dynamic var distanceToFurthestMonitoredPOI: String?
    @objc public dynamic var distanceTraveledLastRefreshPOIRegion: String?
    @objc public dynamic var searchAPILastRequestTimeStampValue = 0.0
    @objc public dynamic var sendSearchAPIRequest: Bool = false
    @objc public dynamic var woosmapAPIKey: String?
    @objc public dynamic var searchAPIRequestEnable: Bool = false

}

public class LogSearchAPIs {


    public class func add(log: LogSearchAPI) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(log)
            try realm.commitWrite()
        } catch {
        }
    }

    
}
