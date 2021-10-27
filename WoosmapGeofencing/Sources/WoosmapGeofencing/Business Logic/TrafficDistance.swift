//
//  TrafficDistance.swift
//  WoosmapGeofencing
//
//

import Foundation
import RealmSwift
import CoreLocation

public class TrafficDistance: Object {
    @objc public dynamic var date: Date?
    @objc public dynamic var originLatitude: Double = 0.0
    @objc public dynamic var originLongitude: Double = 0.0
    @objc public dynamic var destinationLatitude: Double = 0.0
    @objc public dynamic var destinationLongitude: Double = 0.0
    @objc public dynamic var distance: Int = 0
    @objc public dynamic var distanceText: String?
    @objc public dynamic var duration: Int = 0
    @objc public dynamic var durationText: String?
    @objc public dynamic var mode: String?
    @objc public dynamic var units: String?
    @objc public dynamic var routing: String?


    convenience public init(originLatitude: Double, originLongitude: Double, destinationLatitude: Double, destinationLongitude: Double,dateCaptured: Date, distance: Int, duration: Int, mode: String, units: String, routing: String) {
        self.init()
        self.originLatitude = originLatitude
        self.originLongitude = originLongitude
        self.destinationLatitude = destinationLatitude
        self.destinationLongitude = destinationLongitude
        self.date = dateCaptured
        self.distance = distance
        self.duration = duration
        self.mode = mode
        self.units = units
        self.routing = routing
    }

}

public class TrafficDistances {
    public class func addFromResponseJson(APIResponse: Data, locationId: String, origin: CLLocation, destination: CLLocation) -> TrafficDistance {
        do {
            let trafficDistance = TrafficDistance()
            trafficDistance.units = distanceUnits.rawValue
            trafficDistance.date = Date()
            trafficDistance.routing = trafficDistanceRouting.rawValue
            trafficDistance.mode = distanceMode.rawValue
            trafficDistance.originLatitude = origin.coordinate.latitude
            trafficDistance.originLongitude = origin.coordinate.longitude
            trafficDistance.destinationLatitude = destination.coordinate.latitude
            trafficDistance.destinationLongitude = destination.coordinate.longitude
            if(distanceProvider == DistanceProvider.WoosmapTraffic) {
                let jsonStructure = try JSONDecoder().decode(TrafficDistanceAPIData.self, from: APIResponse)
                if jsonStructure.status == "OK" {
                    if jsonStructure.rows?.first?.elements?.first?.status == "OK" {
                        let distance = jsonStructure.rows?.first?.elements?.first?.distance?.value!
                        let distanceText = jsonStructure.rows?.first?.elements?.first?.distance?.text!
                        let duration = jsonStructure.rows?.first?.elements?.first?.duration_with_traffic?.value!
                        let durationText = jsonStructure.rows?.first?.elements?.first?.duration_with_traffic?.text!
                        if distance != nil && duration != nil {
                            trafficDistance.distance = distance ?? 0
                            trafficDistance.distanceText = distanceText
                            trafficDistance.duration = duration ?? 0
                            trafficDistance.durationText = durationText
                        }
                    }
                } else {
                    print("WoosmapGeofencing.TrafficDistanceAPIData " + jsonStructure.status!)
                }
            } else {
                let responseJSON = try JSONDecoder().decode(DistanceAPIData.self, from: APIResponse)
                if responseJSON.status == "OK" {
                    if responseJSON.rows?.first?.elements?.first?.status == "OK" {
                        let distance = responseJSON.rows?.first?.elements?.first?.distance?.value!
                        let distanceText = responseJSON.rows?.first?.elements?.first?.distance?.text!
                        let duration = responseJSON.rows?.first?.elements?.first?.duration?.value!
                        let durationText = responseJSON.rows?.first?.elements?.first?.duration?.text!
                        if distance != nil && duration != nil {
                            trafficDistance.distance = distance ?? 0
                            trafficDistance.distanceText = distanceText
                            trafficDistance.duration = duration ?? 0
                            trafficDistance.durationText = durationText
                        }
                    }
                } else {
                    print("WoosmapGeofencing.DistanceAPIData " + responseJSON.status!)
                }
            }
            let realm = try Realm()
            realm.beginWrite()
            realm.add(trafficDistance)
            try realm.commitWrite()
            return trafficDistance
                
        } catch let error as NSError {
            print(error)
        }
        
        return TrafficDistance()
    }


    public class func getAll() -> [TrafficDistance] {
        do {
            let realm = try Realm()
            let trafficDistances = realm.objects(TrafficDistance.self)
            return Array(trafficDistances)
        } catch {
        }
        return []
    }

    public class func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(TrafficDistance.self))
            }
        } catch let error as NSError {
          print(error)
        }
    }
}
