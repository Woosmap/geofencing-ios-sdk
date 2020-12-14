//
//  DataDistance.swift
//  Sample
//
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import WoosmapGeofencing

public class DataDistance:DistanceAPIDelegate  {
    public func distanceAPIResponseData(distanceAPIData: DistanceAPIData, locationId: String) {
        if (distanceAPIData.status == "OK") {
            let distance = distanceAPIData.rows?.first?.elements?.first?.distance?.value!
            let duration = distanceAPIData.rows?.first?.elements?.first?.duration?.text!
            if(distance != nil && duration != nil) {
                updatePOIWithDistance(distance: Double(distance!), duration: duration!, locationId: locationId)
            }
        }
    }
    
    
    public func distanceAPIError(error: String) {
        print(error)
    }
    
    func updatePOIWithDistance(distance: Double, duration: String, locationId: String) {
        DispatchQueue.main.async {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            do {
                let fetchRequest = NSFetchRequest<POI>(entityName: "POI")
                fetchRequest.predicate = NSPredicate(format: "locationId == %@", locationId)
                let fetchedResults = try context.fetch(fetchRequest)
                if let aPOI = fetchedResults.first {
                    aPOI.setValue(distance, forKey: "distance")
                    aPOI.setValue(duration, forKey: "duration")
                }
                do {
                    try context.save()
                }
            }
            catch {
                print ("fetch task failed", error)
            }
            NotificationCenter.default.post(name: .newPOISaved, object: self)
        }
        
    }
    
    
}
