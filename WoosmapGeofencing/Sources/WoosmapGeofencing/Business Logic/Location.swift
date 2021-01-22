//
//  Location.swift
//  WoosmapGeofencing
//

import Foundation
import RealmSwift
import CoreLocation

public class Location: Object {
    @objc public dynamic var date: Date?
    @objc public dynamic var latitude: Double = 0.0
    @objc public dynamic var locationDescription: String?
    @objc public dynamic var locationId: String?
    @objc public dynamic var longitude: Double = 0.0
    
    convenience public init(locationId: String, latitude: Double, longitude: Double, dateCaptured: Date, descriptionToSave: String) {
        self.init()
        self.locationId = locationId
        self.latitude = latitude
        self.longitude = longitude
        self.date = dateCaptured
        self.locationDescription = descriptionToSave
    }
    
}

public class Locations {
    public class func add(locations: [CLLocation]) -> Location {
        do {
            let realm = try Realm()
            let location = locations.last!
            //create Location ID
            let locationId = UUID().uuidString
            let entry = Location(locationId: locationId, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, dateCaptured: Date(), descriptionToSave: "description")
            realm.beginWrite()
            realm.add(entry)
            try realm.commitWrite()
            return entry
        } catch {
        }
        return Location()
    }
    
    public class func addTest(location: Location) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(location)
            try realm.commitWrite()
        } catch {
        }
    }
    
    public class func getAll() -> [Location] {
        do {
            let realm = try Realm()
            let locations = realm.objects(Location.self)
            return Array(locations)
        } catch {
        }
        return []
    }

    public class func deleteAll() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(Location.self))
        }
    }
}
