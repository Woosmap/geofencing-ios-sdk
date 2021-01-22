//
//  DataCleaner.swift
//  WoosmapGeofencing
//  Copyright © 2021 Web Geo Services. All rights reserved.
//

import Foundation
import RealmSwift

public class DataCleaner {
    
    public init() {}
    
    public func cleanOldGeographicData() {
        let lastDateUpdate = UserDefaults.standard.object(forKey: "lastDateUpdate") as? Date
        
        if (lastDateUpdate != nil) {
            let dateComponents = Calendar.current.dateComponents([.day], from: lastDateUpdate!, to: Date())
            //update date if no updating since 1 day
            if (dateComponents.day! >= 1) {
                //Cleanning database
                do {
                    let realm = try Realm()
                    let limitDate = Calendar.current.date(byAdding: .day, value: -dataDurationDelay, to: Date())
                    let predicate = NSPredicate(format: "(date <= %@)", limitDate! as CVarArg)
                    let locationFetchedResults = realm.objects(Location.self).filter(predicate)
                    let poiFetchedResults = realm.objects(POI.self).filter(predicate)
                    let visitFetchedResults = realm.objects(Visit.self).filter(predicate)
                    if(!visitFetchedResults.isEmpty) {
                        ZOIs.updateZOI(visits: Array(visitFetchedResults))
                    }
                    realm.beginWrite()
                    realm.delete(locationFetchedResults)
                    realm.delete(poiFetchedResults)
                    realm.delete(visitFetchedResults)
                    try realm.commitWrite()
                } catch {
                }
            }
        }
        //Update date
        UserDefaults.standard.set(Date(), forKey:"lastDateUpdate")
    }
    
    func removeLocationOlderThan(days: Int) {
        do {
            let realm = try Realm()
            let limitDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())
            let predicate = NSPredicate(format: "(date <= %@)", limitDate! as CVarArg)
            let fetchedResults = realm.objects(Location.self).filter(predicate)
            try! realm.write {
                realm.delete(fetchedResults)
            }
        } catch {
        }
    }

   func removePOIOlderThan(days: Int) {
        do {
            let realm = try Realm()
            let limitDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())
            let predicate = NSPredicate(format: "(date <= %@)", limitDate! as CVarArg)
            let fetchedResults = realm.objects(POI.self).filter(predicate)
            try! realm.write {
                realm.delete(fetchedResults)
            }
        } catch {
        }
    }

   func removeVisitOlderThan(days: Int) {
       do {
            let realm = try Realm()
            let limitDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())
            let predicate = NSPredicate(format: "(date <= %@)", limitDate! as CVarArg)
            let fetchedResults = realm.objects(Visit.self).filter(predicate)
            try! realm.write {
                if(!fetchedResults.isEmpty) {
                    ZOIs.updateZOI(visits: Array(fetchedResults))
                }
                realm.delete(fetchedResults)
            }
        } catch {
        }
    }
}


