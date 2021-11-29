//
//  TrafficDistance.swift
//  WoosmapGeofencing
//
//

import Foundation
import RealmSwift
import CoreLocation

public class Distance: Object {
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

public class Distances {
    public class func addFromResponseJson(APIResponse: Data, locationId: String, origin: CLLocation, destination: [(Double, Double)]) -> [Distance] {
        do {
            var distanceArray: [Distance] = []
            let jsonStructure = try JSONDecoder().decode(DistanceAPIData.self, from: APIResponse)
            if jsonStructure.status == "OK" {
                for row in jsonStructure.rows! {
                    var indexElement = 0
                    for element in row.elements! {
                        if(element.status == "OK") {
                            let distance = Distance()
                            distance.units = distanceUnits.rawValue
                            distance.date = Date()
                            distance.routing = trafficDistanceRouting.rawValue
                            distance.mode = distanceMode.rawValue
                            distance.originLatitude = origin.coordinate.latitude
                            distance.originLongitude = origin.coordinate.longitude
                            let dest = destination[indexElement]
                            distance.destinationLatitude = dest.0
                            distance.destinationLongitude = dest.1
                            let distanceValue = element.distance?.value
                            let distanceText = element.distance?.text!
                            var durationValue = 0
                            var durationText = ""
                            if(distanceProvider == DistanceProvider.woosmapTraffic) {
                                durationValue = element.duration_with_traffic?.value! ?? 0
                                durationText = element.duration_with_traffic?.text! ?? ""
                            } else {
                                durationValue = element.duration?.value! ?? 0
                                durationText = element.duration?.text! ?? ""
                            }
                            if distanceValue != nil && durationValue != 0 {
                                distance.distance = distanceValue ?? 0
                                distance.distanceText = distanceText
                                distance.duration = durationValue
                                distance.durationText = durationText
                                distanceArray.append(distance)
                            }
                        }
                        indexElement+=1
                    }
                }
            } else {
                print("WoosmapGeofencing.DistanceAPIData " + jsonStructure.status!)
            }
            
            let realm = try Realm()
            realm.beginWrite()
            realm.add(distanceArray)
            try realm.commitWrite()
            return distanceArray
                
        } catch let error as NSError {
            print(error)
        }
        
        return []
    }


    public class func getAll() -> [Distance] {
        do {
            let realm = try Realm()
            let distances = realm.objects(Distance.self)
            return Array(distances)
        } catch {
        }
        return []
    }

    public class func deleteAll() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(Distance.self))
            }
        } catch let error as NSError {
          print(error)
        }
    }
}
