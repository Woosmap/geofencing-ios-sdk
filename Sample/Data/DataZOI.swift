//
//  DataZOI.swift
//  Sample
//
//  Created by Mac de Laurent on 26/05/2020.
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import WoosmapGeofencing

public class DataZOI {
    public init() {}
    
    public func readZOIs()-> [ZOI] {
        var zois: [ZOI] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<ZOI>(entityName: "ZOI")
        do {
            zois = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return zois
    }
    
    func createZOIFrom(zoi: Dictionary<String, Any>) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ZOI", in: context)!
        let newZOi = ZOI(entity: entity, insertInto: context)
        newZOi.setValue(UUID().uuidString, forKey: "zoiId")
        newZOi.setValue(zoi["idVisits"], forKey: "idVisits")
        
        var visitArrivalDate = [Date]()
        var visitDepartureDate = [Date]()
        var duration = 0
        var startTime = Date()
        var endTime = Date()
        if(!(zoi["idVisits"] as! [String]).isEmpty){
            for id in zoi["idVisits"] as! [String] {
                let visit = DataVisit().getVisitFromUUID(id: id)
                if (visit != nil) {
                    visitArrivalDate.append(visit!.arrivalDate!)
                    visitDepartureDate.append(visit!.departureDate!)
                    duration += visit!.departureDate!.seconds(from: visit!.arrivalDate!)
                }
            }
            startTime = visitArrivalDate.reduce(visitArrivalDate[0], { $0.timeIntervalSince1970 < $1.timeIntervalSince1970 ? $0 : $1 } )
            endTime = visitDepartureDate.reduce(visitDepartureDate[0], { $0.timeIntervalSince1970 > $1.timeIntervalSince1970 ? $0 : $1 } )
        }
        newZOi.setValue(startTime , forKey: "startTime")
        newZOi.setValue(endTime, forKey: "endTime")
        newZOi.setValue(duration, forKey: "duration")
        newZOi.setValue(zoi["weekly_density"], forKey: "weekly_density")
        newZOi.setValue(zoi["period"], forKey: "period")
        newZOi.setValue((zoi["mean"] as! Array<Any>)[0] as! Double, forKey: "latMean")
        newZOi.setValue((zoi["mean"] as! Array<Any>)[1] as! Double, forKey: "lngMean")
        newZOi.setValue(zoi["age"] , forKey: "age")
        newZOi.setValue(zoi["accumulator"] , forKey: "accumulator")
        newZOi.setValue(zoi["covariance_det"] , forKey: "covariance_det")
        newZOi.setValue(zoi["prior_probability"] , forKey: "prior_probability")
        newZOi.setValue(zoi["x00Covariance_matrix_inverse"], forKey: "x00Covariance_matrix_inverse")
        newZOi.setValue(zoi["x01Covariance_matrix_inverse"], forKey: "x01Covariance_matrix_inverse")
        newZOi.setValue(zoi["x10Covariance_matrix_inverse"], forKey: "x10Covariance_matrix_inverse")
        newZOi.setValue(zoi["x11Covariance_matrix_inverse"], forKey: "x11Covariance_matrix_inverse")
        newZOi.setValue(zoi["WktPolygon"], forKey: "wktPolygon")
        
        do {
            try context.save()
        }
        catch let error as NSError {
            print("Could not insert. \(error), \(error.userInfo)")
        }
        
    }
    
    func saveZoisInDB(zois: [Dictionary<String, Any>]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ZOI", in: context)!
        for zoi in zois {
            let newZOi = ZOI(entity: entity, insertInto: context)
            newZOi.setValue(UUID().uuidString, forKey: "zoiId")
            newZOi.setValue(zoi["idVisits"], forKey: "idVisits")
            
            var visitArrivalDate = [Date]()
            var visitDepartureDate = [Date]()
            var duration = 0
            var startTime = Date()
            var endTime = Date()
            if(!(zoi["idVisits"] as! [String]).isEmpty){
                for id in zoi["idVisits"] as! [String] {
                    let visit = DataVisit().getVisitFromUUID(id: id)
                    if (visit != nil) {
                        visitArrivalDate.append(visit!.arrivalDate!)
                        visitDepartureDate.append(visit!.departureDate!)
                        duration += visit!.departureDate!.seconds(from: visit!.arrivalDate!)
                    }
                }
                startTime = visitArrivalDate.reduce(visitArrivalDate[0], { $0.timeIntervalSince1970 < $1.timeIntervalSince1970 ? $0 : $1 } )
                endTime = visitDepartureDate.reduce(visitDepartureDate[0], { $0.timeIntervalSince1970 > $1.timeIntervalSince1970 ? $0 : $1 } )
            }
            newZOi.setValue(startTime , forKey: "startTime")
            newZOi.setValue(endTime, forKey: "endTime")
            newZOi.setValue(duration, forKey: "duration")
            newZOi.setValue(zoi["weekly_density"], forKey: "weekly_density")
            newZOi.setValue(zoi["period"], forKey: "period")
            newZOi.setValue((zoi["mean"] as! Array<Any>)[0] as! Double, forKey: "latMean")
            newZOi.setValue((zoi["mean"] as! Array<Any>)[1] as! Double, forKey: "lngMean")
            newZOi.setValue(zoi["age"] , forKey: "age")
            newZOi.setValue(zoi["accumulator"] , forKey: "accumulator")
            newZOi.setValue(zoi["covariance_det"] , forKey: "covariance_det")
            newZOi.setValue(zoi["prior_probability"] , forKey: "prior_probability")
            newZOi.setValue(zoi["x00Covariance_matrix_inverse"], forKey: "x00Covariance_matrix_inverse")
            newZOi.setValue(zoi["x01Covariance_matrix_inverse"], forKey: "x01Covariance_matrix_inverse")
            newZOi.setValue(zoi["x10Covariance_matrix_inverse"], forKey: "x10Covariance_matrix_inverse")
            newZOi.setValue(zoi["x11Covariance_matrix_inverse"], forKey: "x11Covariance_matrix_inverse")
            newZOi.setValue(zoi["WktPolygon"], forKey: "wktPolygon")
        }
        do {
            try context.save()
        }
        catch let error as NSError {
            print("Could not insert. \(error), \(error.userInfo)")
        }
    }
    
    func createZOIFromVisit(visit : Visit) {
        let sMercator = SphericalMercator()
        var zoisFromDB: [Dictionary<String, Any>] = []
        
        for zoiFromDB in readZOIs(){
            var zoiToAdd = Dictionary<String, Any>()
            zoiToAdd["prior_probability"] = zoiFromDB.prior_probability
            zoiToAdd["mean"] = [zoiFromDB.latMean, zoiFromDB.lngMean]
            zoiToAdd["age"] = zoiFromDB.age
            zoiToAdd["accumulator"] = zoiFromDB.accumulator
            zoiToAdd["idVisits"] = zoiFromDB.idVisits
            var listVisit:[LoadedVisit] = []
            for id in zoiFromDB.idVisits! {
                let visitFromId = DataVisit().getVisitFromUUID(id: id)
                if (visitFromId != nil) {
                    let point:LoadedVisit = LoadedVisit(x: visitFromId!.latitude, y: visitFromId!.longitude, accuracy: visitFromId!.accuracy, id: visitFromId!.visitId!, startTime: visitFromId!.arrivalDate!, endTime: visitFromId!.departureDate!)
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
        
        let list_zoi = figmmForVisit(newVisitPoint: LoadedVisit(x: sMercator.lon2x(aLong: visit.longitude), y: sMercator.lat2y(aLat:visit.latitude),accuracy: visit.accuracy, id:visit.visitId!, startTime: visit.arrivalDate!, endTime: visit.departureDate!))

        eraseZOIs()
        saveZoisInDB(zois: list_zoi)
    }
    
    func createZOIFromLocation(visit : Location) {
        
        let sMercator = SphericalMercator()
        var zoisFromDB: [Dictionary<String, Any>] = []
        for zoiFromDB in readZOIs(){
            var zoiToAdd = Dictionary<String, Any>()
            zoiToAdd["prior_probability"] = zoiFromDB.prior_probability
            zoiToAdd["mean"] = [zoiFromDB.latMean, zoiFromDB.lngMean]
            zoiToAdd["age"] = zoiFromDB.age
            zoiToAdd["accumulator"] = zoiFromDB.accumulator
            zoiToAdd["idVisits"] = zoiFromDB.idVisits
            var listVisit:[LoadedVisit] = []
            for id in zoiFromDB.idVisits! {
                let visit = DataVisit().getVisitFromUUID(id: id)
                if (visit != nil) {
                    let point:LoadedVisit = LoadedVisit(x: visit!.latitude, y: visit!.longitude, accuracy: visit!.accuracy, id: visit!.visitId!, startTime: visit!.arrivalDate!, endTime: visit!.departureDate!)
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
        
        let list_zoi = figmmForVisit(newVisitPoint: LoadedVisit(x: sMercator.lon2x(aLong: visit.longitude), y: sMercator.lat2y(aLat:visit.latitude),accuracy: 20.0, id:visit.locationId!, startTime: Date(), endTime: Date().addingTimeInterval(100)))
        
        eraseZOIs()
        
        for zoi in list_zoi{
            createZOIFrom(zoi: zoi)
        }
        
    }
    
    public func updateZOI(visits : [Visit]) {
        let sMercator = SphericalMercator()
        var zoisFromDB: [Dictionary<String, Any>] = []
        
        for zoiFromDB in DataZOI().readZOIs() {
            var zoiToAdd = Dictionary<String, Any>()
            zoiToAdd["prior_probability"] = zoiFromDB.prior_probability
            zoiToAdd["mean"] = [zoiFromDB.latMean, zoiFromDB.lngMean]
            zoiToAdd["age"] = zoiFromDB.age
            zoiToAdd["accumulator"] = zoiFromDB.accumulator
            zoiToAdd["idVisits"] = zoiFromDB.idVisits
            var listVisit:[LoadedVisit] = []
            for id in zoiFromDB.idVisits! {
                let visitFromId = DataVisit().getVisitFromUUID(id: id)
                if (visitFromId != nil) {
                    let point:LoadedVisit = LoadedVisit(x: visitFromId!.latitude, y: visitFromId!.longitude, accuracy: visitFromId!.accuracy, id: visitFromId!.visitId!, startTime: visitFromId!.arrivalDate!, endTime: visitFromId!.departureDate!)
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
        
        var list_zoi:[Dictionary<String, Any>] = []
        for visit in visits{
            list_zoi = deleteVisitOnZoi(visitsToDelete: LoadedVisit(x: sMercator.lon2x(aLong: visit.longitude), y: sMercator.lat2y(aLat:visit.latitude),accuracy: visit.accuracy, id:visit.visitId!, startTime: visit.arrivalDate!, endTime: visit.departureDate!))
        }
        
        DataZOI().eraseZOIs()
        DataZOI().saveZoisInDB(zois: list_zoi)
    }
    
    public func eraseZOIs() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ZOI")
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in ZOI error : \(error) \(error.userInfo)")
        }
    }
}
