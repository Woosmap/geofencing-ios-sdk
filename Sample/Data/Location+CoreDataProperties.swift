//
//  Location+CoreDataProperties.swift
//  
//
//  Created by Mac de Laurent on 18/06/2020.
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
    @NSManaged public var locationId: String?
    @NSManaged public var longitude: Double

}
