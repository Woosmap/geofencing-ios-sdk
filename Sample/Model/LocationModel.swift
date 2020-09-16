//
//  LocationModel.swift
//  WoosmapGeofencing
//
//

import Foundation

public struct LocationModel {
    public init(locationId: String? = nil, latitude: Double? = nil, longitude: Double? = nil, dateCaptured: Date? = nil, descriptionToSave: String? = nil) {
        self.locationId = locationId
        self.latitude = latitude
        self.longitude = longitude
        self.dateCaptured = dateCaptured
        self.descriptionToSave = descriptionToSave
    }
    
    public var locationId: String!
    public var latitude: Double!
    public var longitude: Double!
    public var dateCaptured: Date!
    public var descriptionToSave: String?
}

