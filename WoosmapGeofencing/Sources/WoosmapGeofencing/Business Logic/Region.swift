//
//  Region.swift
//  WoosmapGeofencing
//
//

import Foundation
import RealmSwift
import CoreLocation

public class Region: Object {
    @objc public dynamic var date: Date = Date()
    @objc public dynamic var didEnter: Bool = false
    @objc public dynamic var identifier: String = ""
    @objc public dynamic var latitude: Double = 0.0
    @objc public dynamic var longitude: Double = 0.0
    @objc public dynamic var radius: Double = 0.0
    @objc public dynamic var fromPositionDetection: Bool = false
    @objc public dynamic var distance = 0;
    @objc public dynamic var distanceText = "";
    @objc public dynamic var duration = 0;
    @objc public dynamic var durationText = "";
    @objc public dynamic var type = "circle";
    @objc public dynamic var origin = "";

    convenience init(latitude: Double, longitude: Double, radius: Double, dateCaptured: Date, identifier: String, didEnter: Bool, fromPositionDetection: Bool) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
        self.date = dateCaptured
        self.didEnter = didEnter
        self.identifier = identifier
        self.radius = radius
        self.fromPositionDetection = fromPositionDetection
    }
}

public class Regions {
    public class func add(POIregion: CLRegion, didEnter: Bool, fromPositionDetection: Bool) -> Region {
        do {
            let realm = try Realm()
            let latRegion = (POIregion as! CLCircularRegion).center.latitude
            let lngRegion = (POIregion as! CLCircularRegion).center.longitude
            let radius = (POIregion as! CLCircularRegion).radius
            var identifier = POIregion.identifier
            var origin = "custom"
            if(POIregion.identifier.contains(LocationService.RegionType.poi.rawValue)) {
                identifier = POIregion.identifier.components(separatedBy: "<id>")[1]
                origin = "POI"
            } else if (POIregion.identifier.contains(LocationService.RegionType.custom.rawValue)) {
                identifier = POIregion.identifier.components(separatedBy: "<id>")[1]
                origin = "custom"
            }
            let entry = Region(latitude: latRegion, longitude: lngRegion, radius: radius, dateCaptured: Date(), identifier: identifier, didEnter: didEnter, fromPositionDetection: fromPositionDetection)
            entry.origin = origin
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
    
    public class func add(regionIso: RegionIsochrone) -> Region {
        do {
            let realm = try Realm()
            let latRegion = regionIso.latitude
            let lngRegion = regionIso.longitude
            let radius = regionIso.radius
            let entry = Region(latitude: latRegion, longitude: lngRegion, radius: Double(radius), dateCaptured: Date(), identifier: regionIso.identifier!, didEnter: regionIso.didEnter, fromPositionDetection: true)
            entry.duration = regionIso.duration
            entry.durationText = regionIso.durationText
            entry.distance = regionIso.distance
            entry.distanceText = regionIso.distanceText
            entry.type = "isochrone"
            entry.origin = "custom"
            realm.beginWrite()
            realm.add(entry)
            try realm.commitWrite()
            return entry
        } catch {
        }
        return Region()
    }
    
    public class func getRegionFromId(id: String) -> Region? {
        do {
            let realm = try Realm()
            var identifier = id
            if((id.contains(LocationService.RegionType.poi.rawValue) || id.contains(LocationService.RegionType.custom.rawValue))
               && id.contains("<id>")){
                identifier = id.components(separatedBy: "<id>")[1]
            } 
            let predicate = NSPredicate(format: "identifier == %@", identifier)
            let fetchedResults = realm.objects(Region.self).filter(predicate)
            if let aRegion = fetchedResults.last {
               return aRegion
            }
        } catch {
        }
        return nil
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
