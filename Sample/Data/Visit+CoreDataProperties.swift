//
//  Visit+CoreDataProperties.swift
//  
//
//  Created by Mac de Laurent on 18/06/2020.
//
//

import Foundation
import CoreData


extension Visit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Visit> {
        return NSFetchRequest<Visit>(entityName: "Visit")
    }

    @NSManaged public var accuracy: Double
    @NSManaged public var arrivalDate: Date?
    @NSManaged public var date: Date?
    @NSManaged public var departureDate: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var visitId: String?

}
