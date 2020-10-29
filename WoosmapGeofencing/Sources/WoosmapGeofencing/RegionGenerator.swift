//
//  RegionGenerator.swift
//  WoosmapGeofencing
//
//

import Foundation
import CoreLocation



struct Translations {
    var offsetLat: Double
    var offsetLng: Double
    var identifier: String
}

class RegionsGenerator: NSObject {
    
    func generateRegionsFrom(location: CLLocation) -> Set<CLRegion> {
        
        let coordinate = location.coordinate
        //let speed = abs(location.speed)
        //Earth’s radius, sphere
        let R = 6378137.0
        
        var regions: Set<CLRegion> = []
        
        let pi = Double.pi
        let distanceDetection = 140.0
        let radiusDetection = 40.0
        
        let steps = 6.0
        let stepsLength = 2 * Double.pi / steps
        
        let lat = coordinate.latitude * pi / 180.0
        let lng = coordinate.longitude * pi / 180.0
        
        var t: Double = 0
        while(t <= 2 * pi) {
            let cos_t = cos(Double(t))
            let sin_t = sin(Double(t))
            let c = acos((cos(distanceDetection/R) - pow(sin(lat), 2.0)) / pow(cos(lat),2.0))
            let pointLng = lng + c * cos_t
            let pointLat = lat + (distanceDetection/R) * sin_t
            
            let center = CLLocationCoordinate2D(latitude: pointLat * 180 / pi, longitude: pointLng * 180 / pi)
            let name = "detection" + String(t)
            regions.insert(CLCircularRegion(center: center, radius: radiusDetection, identifier: name))
            
            t += stepsLength
        }
       
    
        return regions
    }
    
}
