//
//  POI+CoreDataProperties.swift
//  
//
//  Created by Mac de Laurent on 18/06/2020.
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
    @NSManaged public var locationId: String?
    @NSManaged public var longitude: Double
    @NSManaged public var zipCode: String?

}
