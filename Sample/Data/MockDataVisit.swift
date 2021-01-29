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
            if columns[0] != "" {
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

            if accuracy < 20.0 {
                let latLng = visit[2].replacingOccurrences(of: "POINT(", with: "").replacingOccurrences(of: ")", with: "")
                let lng = Double(latLng.components(separatedBy: " ")[0])!
                let lat = Double(latLng.components(separatedBy: " ")[1])!

                let arrivalDate = dateFormatter.date(from: visit[3])!
                let departureDate = dateFormatter.date(from: visit[4])!

                let visitToSave = Visit(visitId: id, arrivalDate: arrivalDate, departureDate: departureDate, latitude: lat, longitude: lng, dateCaptured: departureDate, accuracy: accuracy)
                Visits.addTest(visit: visitToSave)
            }
        }
        NotificationCenter.default.post(name: .reloadData, object: self)
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

            if accuracy < 20.0 {
                let latLng = visit[2].replacingOccurrences(of: "POINT(", with: "").replacingOccurrences(of: ")", with: "")
                let lng = Double(latLng.components(separatedBy: " ")[0])!
                let lat = Double(latLng.components(separatedBy: " ")[1])!

                let arrivalDate = dateFormatter.date(from: visit[3])!
                let departureDate = dateFormatter.date(from: visit[4])!

                let visitToSave = Visit(visitId: id, arrivalDate: arrivalDate, departureDate: departureDate, latitude: lat, longitude: lng, dateCaptured: departureDate, accuracy: accuracy)

                let locationToSave = Location(locationId: id, latitude: lat, longitude: lng, dateCaptured: departureDate, descriptionToSave: "mockLocation")

                let POIToSave = POI(locationId: id, city: "test", zipCode: "75020", distance: 10.0, latitude: lat, longitude: lng, dateCaptured: departureDate)

                Visits.addTest(visit: visitToSave)
                Locations.addTest(location: locationToSave)
                POIs.addTest(poi: POIToSave)
            }
        }
        NotificationCenter.default.post(name: .reloadData, object: self)
    }

    public func mockDataFromSample() {
        DataLocation().eraseLocations()
        DataVisit().eraseVisits()
        DataZOI().eraseZOIs()
        let path = Bundle.main.path(forResource: "SampleGeofencing.csv", ofType: nil)!
        let dataCSV = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let extractedDatas = csv(data: dataCSV)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ssZ"
        var id = 0
        var nbrLoc = 0
        for linePoint in extractedDatas {
            if linePoint == extractedDatas.first {
                continue
            }
            id+=1
            let point = linePoint[0].components(separatedBy: ",")
            let creationDate = point[0].replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let lat = Double(point[1])
            let lng = Double(point[2])
            let description = point[3].replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let city = point[4].replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let distance = Double(point[5])
            let zipcode = point[6].replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let type = point[7]
            let accuracy = Double(point[8])
            let arrivalDate = point[9].replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
            let departureDate = point[10].replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")

            if type == "location" {
                nbrLoc+=1
                print("location " + String(nbrLoc))
                let locationToSave = Location(locationId: String(id), latitude: lat!, longitude: lng!, dateCaptured: dateFormatter.date(from: creationDate)!, descriptionToSave: description)
                Locations.addTest(location: locationToSave)
            } else if type == "POI" {
                let POIToSave = POI(locationId: String(id), city: city, zipCode: zipcode, distance: distance, latitude: lat, longitude: lng, dateCaptured: dateFormatter.date(from: creationDate))
                POIs.addTest(poi: POIToSave)
            } else if type == "visit" {
                let visitToSave = Visit(visitId: String(id), arrivalDate: dateFormatter.date(from: arrivalDate), departureDate: dateFormatter.date(from: departureDate), latitude: lat!, longitude: lng!, dateCaptured: dateFormatter.date(from: creationDate), accuracy: accuracy!)
                Visits.addTest(visit: visitToSave)
            }
        }
        NotificationCenter.default.post(name: .reloadData, object: self)
    }

}

extension Notification.Name {
    static let reloadData = Notification.Name("reloadData")
}
