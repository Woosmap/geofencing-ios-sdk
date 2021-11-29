//
//  DataTrafficDistance.swift
//

import Foundation
import CoreLocation
import WoosmapGeofencing

public class DataDistance: DistanceAPIDelegate {
    public init() {}
    
    public func distanceAPIError(error: String) {
        print(error)
    }

    public func distanceAPIResponse(distance: [Distance]) {
        print("distance = " + distance.debugDescription)
        
    }
}
