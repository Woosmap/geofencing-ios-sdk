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
                removePOIOlderThan(days: dataDurationDelay)
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
    
    func removePOIOlderThan(days: Int) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let limitDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "POI")

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
                DataZOI().updateZOI(visits: visits)
            }
            try context.execute(deleteRequest)
            try context.save()
        } catch {
          print (error)
        }
    }
}

extension Notification.Name {
    static let reloadData = Notification.Name("reloadData")
}

