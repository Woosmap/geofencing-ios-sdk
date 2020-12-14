//
//  Region+CoreDataProperties.swift
//  
//
//  Created by Mac de Laurent on 09/12/2020.
//
//

import Foundation
import CoreData


extension Region {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Region> {
        return NSFetchRequest<Region>(entityName: "Region")
    }

    @NSManaged public var date: Date?
    @NSManaged public var didEnter: Bool
    @NSManaged public var identifier: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var radius: Double

}
