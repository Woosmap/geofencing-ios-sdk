//
//  ZOI.swift
//  WoosmapGeofencing
//
//

import RealmSwift
import Foundation

public class ZOI: Object {
    @objc public dynamic var accumulator: Double = 0.0
    @objc public dynamic var age: Double = 0.0
    @objc public dynamic var covariance_det: Double = 0.0
    @objc public dynamic var duration: Int64 = 0
    @objc public dynamic var endTime: Date?
    public dynamic var idVisits = List<String>()
    @objc public dynamic var latMean: Double = 0.0
    @objc public dynamic var lngMean: Double = 0.0
    @objc public dynamic var period: String?
    @objc public dynamic var prior_probability: Double = 0.0
    @objc public dynamic var startTime: Date?
    public dynamic var weekly_density = List<Double>()
    @objc public dynamic var wktPolygon: String?
    @objc public dynamic var x00Covariance_matrix_inverse: Double = 0.0
    @objc public dynamic var x01Covariance_matrix_inverse: Double = 0.0
    @objc public dynamic var x10Covariance_matrix_inverse: Double = 0.0
    @objc public dynamic var x11Covariance_matrix_inverse: Double = 0.0
    @objc public dynamic var zoiId: String?

    public override class func primaryKey() -> String? {
            return "zoiId"
        }
}

public class ZOIs {
    public class func createZOIFrom(zoi: [String: Any]) {
        do {
            let realm = try Realm()
            let newZOI = ZOI()
            newZOI.zoiId = UUID().uuidString
            newZOI.idVisits = zoi["idVisits"] as! List<String>
            var visitArrivalDate = [Date]()
            var visitDepartureDate = [Date]()
            var duration = 0
            var startTime = Date()
            var endTime = Date()
            if !(zoi["idVisits"] as! [String]).isEmpty {
                for id in zoi["idVisits"] as! [String] {
                    let visit = Visits.getVisitFromUUID(id: id)
                    if visit != nil {
                        visitArrivalDate.append(visit!.arrivalDate!)
                        visitDepartureDate.append(visit!.departureDate!)
                        duration += visit!.departureDate!.seconds(from: visit!.arrivalDate!)
                    }
                }
                startTime = visitArrivalDate.reduce(visitArrivalDate[0], { $0.timeIntervalSince1970 < $1.timeIntervalSince1970 ? $0 : $1 })
                endTime = visitDepartureDate.reduce(visitDepartureDate[0], { $0.timeIntervalSince1970 > $1.timeIntervalSince1970 ? $0 : $1 })
            }
            newZOI.setValue(startTime, forKey: "startTime")
            newZOI.setValue(endTime, forKey: "endTime")
            newZOI.setValue(duration, forKey: "duration")
            newZOI.setValue(zoi["weekly_density"], forKey: "weekly_density")
            newZOI.setValue(zoi["period"], forKey: "period")
            newZOI.setValue((zoi["mean"] as! [Any])[0] as! Double, forKey: "latMean")
            newZOI.setValue((zoi["mean"] as! [Any])[1] as! Double, forKey: "lngMean")
            newZOI.setValue(zoi["age"], forKey: "age")
            newZOI.setValue(zoi["accumulator"], forKey: "accumulator")
            newZOI.setValue(zoi["covariance_det"], forKey: "covariance_det")
            newZOI.setValue(zoi["prior_probability"], forKey: "prior_probability")
            newZOI.setValue(zoi["x00Covariance_matrix_inverse"], forKey: "x00Covariance_matrix_inverse")
            newZOI.setValue(zoi["x01Covariance_matrix_inverse"], forKey: "x01Covariance_matrix_inverse")
            newZOI.setValue(zoi["x10Covariance_matrix_inverse"], forKey: "x10Covariance_matrix_inverse")
            newZOI.setValue(zoi["x11Covariance_matrix_inverse"], forKey: "x11Covariance_matrix_inverse")
            newZOI.setValue(zoi["WktPolygon"], forKey: "wktPolygon")

            realm.beginWrite()
            realm.add(newZOI)
            try realm.commitWrite()
        } catch {
        }
    }

    public class func saveZoisInDB(zois: [[String: Any]]) {
        var zoisToDB: [ZOI] = []
        for zoi in zois {
            let newZOi = ZOI()
            newZOi.setValue(UUID().uuidString, forKey: "zoiId")
            newZOi.setValue(zoi["idVisits"], forKey: "idVisits")
            var visitArrivalDate = [Date]()
            var visitDepartureDate = [Date]()
            var duration = 0
            var startTime = Date()
            var endTime = Date()
            var arrayIdVisits: [String] = [String]()
            if let list = zoi["idVisits"] as? [String] {
                arrayIdVisits = list
            } else {
                arrayIdVisits = Array((zoi["idVisits"] as! List<String>).elements)
            }
            if arrayIdVisits.count != 0 {
                for id in arrayIdVisits {
                    let visit = Visits.getVisitFromUUID(id: id)
                    if visit != nil {
                        visitArrivalDate.append(visit!.arrivalDate!)
                        visitDepartureDate.append(visit!.departureDate!)
                        duration += visit!.departureDate!.seconds(from: visit!.arrivalDate!)
                    }
                }
                startTime = visitArrivalDate.reduce(visitArrivalDate[0], { $0.timeIntervalSince1970 < $1.timeIntervalSince1970 ? $0 : $1 })
                endTime = visitDepartureDate.reduce(visitDepartureDate[0], { $0.timeIntervalSince1970 > $1.timeIntervalSince1970 ? $0 : $1 })
            }
            newZOi.setValue(startTime, forKey: "startTime")
            newZOi.setValue(endTime, forKey: "endTime")
            newZOi.setValue(duration, forKey: "duration")
            newZOi.setValue(zoi["weekly_density"], forKey: "weekly_density")
            newZOi.setValue(zoi["period"], forKey: "period")
            newZOi.setValue((zoi["mean"] as! [Any])[0] as! Double, forKey: "latMean")
            newZOi.setValue((zoi["mean"] as! [Any])[1] as! Double, forKey: "lngMean")
            newZOi.setValue(zoi["age"], forKey: "age")
            newZOi.setValue(zoi["accumulator"], forKey: "accumulator")
            newZOi.setValue(zoi["covariance_det"], forKey: "covariance_det")
            newZOi.setValue(zoi["prior_probability"], forKey: "prior_probability")
            newZOi.setValue(zoi["x00Covariance_matrix_inverse"], forKey: "x00Covariance_matrix_inverse")
            newZOi.setValue(zoi["x01Covariance_matrix_inverse"], forKey: "x01Covariance_matrix_inverse")
            newZOi.setValue(zoi["x10Covariance_matrix_inverse"], forKey: "x10Covariance_matrix_inverse")
            newZOi.setValue(zoi["x11Covariance_matrix_inverse"], forKey: "x11Covariance_matrix_inverse")
            newZOi.setValue(zoi["WktPolygon"], forKey: "wktPolygon")
            zoisToDB.append(newZOi)
        }

        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.delete(realm.objects(ZOI.self))
            realm.add(zoisToDB)
            try realm.commitWrite()
        } catch {
        }
    }

    public class func createZOIFromVisit(visit: Visit) {
        let sMercator = SphericalMercator()
        var zoisFromDB: [[String: Any]] = []

        for zoiFromDB in ZOIs.getAll() {
            var zoiToAdd = [String: Any]()
            zoiToAdd["prior_probability"] = zoiFromDB.prior_probability
            zoiToAdd["mean"] = [zoiFromDB.latMean, zoiFromDB.lngMean]
            zoiToAdd["age"] = zoiFromDB.age
            zoiToAdd["accumulator"] = zoiFromDB.accumulator
            zoiToAdd["idVisits"] = zoiFromDB.idVisits
            var listVisit: [LoadedVisit] = []
            for id in zoiFromDB.idVisits {
                let visitFromId = Visits.getVisitFromUUID(id: id)
                if visitFromId != nil {
                    let point: LoadedVisit = LoadedVisit(x: visitFromId!.latitude, y: visitFromId!.longitude, accuracy: visitFromId!.accuracy, id: visitFromId!.visitId!, startTime: visitFromId!.arrivalDate!, endTime: visitFromId!.departureDate!)
                    listVisit.append(point)
                }
            }
            zoiToAdd["visitPoint"] = listVisit
            zoiToAdd["startTime"] = zoiFromDB.startTime
            zoiToAdd["endTime"] = zoiFromDB.endTime
            zoiToAdd["duration"] = zoiFromDB.duration
            zoiToAdd["weekly_density"] = zoiFromDB.weekly_density
            zoiToAdd["weeks_on_zoi"] = []
            zoiToAdd["period"] = zoiFromDB.period
            zoiToAdd["covariance_det"] = zoiFromDB.covariance_det
            zoiToAdd["x00Covariance_matrix_inverse"] = zoiFromDB.x00Covariance_matrix_inverse
            zoiToAdd["x01Covariance_matrix_inverse"] = zoiFromDB.x01Covariance_matrix_inverse
            zoiToAdd["x10Covariance_matrix_inverse"] = zoiFromDB.x10Covariance_matrix_inverse
            zoiToAdd["x11Covariance_matrix_inverse"] = zoiFromDB.x11Covariance_matrix_inverse
            zoisFromDB.append(zoiToAdd)

        }

        setListZOIsFromDB(zoiFromDB: zoisFromDB)

        let list_zoi = figmmForVisit(newVisitPoint: LoadedVisit(x: sMercator.lon2x(aLong: visit.longitude), y: sMercator.lat2y(aLat: visit.latitude), accuracy: visit.accuracy, id: visit.visitId!, startTime: visit.arrivalDate!, endTime: visit.departureDate!))

        saveZoisInDB(zois: list_zoi)
    }

    public class func createZOIFromLocation(visit: Location) {
        let sMercator = SphericalMercator()
        var zoisFromDB: [[String: Any]] = []
        for zoiFromDB in ZOIs.getAll() {
            var zoiToAdd = [String: Any]()
            zoiToAdd["prior_probability"] = zoiFromDB.prior_probability
            zoiToAdd["mean"] = [zoiFromDB.latMean, zoiFromDB.lngMean]
            zoiToAdd["age"] = zoiFromDB.age
            zoiToAdd["accumulator"] = zoiFromDB.accumulator
            zoiToAdd["idVisits"] = zoiFromDB.idVisits
            var listVisit: [LoadedVisit] = []
            for id in zoiFromDB.idVisits {
                let visit = Visits.getVisitFromUUID(id: id)
                if visit != nil {
                    let point: LoadedVisit = LoadedVisit(x: visit!.latitude, y: visit!.longitude, accuracy: visit!.accuracy, id: visit!.visitId!, startTime: visit!.arrivalDate!, endTime: visit!.departureDate!)
                    listVisit.append(point)
                }
            }
            zoiToAdd["startTime"] = zoiFromDB.startTime
            zoiToAdd["endTime"] = zoiFromDB.endTime
            zoiToAdd["duration"] = zoiFromDB.duration
            zoiToAdd["weekly_density"] = zoiFromDB.weekly_density
            zoiToAdd["period"] = zoiFromDB.period
            zoiToAdd["weeks_on_zoi"] = []
            zoiToAdd["covariance_det"] = zoiFromDB.covariance_det
            zoiToAdd["x00Covariance_matrix_inverse"] = zoiFromDB.x00Covariance_matrix_inverse
            zoiToAdd["x01Covariance_matrix_inverse"] = zoiFromDB.x01Covariance_matrix_inverse
            zoiToAdd["x10Covariance_matrix_inverse"] = zoiFromDB.x10Covariance_matrix_inverse
            zoiToAdd["x11Covariance_matrix_inverse"] = zoiFromDB.x11Covariance_matrix_inverse
            zoisFromDB.append(zoiToAdd)

        }

        setListZOIsFromDB(zoiFromDB: zoisFromDB)

        let list_zoi = figmmForVisit(newVisitPoint: LoadedVisit(x: sMercator.lon2x(aLong: visit.longitude), y: sMercator.lat2y(aLat: visit.latitude), accuracy: 20.0, id: visit.locationId!, startTime: Date(), endTime: Date().addingTimeInterval(100)))

        ZOIs.deleteAll()

        for zoi in list_zoi {
            createZOIFrom(zoi: zoi)
        }

    }

    public class func updateZOI(visits: [Visit]) {
        let sMercator = SphericalMercator()
        var zoisFromDB: [[String: Any]] = []

        for zoiFromDB in ZOIs.getAll() {
            var zoiToAdd = [String: Any]()
            zoiToAdd["prior_probability"] = zoiFromDB.prior_probability
            zoiToAdd["mean"] = [zoiFromDB.latMean, zoiFromDB.lngMean]
            zoiToAdd["age"] = zoiFromDB.age
            zoiToAdd["accumulator"] = zoiFromDB.accumulator
            zoiToAdd["idVisits"] = zoiFromDB.idVisits
            var listVisit: [LoadedVisit] = []
            for id in zoiFromDB.idVisits {
                let visitFromId = Visits.getVisitFromUUID(id: id)
                if visitFromId != nil {
                    let point: LoadedVisit = LoadedVisit(x: visitFromId!.latitude, y: visitFromId!.longitude, accuracy: visitFromId!.accuracy, id: visitFromId!.visitId!, startTime: visitFromId!.arrivalDate!, endTime: visitFromId!.departureDate!)
                    listVisit.append(point)
                }
            }
            zoiToAdd["visitPoint"] = listVisit
            zoiToAdd["startTime"] = zoiFromDB.startTime
            zoiToAdd["endTime"] = zoiFromDB.endTime
            zoiToAdd["duration"] = zoiFromDB.duration
            zoiToAdd["weekly_density"] = zoiFromDB.weekly_density
            zoiToAdd["weeks_on_zoi"] = []
            zoiToAdd["period"] = zoiFromDB.period
            zoiToAdd["covariance_det"] = zoiFromDB.covariance_det
            zoiToAdd["x00Covariance_matrix_inverse"] = zoiFromDB.x00Covariance_matrix_inverse
            zoiToAdd["x01Covariance_matrix_inverse"] = zoiFromDB.x01Covariance_matrix_inverse
            zoiToAdd["x10Covariance_matrix_inverse"] = zoiFromDB.x10Covariance_matrix_inverse
            zoiToAdd["x11Covariance_matrix_inverse"] = zoiFromDB.x11Covariance_matrix_inverse
            zoisFromDB.append(zoiToAdd)
        }

        setListZOIsFromDB(zoiFromDB: zoisFromDB)

        var list_zoi: [[String: Any]] = []
        for visit in visits {
            list_zoi = deleteVisitOnZoi(visitsToDelete: LoadedVisit(x: sMercator.lon2x(aLong: visit.longitude), y: sMercator.lat2y(aLat: visit.latitude), accuracy: visit.accuracy, id: visit.visitId!, startTime: visit.arrivalDate!, endTime: visit.departureDate!))
        }

        ZOIs.saveZoisInDB(zois: list_zoi)
    }

    public class func getAll() -> [ZOI] {
        do {
            let realm = try Realm()
            let zois = realm.objects(ZOI.self)
            return Array(zois)
        } catch {
        }
        return []
    }

    public class func deleteAll() {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.delete(realm.objects(ZOI.self))
            try realm.commitWrite()
        } catch {
        }
    }
}
