//
//  POI+CoreDataProperties.swift
//  
//
//  Created by Mac de Laurent on 12/02/2020.
//
//

import Foundation
import CoreData


extension POI {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<POI> {
        return NSFetchRequest<POI>(entityName: "POI")
    }

    @NSManaged public var city: String?
    @NSManaged public var date: Date?
    @NSManaged public var distance: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var zipCode: String?
    @NSManaged public var locationId: UUID?

}
