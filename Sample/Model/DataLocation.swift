//
//  DataLocation.swift
//  WoosmapGeofencing
//
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import WoosmapGeofencing

public class DataLocation:LocationServiceDelegate  {
    
    var lastLocation: CLLocation?
    
    public init() {}
    
    public func tracingLocation(locations: [CLLocation], locationId: String) {
        let location = locations.last!
        
        let locationToSave = LocationModel(locationId: locationId, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, dateCaptured: Date(), descriptionToSave: "description")
        createLocation(location: locationToSave)
        self.lastLocation = location
    }
    
    public func tracingLocationDidFailWithError(error: Error) {
        NSLog("\(error)")
    }
    
    
    public func readLocations()-> Array<Location> {
        var locations = [Location]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
        
        do {
            locations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return locations
    }
    
    public func createLocation(location: LocationModel) {
        DispatchQueue.main.async(execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)!
            let newLocation = Location(entity: entity, insertInto: context)
            newLocation.setValue(location.locationId, forKey: "locationId")
            newLocation.setValue(location.latitude, forKey: "latitude")
            newLocation.setValue(location.longitude, forKey: "longitude")
            newLocation.setValue(location.dateCaptured, forKey: "date")
            newLocation.setValue(location.descriptionToSave, forKey: "locationDescription")
            do {
                try context.save()
                
            }
            catch let error as NSError {
                print("Could not insert. \(error), \(error.userInfo)")
            }
            NotificationCenter.default.post(name: .newLocationSaved, object: self,userInfo: ["Location": location])
        });
    }
    
    public func eraseLocations() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
        let deleteReqest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try managedContext.execute(deleteReqest)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getLocationFromUUID(id:String) -> Location? {
        var locations = [Location]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
        fetchRequest.predicate = NSPredicate(format: "locationId = %@", id as CVarArg)
        do {
            locations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        if locations.isEmpty {
            return nil
        }
        return locations.first!
    }
    
    
}

extension Notification.Name {
    static let newLocationSaved = Notification.Name("newLocationSaved")
}


