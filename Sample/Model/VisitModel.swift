//
//  VisitModel.swift
//

import Foundation

import Foundation
public struct VisitModel {
    public init(visitId: String, arrivalDate: Date? = nil, departureDate: Date? = nil, latitude: Double, longitude: Double, dateCaptured: Date? = nil, accuracy: Double) {
        self.visitId = visitId
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
        self.latitude = latitude
        self.longitude = longitude
        self.dateCaptured = dateCaptured
        self.accuracy = accuracy
    }
    
    public var visitId: String
    public var arrivalDate: Date?
    public var departureDate: Date?
    public var latitude: Double
    public var longitude: Double
    public var dateCaptured: Date!
    public var accuracy: Double
}

