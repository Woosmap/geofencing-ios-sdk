//
//  DataSearchAPI.swift
//  WoosmapGeofencing
//
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import WoosmapGeofencing

class DataPOI:SearchAPIDelegate  {
    func searchAPIResponseData(searchAPIData: SearchAPIData, locationId: UUID) {
        for feature in (searchAPIData.features)! {
            let city = feature.properties!.address!.city!
            let zipCode = feature.properties!.address!.zipcode!
            let distance = feature.properties!.distance!
            let latitude = (feature.geometry?.coordinates![1])!
            let longitude = (feature.geometry?.coordinates![0])!
            let dateCaptured = Date()
            let POIToSave = POIModel(locationId: locationId,city: city,zipCode: zipCode,distance: distance,latitude: latitude, longitude: longitude,dateCaptured: dateCaptured)
            createPOI(POImodel: POIToSave)
        }
    }
    func serachAPIError(error: String) {
        
    }
    
    func readPOI()-> Array<POI> {
        var searchAPIData = [POI]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<POI>(entityName: "POI")
        
        do {
            searchAPIData = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return searchAPIData
    }
    
    func getPOIbyLocationID(locationId: UUID)-> POI? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        do {
            let fetchRequest = NSFetchRequest<POI>(entityName: "POI")
            fetchRequest.predicate = NSPredicate(format: "locationId == %@", locationId.uuidString)
            let fetchedResults = try context.fetch(fetchRequest)
            if let aPOI = fetchedResults.first {
               return aPOI
            }
        }
        catch {
            print ("fetch task failed", error)
        }
        
        return nil

    }
    
    func createPOI(POImodel: POIModel) {
        DispatchQueue.main.async(execute: {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "POI", in: managedContext)!
            let newPOI = POI(entity: entity, insertInto: managedContext)
            newPOI.setValue(POImodel.locationId, forKey: "locationId")
            newPOI.setValue(POImodel.city, forKey: "city")
            newPOI.setValue(POImodel.zipCode, forKey: "zipCode")
            newPOI.setValue(POImodel.distance, forKey: "distance")
            newPOI.setValue(POImodel.latitude, forKey: "latitude")
            newPOI.setValue(POImodel.longitude, forKey: "longitude")
            newPOI.setValue(POImodel.dateCaptured, forKey: "date")
            do {
                try managedContext.save()
            }
            catch let error as NSError {
                print("Could not insert. \(error), \(error.userInfo)")
            }
            NotificationCenter.default.post(name: .newPOISaved, object: self, userInfo: ["POI": POImodel])
        });
        
        
    
    }
    
    func erasePOI() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<POI>(entityName: "POI")
        let deleteReqest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try managedContext.execute(deleteReqest)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}

extension Notification.Name {
    static let newPOISaved = Notification.Name("newPOISaved")
}

