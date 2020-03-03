//
//  Location+CoreDataProperties.swift
//  
//
//  Created by Mac de Laurent on 12/02/2020.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var date: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var locationDescription: String?
    @NSManaged public var longitude: Double
    @NSManaged public var locationId: UUID?

}
