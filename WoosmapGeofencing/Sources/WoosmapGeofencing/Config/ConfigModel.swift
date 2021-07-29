//
//  ConfigModel.swift
//  WoosmapGeofencing
//
//  Copyright © 2021 Web Geo Services. All rights reserved.
//

import Foundation

class ConfigModel: Codable { 
    let trackingEnable, foregroundLocationServiceEnable, modeHighFrequencyLocation, visitEnable: Bool?
    let classificationEnable: Bool?
    let minDurationVisitDisplay, radiusDetectionClassifiedZOI, distanceDetectionThresholdVisits: Double?
    let creationOfZOIEnable: Bool?
    let accuracyVisitFilter, currentLocationTimeFilter, currentLocationDistanceFilter, accuracyFilter: Double?
    let searchAPIEnable, searchAPICreationRegionEnable: Bool?
    let searchAPITimeFilter, searchAPIDistanceFilter: Int?
    let distanceAPIEnable: Bool?
    let modeDistance: String?
    let outOfTimeDelay, dataDurationDelay: Int?

    init(trackingEnable: Bool?, foregroundLocationServiceEnable: Bool?, modeHighFrequencyLocation: Bool?, visitEnable: Bool?, classificationEnable: Bool?, minDurationVisitDisplay: Double?, radiusDetectionClassifiedZOI: Double?, distanceDetectionThresholdVisits: Double?, creationOfZOIEnable: Bool?, accuracyVisitFilter: Double?, currentLocationTimeFilter: Double?, currentLocationDistanceFilter: Double?, accuracyFilter: Double?, searchAPIEnable: Bool?, searchAPICreationRegionEnable: Bool?, searchAPITimeFilter: Int?, searchAPIDistanceFilter: Int?, distanceAPIEnable: Bool?, modeDistance: String?, outOfTimeDelay: Int?, dataDurationDelay: Int?) {
        self.trackingEnable = trackingEnable
        self.foregroundLocationServiceEnable = foregroundLocationServiceEnable
        self.modeHighFrequencyLocation = modeHighFrequencyLocation
        self.visitEnable = visitEnable
        self.classificationEnable = classificationEnable
        self.minDurationVisitDisplay = minDurationVisitDisplay
        self.radiusDetectionClassifiedZOI = radiusDetectionClassifiedZOI
        self.distanceDetectionThresholdVisits = distanceDetectionThresholdVisits
        self.creationOfZOIEnable = creationOfZOIEnable
        self.accuracyVisitFilter = accuracyVisitFilter
        self.currentLocationTimeFilter = currentLocationTimeFilter
        self.currentLocationDistanceFilter = currentLocationDistanceFilter
        self.accuracyFilter = accuracyFilter
        self.searchAPIEnable = searchAPIEnable
        self.searchAPICreationRegionEnable = searchAPICreationRegionEnable
        self.searchAPITimeFilter = searchAPITimeFilter
        self.searchAPIDistanceFilter = searchAPIDistanceFilter
        self.distanceAPIEnable = distanceAPIEnable
        self.modeDistance = modeDistance
        self.outOfTimeDelay = outOfTimeDelay
        self.dataDurationDelay = dataDurationDelay
    }
}
