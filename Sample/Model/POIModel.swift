//
//  SearchAPIModel.swift
//  WoosmapGeofencing
//
//

import Foundation
public struct POIModel {
    public init(locationId: String? = nil, city: String? = nil, zipCode: String? = nil, distance: Double? = nil, latitude: Double? = nil, longitude: Double? = nil, dateCaptured: Date? = nil) {
        self.locationId = locationId
        self.city = city
        self.zipCode = zipCode
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
        self.dateCaptured = dateCaptured
    }
    
    var locationId: String!
    var city: String!
    var zipCode: String!
    var distance: Double!
    var latitude: Double!
    var longitude: Double!
    var dateCaptured: Date!
}

