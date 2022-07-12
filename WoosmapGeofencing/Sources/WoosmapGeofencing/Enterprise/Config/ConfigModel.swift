//
//  ConfigModel.swift
//  WoosmapGeofencing
//
//  Copyright © 2021 Web Geo Services. All rights reserved.
//

import Foundation

public struct ConfigModel: Codable {
    let trackingEnable, foregroundLocationServiceEnable, modeHighFrequencyLocation, visitEnable: Bool?
    let woosmapKey: String?
    let classificationEnable: Bool?
    let minDurationVisitDisplay, radiusDetectionClassifiedZOI, distanceDetectionThresholdVisits: Double?
    let creationOfZOIEnable: Bool?
    let accuracyVisitFilter, currentLocationTimeFilter, currentLocationDistanceFilter, accuracyFilter: Double?
    let distanceAPIEnable: Bool?
    let distance: DistanceConfig?
    let searchAPI: SearchAPIConfig?
    let sfmcCredentials: SFMCConfig?
    let outOfTimeDelay, dataDurationDelay: Int?

    init(trackingEnable: Bool?, foregroundLocationServiceEnable: Bool?, modeHighFrequencyLocation: Bool?, woosmapKey: String?, visitEnable: Bool?, classificationEnable: Bool?, minDurationVisitDisplay: Double?, radiusDetectionClassifiedZOI: Double?, distanceDetectionThresholdVisits: Double?, creationOfZOIEnable: Bool?, accuracyVisitFilter: Double?, currentLocationTimeFilter: Double?, currentLocationDistanceFilter: Double?, accuracyFilter: Double?, searchAPIEnable: Bool?, searchAPICreationRegionEnable: Bool?, searchAPITimeFilter: Int?, searchAPIDistanceFilter: Int?, searchAPIRefreshDelayDay: Int?, distanceAPIEnable: Bool?, distanceConfig: DistanceConfig?, searchAPIConfig:SearchAPIConfig?, SFMCConfig:SFMCConfig?, outOfTimeDelay: Int?, dataDurationDelay: Int?) {
        self.trackingEnable = trackingEnable
        self.foregroundLocationServiceEnable = foregroundLocationServiceEnable
        self.modeHighFrequencyLocation = modeHighFrequencyLocation
        self.woosmapKey = woosmapKey
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
        self.sfmcCredentials = SFMCConfig
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
    let searchAPIParameters: [SearchAPIParameters]?
}

public struct SearchAPIParameters: Codable {
    let key: String?
    let value: String?
}


public struct SFMCConfig: Codable {
    let authenticationBaseURI, restBaseURI, client_id, client_secret, regionEnteredEventDefinitionKey, regionExitedEventDefinitionKey, poiEventDefinitionKey, zoiClassifiedEnteredEventDefinitionKey, zoiClassifiedExitedEventDefinitionKey, visitEventDefinitionKey: String?
}
