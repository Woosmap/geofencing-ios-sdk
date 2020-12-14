//
//  RegionModel.swift
//  Sample
//


import Foundation

public struct RegionModel {
    public init(latitude: Double? = nil, longitude: Double? = nil, radius: Double?, dateCaptured: Date? = nil, identifier: String? = nil, didEnter: Bool = false) {
        self.latitude = latitude
        self.longitude = longitude
        self.dateCaptured = dateCaptured
        self.didEnter = didEnter
        self.identifier = identifier
        self.radius = radius
    }
    
    public var latitude: Double!
    public var longitude: Double!
    public var radius: Double!
    public var dateCaptured: Date!
    public var identifier: String?
    public var didEnter: Bool
}
