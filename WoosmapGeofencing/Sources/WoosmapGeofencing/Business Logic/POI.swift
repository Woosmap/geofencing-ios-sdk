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
    @objc public dynamic var radius: Double = 0.0
    @objc public dynamic var address: String?
    @objc public dynamic var openNow: Bool = false
    @objc public dynamic var countryCode: String?
    @objc public dynamic var tags: String?
    @objc public dynamic var types: String?
    @objc public dynamic var contact: String?


    convenience public init(locationId: String? = nil, city: String? = nil, zipCode: String? = nil, distance: Double? = nil, latitude: Double? = nil, longitude: Double? = nil, dateCaptured: Date? = nil, radius: Double? = nil, address: String? = nil, tags: String? = nil, types: String? = nil, countryCode: String? = nil, contact: String? = nil) {
        self.init()
        self.locationId = locationId
        self.city = city
        self.zipCode = zipCode
        self.distance = distance!
        self.latitude = latitude!
        self.longitude = longitude!
        self.date = dateCaptured
        self.radius = radius!
        self.address = address
        self.countryCode = countryCode
        self.tags = tags
        self.types = types
        self.contact = contact
    }
}

public class POIs {
    public class func addFromResponseJson(searchAPIResponse: Data, locationId: String) -> [POI] {
        do {
            let jsonStructure = try JSONDecoder().decode(JSONAny.self, from: searchAPIResponse)
            let realm = try Realm()
            var aPOIs: [POI] = []
            if let value = jsonStructure.value as? [String: Any] {
                if let features = value["features"] as? [[String: Any]] {
                    for feature in features {
                        let poi = POI()
                        poi.jsonData = searchAPIResponse
                        poi.locationId = locationId
                        poi.date = Date()
                        
                        if let properties = feature["properties"] as? [String: Any] {
                            poi.idstore = properties["store_id"] as? String ?? ""
                            poi.name = properties["name"] as? String ?? ""
                            poi.distance = properties["distance"] as? Double ?? 0.0
                            if let address = properties["address"] as? [String: Any] {
                                poi.city = address["city"] as? String ?? ""
                                poi.zipCode = address["zipcode"] as? String ?? ""
                                poi.countryCode = address["country_code"] as? String ?? ""
                                if let address = address["lines"] as? [String] {
                                    poi.address = address.joined(separator:" - ")
                                }
                            }
                            
                            if let open = properties["open"] as? [String: Any] {
                                poi.openNow = open["open_now"] as? Bool ?? false
                            }
                            
                            if let contact = properties["contact"] as? [String: String] {
                                for (key, value) in contact {
                                    poi.contact = (poi.contact ?? "") + key + "=" + value + "_"
                                }
                            } else {
                                poi.contact = "null"
                            }
                            
                            //Value by default
                            poi.radius = 300
                            
                            if let radius = poiRadius as? Double {
                                poi.radius = radius
                            } else if let radius = poiRadius as? Int {
                                poi.radius = Double(radius)
                            } else if let radius = poiRadius as? String{
                                if let userProperties = properties["user_properties"] as? [String: Any] {
                                    for (key, value) in userProperties {
                                        if(key == radius) {
                                            poi.radius = Double(value as! Int64)
                                        }
                                    }
                                }
                            }
                            
                            if let tags = properties["tags"] as? [String] {
                                poi.tags = tags.joined(separator:" - ")
                            }
                            if let types = properties["types"] as? [String] {
                                poi.types = types.joined(separator:" - ")
                            }
                            
                        }
                        
                        if let geometry = feature["geometry"] as? [String: Any] {
                            let coord:Array<Double> = geometry["coordinates"] as! Array<Double>
                            poi.latitude = coord[1]
                            poi.longitude = coord[0]
                        }
                        
                        
                        aPOIs.append(poi)
                    }
                }
            }
            
            realm.beginWrite()
            realm.add(aPOIs)
            try realm.commitWrite()
            return aPOIs
        } catch {
        }
        return []
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
    
    public class func getPOIbyIdStore(idstore: String) -> POI? {
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "idstore == %@", idstore)
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
                realm.delete(realm.objects(POI.self))
            }
        } catch let error as NSError {
          print(error)
        }
    }
}
