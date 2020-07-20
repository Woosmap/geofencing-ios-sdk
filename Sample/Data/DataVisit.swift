//
//  DataVisit.swift
//
//  WoosmapGeofencing
//
//
import Foundation
import UIKit
import CoreData
import CoreLocation
import WoosmapGeofencing

class DataVisit:VisitServiceDelegate  {
    
    
    func processVisit(visit: CLVisit) {
        let calendar = Calendar.current
        let departureDate = calendar.component(.year, from: visit.departureDate) != 4001 ? visit.departureDate : nil
        let arrivalDate = calendar.component(.year, from: visit.arrivalDate) != 4001 ? visit.arrivalDate : nil
        
        if(arrivalDate != nil && departureDate != nil) {
            let visitToSave = VisitModel(visitId: UUID().uuidString, arrivalDate: arrivalDate, departureDate: departureDate, latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude, dateCaptured:Date() , accuracy: visit.horizontalAccuracy)
            createVisit(visit: visitToSave)
        }
        
    }
    
    func readVisits()-> Array<Visit> {
        var visits = [Visit]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Visit>(entityName: "Visit")
        
        do {
            visits = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return visits
    }
    
    func createVisit(visit: VisitModel) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Visit", in: context)!
        let newVisit = Visit(entity: entity, insertInto: context)
        newVisit.setValue(visit.visitId, forKey: "visitId")
        newVisit.setValue(visit.arrivalDate, forKey: "arrivalDate")
        newVisit.setValue(visit.departureDate, forKey: "departureDate")
        newVisit.setValue(visit.accuracy, forKey: "accuracy")
        newVisit.setValue(visit.latitude, forKey: "latitude")
        newVisit.setValue(visit.longitude, forKey: "longitude")
        newVisit.setValue(visit.dateCaptured, forKey: "date")
        do {
            try context.save()
        }
        catch let error as NSError {
            print("Could not insert. \(error), \(error.userInfo)")
        }
        NotificationCenter.default.post(name: .newVisitSaved, object: self,userInfo: ["Visit": visit])
        DataZOI().createZOIFromVisit(visit: newVisit)
    }
    
    func eraseVisits() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Visit>(entityName: "Visit")
        let deleteReqest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try managedContext.execute(deleteReqest)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getVisitFromUUID(id:String) -> Visit? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<Visit>(entityName: "Visit")
            fetchRequest.predicate = NSPredicate(format: "visitId == %@", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let aVisit = fetchedResults.first {
                return aVisit
            }
        }
        catch {
            print ("fetch task failed", error)
        }
        return nil
        
    }
    
}


extension Notification.Name {
    static let newVisitSaved = Notification.Name("newVisitSaved")
}


