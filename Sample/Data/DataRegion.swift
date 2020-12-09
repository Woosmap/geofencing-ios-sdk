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
        let latRegion = (POIregion as! CLCircularRegion).center.latitude
        let lngRegion = (POIregion as! CLCircularRegion).center.longitude
        let radius = (POIregion as! CLCircularRegion).radius
        let regionToSave = RegionModel(latitude: latRegion, longitude: lngRegion, radius: radius, dateCaptured: Date(), identifier: POIregion.identifier, didEnter: true)
        
        createRegion(region: regionToSave)
    }
    
    public func didExitPOIRegion(POIregion: CLRegion) {
        let latRegion = (POIregion as! CLCircularRegion).center.latitude
        let lngRegion = (POIregion as! CLCircularRegion).center.longitude
        let radius = (POIregion as! CLCircularRegion).radius
        let regionToSave = RegionModel(latitude: latRegion, longitude: lngRegion, radius: radius, dateCaptured: Date(), identifier: POIregion.identifier, didEnter: false)
        
        createRegion(region: regionToSave)
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
    
    public func createRegion(region: RegionModel) {
        DispatchQueue.main.async(execute: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Region", in: context)!
            let newRegion = Region(entity: entity, insertInto: context)
            newRegion.setValue(region.identifier, forKey: "identifier")
            newRegion.setValue(region.latitude, forKey: "latitude")
            newRegion.setValue(region.longitude, forKey: "longitude")
            newRegion.setValue(region.dateCaptured, forKey: "date")
            newRegion.setValue(region.didEnter, forKey: "didEnter")
            newRegion.setValue(region.radius, forKey: "radius")
            do {
                try context.save()
                
            }
            catch let error as NSError {
                print("Could not insert. \(error), \(error.userInfo)")
            }
            NotificationCenter.default.post(name: .didEventPOIRegion, object: self,userInfo: ["Region": region])
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

