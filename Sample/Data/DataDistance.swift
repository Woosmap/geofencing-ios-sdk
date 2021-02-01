//
//  DataDistance.swift
//  Sample
//
//

import Foundation
import CoreLocation
import WoosmapGeofencing

public class DataDistance: DistanceAPIDelegate {
    public init() {}

    public func distanceAPIResponseData(distanceAPIData: DistanceAPIData, locationId: String) {
        if distanceAPIData.status == "OK" {
            if distanceAPIData.rows?.first?.elements?.first?.status == "OK" {
                let distance = distanceAPIData.rows?.first?.elements?.first?.distance?.value!
                let duration = distanceAPIData.rows?.first?.elements?.first?.duration?.text!
                if distance != nil && duration != nil {
                    print(distance ?? 0)
                    print(duration ?? 0)
                }
            }
        }
    }

    public func distanceAPIError(error: String) {
        print(error)
    }

}
