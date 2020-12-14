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
    
    var s_radius = 140.0
    var s_fullOffset = 320.0
    var s_halfOffset = 270.0
    
    
    var radiuses : [Double] = [
        200.0,
        300.0,
        500.0,
        1000.0,
        2000.0
        ]
    
    func getNewLatLon(offsetLat: Double, offsetLng: Double, lat: Double, lon: Double) -> (latitude: Double, longitude: Double) {
        //Earth’s radius, sphere
        let R = 6378137.0
        
        //Coordinate offsets in radians
        let dLat = offsetLat/R
        let dLon = offsetLng/(R*cos(Double.pi*lat/180.0))
        
        //OffsetPosition, decimal degrees
        let latO = lat + dLat * 180.0/Double.pi
        let lonO = lon + dLon * 180.0/Double.pi
        
        return (latitude: latO,longitude: lonO)
    }
    
    func generateRegionsFrom(location: CLLocation) -> Set<CLRegion> {
        
        let coordinate = location.coordinate
        let speed = abs(location.speed)
        
        s_fullOffset = max(speed * 48, 320)
        s_halfOffset = max(speed * 36, 270)
        s_radius = max(speed * 20, 140)
        
        let translations = [
            Translations(offsetLat: s_fullOffset, offsetLng: 0, identifier: "POSITION_REGION_translation n"),
            Translations(offsetLat: s_halfOffset, offsetLng: -s_halfOffset, identifier: "POSITION_REGION_translation nw"),
            Translations(offsetLat: s_halfOffset, offsetLng: s_halfOffset, identifier: "POSITION_REGION_translation ne"),
            Translations(offsetLat: -s_fullOffset, offsetLng: 0, identifier: "POSITION_REGION_translation s"),
            Translations(offsetLat: -s_halfOffset, offsetLng: -s_halfOffset, identifier: "POSITION_REGION_translation sw"),
            Translations(offsetLat: -s_halfOffset, offsetLng: s_halfOffset, identifier: "POSITION_REGION_translation se"),
            Translations(offsetLat: 0, offsetLng: s_fullOffset, identifier: "POSITION_REGION_translation e"),
            Translations(offsetLat: 0, offsetLng: -s_fullOffset, identifier: "POSITION_REGION_translation w"),
        ]
        
        var regions: Set<CLRegion> = []
        
        for translation in translations {
            let translatedLatLng = getNewLatLon(offsetLat: translation.offsetLat, offsetLng: translation.offsetLng, lat: coordinate.latitude, lon: coordinate.longitude)
            let center = CLLocationCoordinate2D(latitude: translatedLatLng.latitude, longitude: translatedLatLng.longitude)
            regions.insert(CLCircularRegion(center: center, radius: s_radius, identifier: translation.identifier))
        }
        
        for radius in radiuses {
            
            if radius <= 500 && location.speed > 10 {
                continue
            }
            regions.insert(CLCircularRegion(center: coordinate, radius: radius, identifier: "POSITION_REGION_radius \(radius)"))
            
        }
    
        return regions
    }
    
}
