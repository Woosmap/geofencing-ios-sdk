//
//  ZOI+CoreDataProperties.swift
//  
//
//  Created by Mac de Laurent on 22/07/2020.
//
//

import Foundation
import CoreData


extension ZOI {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ZOI> {
        return NSFetchRequest<ZOI>(entityName: "ZOI")
    }

    @NSManaged public var accumulator: Double
    @NSManaged public var age: Double
    @NSManaged public var covariance_det: Double
    @NSManaged public var duration: Int64
    @NSManaged public var endTime: Date?
    @NSManaged public var idVisits: [String]?
    @NSManaged public var latMean: Double
    @NSManaged public var lngMean: Double
    @NSManaged public var period: String?
    @NSManaged public var prior_probability: Double
    @NSManaged public var startTime: Date?
    @NSManaged public var weekly_density: [Double]?
    @NSManaged public var wktPolygon: String?
    @NSManaged public var x00Covariance_matrix_inverse: Double
    @NSManaged public var x01Covariance_matrix_inverse: Double
    @NSManaged public var x10Covariance_matrix_inverse: Double
    @NSManaged public var x11Covariance_matrix_inverse: Double
    @NSManaged public var zoiId: String?

}
