//
//  POI.swift
//  WoosmapGeofencing
//  Copyright © 2021 Web Geo Services. All rights reserved.
//

import RealmSwift
import Foundation

public class POI: Object {
    @objc public dynamic var jsonData: Data?
    @objc public dynamic var city: String?
    @objc public dynamic var idstore: String?
    @objc public dynamic var name: String?
    @objc public dynamic var date: Date?
    @objc public dynamic var distance: Double = 0.0
    @objc public dynamic var duration: String?
    @objc public dynamic var latitude: Double = 0.0
    @objc public dynamic var locationId: String?
    @objc public dynamic var longitude: Double = 0.0
    @objc public dynamic var zipCode: String?

    convenience public init(locationId: String? = nil, city: String? = nil, zipCode: String? = nil, distance: Double? = nil, latitude: Double? = nil, longitude: Double? = nil, dateCaptured: Date? = nil) {
        self.init()
        self.locationId = locationId
        self.city = city
        self.zipCode = zipCode
        self.distance = distance!
        self.latitude = latitude!
        self.longitude = longitude!
        self.date = dateCaptured
    }
}

public class POIs {
    public class func addFromResponseJson(searchAPIResponse: Data, locationId: String) -> POI {
        do {
            let realm = try Realm()
            let poi = POI()
            poi.jsonData = searchAPIResponse
            poi.locationId = locationId
            let responseJSON = try? JSONDecoder().decode(SearchAPIData.self, from: searchAPIResponse)
            for feature in (responseJSON?.features)! {
                poi.city = feature.properties!.address!.city!
                poi.zipCode = feature.properties!.address!.zipcode!
                poi.distance = feature.properties!.distance!
                poi.latitude = (feature.geometry?.coordinates![1])!
                poi.longitude = (feature.geometry?.coordinates![0])!
                poi.date = Date()
                poi.idstore = (feature.properties?.store_id)!
                poi.name = (feature.properties?.name)!
            }
            realm.beginWrite()
            realm.add(poi)
            try realm.commitWrite()
            return poi
        } catch {
        }
        return POI()
    }

    public class func addTest(poi: POI) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(poi)
            try realm.commitWrite()
        } catch {
        }
    }

    public class func getAll() -> [POI] {
        do {
            let realm = try Realm()
            let pois = realm.objects(POI.self)
            return Array(pois)
        } catch {
        }
        return []
    }

    public class func getPOIbyLocationID(locationId: String) -> POI? {
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "locationId == %@", locationId)
            let fetchedResults = realm.objects(POI.self).filter(predicate)
            if let aPOI = fetchedResults.first {
               return aPOI
            }
        } catch {
        }
        return nil
    }

    public class func updatePOIWithDistance(distance: Double, duration: String, locationId: String) -> POI {
        do {
            let poiToUpdate = POIs.getPOIbyLocationID(locationId: locationId)
            if poiToUpdate != nil {
                let realm = try Realm()
                realm.beginWrite()
                poiToUpdate?.distance = distance
                poiToUpdate?.duration = duration
                realm.add(poiToUpdate!)
                try realm.commitWrite()
                return poiToUpdate!
            }
        } catch {
        }
        return POI()
    }

    public class func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(Visit.self))
            }
        } catch let error as NSError {
          print(error)
        }
    }
}
