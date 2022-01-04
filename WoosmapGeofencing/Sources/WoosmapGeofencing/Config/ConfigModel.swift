//
//  ConfigModel.swift
//  WoosmapGeofencing
//
//  Copyright © 2021 Web Geo Services. All rights reserved.
//

import Foundation

public struct ConfigModel: Codable {
    let trackingEnable, foregroundLocationServiceEnable, modeHighFrequencyLocation, visitEnable: Bool?
    let classificationEnable: Bool?
    let minDurationVisitDisplay, radiusDetectionClassifiedZOI, distanceDetectionThresholdVisits: Double?
    let creationOfZOIEnable: Bool?
    let accuracyVisitFilter, currentLocationTimeFilter, currentLocationDistanceFilter, accuracyFilter: Double?
    let distanceAPIEnable: Bool?
    let distance: DistanceConfig?
    let searchAPI: SearchAPIConfig?
    let outOfTimeDelay, dataDurationDelay: Int?

    init(trackingEnable: Bool?, foregroundLocationServiceEnable: Bool?, modeHighFrequencyLocation: Bool?, visitEnable: Bool?, classificationEnable: Bool?, minDurationVisitDisplay: Double?, radiusDetectionClassifiedZOI: Double?, distanceDetectionThresholdVisits: Double?, creationOfZOIEnable: Bool?, accuracyVisitFilter: Double?, currentLocationTimeFilter: Double?, currentLocationDistanceFilter: Double?, accuracyFilter: Double?, searchAPIEnable: Bool?, searchAPICreationRegionEnable: Bool?, searchAPITimeFilter: Int?, searchAPIDistanceFilter: Int?, searchAPIRefreshDelayDay: Int?, distanceAPIEnable: Bool?, distanceConfig: DistanceConfig?, searchAPIConfig:SearchAPIConfig?, outOfTimeDelay: Int?, dataDurationDelay: Int?) {
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
        self.searchAPI = searchAPIConfig
        self.distanceAPIEnable = distanceAPIEnable
        self.distance = distanceConfig
        self.outOfTimeDelay = outOfTimeDelay
        self.dataDurationDelay = dataDurationDelay
    }
}


public struct DistanceConfig: Codable {
    let distanceProvider, distanceMode, distanceRouting, distanceUnits: String?
    let distanceLanguage: String?
    let distanceMaxAirDistanceFilter: Int?
    let distanceTimeFilter: Int?
}

public struct SearchAPIConfig: Codable {
    let searchAPIEnable, searchAPICreationRegionEnable: Bool?
    let searchAPITimeFilter, searchAPIDistanceFilter, searchAPIRefreshDelayDay: Int?
}
