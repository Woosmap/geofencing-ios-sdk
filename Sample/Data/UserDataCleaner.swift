//
//  UserDataCleaner.swift
//  Sample
//
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import WoosmapGeofencing

public class UserDataCleaner {
    
    public init() {}
    
    public func cleanOldGeographicData() {
        let lastDateUpdate = UserDefaults.standard.object(forKey: "lastDateUpdate") as? Date
        
        if (lastDateUpdate != nil) {
            let dateComponents = Calendar.current.dateComponents([.day], from: lastDateUpdate!, to: Date())
            //update date if no updating since 1 day
            if (dateComponents.day! >= 1) {
                //Cleanning database
                removeLocationOlderThan(days: dataDurationDelay)
                removeVisitOlderThan(days: dataDurationDelay)
                NotificationCenter.default.post(name: .reloadData, object: self)
            }
        }
        //Update date
        UserDefaults.standard.set(Date(), forKey:"lastDateUpdate")
    }
    
    func removeLocationOlderThan(days: Int) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let limitDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")

        fetchRequest.predicate = NSPredicate(format: "(date <= %@)", limitDate! as CVarArg)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
          print (error)
        }
    }
    
    func removeVisitOlderThan(days: Int) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let limitDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Visit")

        fetchRequest.predicate = NSPredicate(format: "(date <= %@)", limitDate! as CVarArg)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            var visits:[Visit] = []
            visits = try (context.fetch(fetchRequest) as? [Visit])!
            if(!visits.isEmpty) {
                updateZOI(visits: visits)
            }
            try context.execute(deleteRequest)
            try context.save()
        } catch {
          print (error)
        }
    }
    
    func updateZOI(visits : [Visit]) {
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
            list_zoi = deleteVisitOnZoi(visitToDelete: LoadedVisit(x: sMercator.lon2x(aLong: visit.longitude), y: sMercator.lat2y(aLat:visit.latitude),accuracy: visit.accuracy, id:visit.visitId!, startTime: visit.arrivalDate!, endTime: visit.departureDate!))
        }
        
        DataZOI().eraseZOIs()
        DataZOI().saveZoisInDB(zois: list_zoi)
    }
}

extension Notification.Name {
    static let reloadData = Notification.Name("reloadData")
}

