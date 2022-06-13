//
//  RegionIsochrone.swift
//  WoosmapGeofencing
//

import Foundation
import RealmSwift
import CoreLocation

public class RegionIsochrone: Object {
    @objc public dynamic var date: Date?
    @objc public dynamic var didEnter: Bool = false
    @objc public dynamic var identifier: String?
    @objc public dynamic var locationId: String?
    @objc public dynamic var idStore: String?
    @objc public dynamic var latitude: Double = 0.0
    @objc public dynamic var longitude: Double = 0.0
    @objc public dynamic var radius: Int = 0
    @objc public dynamic var fromPositionDetection: Bool = false
    @objc public dynamic var distance = 0;
    @objc public dynamic var distanceText = "";
    @objc public dynamic var duration = 0;
    @objc public dynamic var durationText = "";
    @objc public dynamic var type = "isochrone";
    @objc public dynamic var expectedAverageSpeed:Double = -1;

    convenience init(latitude: Double, longitude: Double, radius: Int, dateCaptured: Date, identifier: String, didEnter: Bool, fromPositionDetection: Bool) {
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

public class RegionIsochrones {
    public class func add(regionIsochrone: RegionIsochrone)  {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(regionIsochrone)
            try realm.commitWrite()
        } catch {
        }
    }
    
    public class func updateRegion(id: String, didEnter: Bool, distanceInfo: Distance) -> RegionIsochrone  {
        do {
            if let regionToUpdate = RegionIsochrones.getRegionFromId(id: id){
                let averageSpeed:Double = Double(distanceInfo.distance) / Double(distanceInfo.duration)
                let realm = try Realm()
                realm.beginWrite()
                regionToUpdate.distance = distanceInfo.distance
                regionToUpdate.distanceText = distanceInfo.distanceText ?? ""
                regionToUpdate.duration = distanceInfo.duration
                regionToUpdate.durationText = distanceInfo.durationText ?? ""
                regionToUpdate.didEnter = didEnter
                regionToUpdate.expectedAverageSpeed = averageSpeed
                regionToUpdate.date = Date()
                realm.add(regionToUpdate)
                try realm.commitWrite()
                return regionToUpdate
            }
            
        } catch {
        }
        return RegionIsochrone()
    }
    
    
    public class func getRegionFromId(id: String) -> RegionIsochrone? {
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "identifier == %@", id)
            let fetchedResults = realm.objects(RegionIsochrone.self).filter(predicate)
            if let aRegion = fetchedResults.last {
               return aRegion
            }
        } catch {
        }
        return nil
    }
    
    public class func removeRegionIsochrone(id: String) {
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "identifier == %@", id)
            let fetchedResults = realm.objects(RegionIsochrone.self).filter(predicate)
            if let aRegion = fetchedResults.last {
                try realm.write {
                    realm.delete(aRegion)
                }
            }
        } catch {
        }
    }

    public class func getAll() -> [RegionIsochrone] {
        do {
            let realm = try Realm()
            let regions = realm.objects(RegionIsochrone.self)
            return Array(regions)
        } catch {
        }
        return []
    }

    public class func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(RegionIsochrone.self))
            }
        } catch let error as NSError {
          print(error)
        }
    }
}
