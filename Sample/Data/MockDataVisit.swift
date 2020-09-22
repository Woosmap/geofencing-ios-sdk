//
//  MockDataVisit.swift
//  Sample
//
//  Created by Mac de Laurent on 09/06/2020.
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import Foundation
import WoosmapGeofencing

//Class to mock the visits in order to create ZOI
public class MockDataVisit {
    
    public init() {}
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ";")
            if(columns[0] != "") {
                result.append(columns)
            }
        }
        return result
    }
    
    public func mockVisitData() {
        DataVisit().eraseVisits()
        DataZOI().eraseZOIs()
        let path = Bundle.main.path(forResource: "Visit_qualif.csv", ofType: nil)!
        let dataVisit = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let testDatas = csv(data: dataVisit)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ssZ"
        
        for linePoint in testDatas {
            let visit = linePoint[0].components(separatedBy: ",")
            
            let id = visit[0]
            let accuracy = Double(visit[1])!
            
            if(accuracy < 20.0) {
                let latLng = visit[2].replacingOccurrences(of: "POINT(", with: "").replacingOccurrences(of: ")", with: "")
                let lng = Double(latLng.components(separatedBy: " ")[0])!
                let lat = Double(latLng.components(separatedBy: " ")[1])!
                
                let arrivalDate = dateFormatter.date(from:visit[3])!
                let departureDate = dateFormatter.date(from:visit[4])!
                
                let visitToSave = VisitModel(visitId: id, arrivalDate: arrivalDate, departureDate: departureDate, latitude: lat, longitude:  lng, dateCaptured:departureDate, accuracy: accuracy)
                
                DataVisit().createVisit(visit: visitToSave)
            }
        }
    }
    
    
    public func mockLocationsData() {
        DataLocation().eraseLocations()
        DataVisit().eraseVisits()
        DataZOI().eraseZOIs()
        let path = Bundle.main.path(forResource: "Locations.csv", ofType: nil)!
        let dataVisit = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let testDatas = csv(data: dataVisit)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ssZ"
        
        for linePoint in testDatas {
            let visit = linePoint[0].components(separatedBy: ",")
            
            let id = visit[0]
            let accuracy = Double(visit[1])!
            
            if(accuracy < 20.0) {
                let latLng = visit[2].replacingOccurrences(of: "POINT(", with: "").replacingOccurrences(of: ")", with: "")
                let lng = Double(latLng.components(separatedBy: " ")[0])!
                let lat = Double(latLng.components(separatedBy: " ")[1])!
                
                let arrivalDate = dateFormatter.date(from:visit[3])!
                let departureDate = dateFormatter.date(from:visit[4])!
                
                let visitToSave = VisitModel(visitId: id, arrivalDate: arrivalDate, departureDate: departureDate, latitude: lat, longitude:  lng, dateCaptured:departureDate, accuracy: accuracy)
                
                let locationToSave = LocationModel(locationId: id, latitude: lat, longitude: lng, dateCaptured: departureDate, descriptionToSave: "mockLocation")
                
                DataVisit().createVisit(visit: visitToSave)
                DataLocation().createLocation(location: locationToSave)
            }
        }
    }
    
}
