//
//  DataRegion.swift
//  Sample
//

import Foundation

import Foundation
import UIKit
import CoreData
import CoreLocation
import WoosmapGeofencing

public class DataRegion:RegionsServiceDelegate  {
    
    public func updateRegions(regions: Set<CLRegion>) {
        NotificationCenter.default.post(name: .updateRegions, object: self,userInfo: ["Regions": regions])
    }
    
    public func didEnterPOIRegion(POIregion: CLRegion) {
        createRegion(POIregion: POIregion, didEnter: true)
    }
    
    public func didExitPOIRegion(POIregion: CLRegion) {
        createRegion(POIregion: POIregion, didEnter: false)
    }
    
    public func readRegions()-> Array<Region> {
        var regions = [Region]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Region>(entityName: "Region")
        
        do {
            regions = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return regions
    }
    
    public func createRegion(POIregion: CLRegion, didEnter: Bool) {
        let latRegion = (POIregion as! CLCircularRegion).center.latitude
        let lngRegion = (POIregion as! CLCircularRegion).center.longitude
        let radius = (POIregion as! CLCircularRegion).radius
        let regionToSave = RegionModel(latitude: latRegion, longitude: lngRegion, radius: radius, dateCaptured: Date(), identifier: POIregion.identifier, didEnter: didEnter)
        
        
        DispatchQueue.main.async(execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Region", in: context)!
            let newRegion = Region(entity: entity, insertInto: context)
            newRegion.setValue(regionToSave.identifier, forKey: "identifier")
            newRegion.setValue(regionToSave.latitude, forKey: "latitude")
            newRegion.setValue(regionToSave.longitude, forKey: "longitude")
            newRegion.setValue(regionToSave.dateCaptured, forKey: "date")
            newRegion.setValue(regionToSave.didEnter, forKey: "didEnter")
            newRegion.setValue(regionToSave.radius, forKey: "radius")
            do {
                try context.save()
                
            }
            catch let error as NSError {
                print("Could not insert. \(error), \(error.userInfo)")
            }
            NotificationCenter.default.post(name: .didEventPOIRegion, object: self,userInfo: ["Region": regionToSave])
        });
    }
    
    public func eraseRegions() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Location>(entityName: "Region")
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
    static let updateRegions = Notification.Name("updateRegions")
    static let didEventPOIRegion = Notification.Name("didEventPOIRegion")

}

