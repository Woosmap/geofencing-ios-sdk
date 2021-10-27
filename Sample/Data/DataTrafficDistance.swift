//
//  DataTrafficDistance.swift
//

import Foundation
import CoreLocation
import WoosmapGeofencing

public class DataTrafficDistance: TrafficDistanceAPIDelegate {
    public init() {}
    
    public func trafficDistanceAPIError(error: String) {
        print(error)
    }

    public func trafficDistanceAPIResponse(trafficDistance: TrafficDistance) {
        print("trafficDistance = " + trafficDistance.debugDescription)
        print("trafficDistance.distance = " + String(trafficDistance.distance))
    }
}
