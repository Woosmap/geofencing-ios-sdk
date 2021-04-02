//
//  Region.swift
//  WoosmapGeofencing
//
//

import Foundation
import RealmSwift
import CoreLocation

public class Region: Object {
    @objc public dynamic var date: Date?
    @objc public dynamic var didEnter: Bool = false
    @objc public dynamic var identifier: String?
    @objc public dynamic var latitude: Double = 0.0
    @objc public dynamic var longitude: Double = 0.0
    @objc public dynamic var radius: Double = 0.0

    convenience init(latitude: Double, longitude: Double, radius: Double, dateCaptured: Date, identifier: String, didEnter: Bool) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
        self.date = dateCaptured
        self.didEnter = didEnter
        self.identifier = identifier
        self.radius = radius
    }
}

public class Regions {
    public class func add(POIregion: CLRegion, didEnter: Bool) -> Region {
        do {
            let realm = try Realm()
            let latRegion = (POIregion as! CLCircularRegion).center.latitude
            let lngRegion = (POIregion as! CLCircularRegion).center.longitude
            let radius = (POIregion as! CLCircularRegion).radius
            let entry = Region(latitude: latRegion, longitude: lngRegion, radius: radius, dateCaptured: Date(), identifier: POIregion.identifier, didEnter: didEnter)
            realm.beginWrite()
            realm.add(entry)
            try realm.commitWrite()
            return entry
        } catch {
        }
        return Region()
    }
    
    public class func add(classifiedRegion: Region) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(classifiedRegion)
            try realm.commitWrite()
        } catch {
        }
    }

    public class func getAll() -> [Region] {
        do {
            let realm = try Realm()
            let regions = realm.objects(Region.self)
            return Array(regions)
        } catch {
        }
        return []
    }

    public class func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(Region.self))
            }
        } catch let error as NSError {
          print(error)
        }
    }
}
