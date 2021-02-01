//
//  DelayDataDurationTests.swift
//  WoosmapGeofencingTests
//
//  Copyright © 2021 Web Geo Services. All rights reserved.
//

import XCTest
import WoosmapGeofencing
import RealmSwift

class DelayDataDurationTests: XCTestCase {
    let dateFormatter = DateFormatter()

    override func setUp() {
        super.setUp()
        // Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                        appropriateFor: nil, create: false)
        let url = documentDirectory!.appendingPathComponent("my-new-realm.realm")
        Realm.Configuration.defaultConfiguration.fileURL = url

        cleanDatabase()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ssZ"
    }

    override func tearDown() {
        super.tearDown()
        cleanDatabase()
    }

    func test_when_clean_old_geographic_data_then_clean_data_older_than_data_duration_delay() {
        dataDurationDelay = 30
        let lastDateUpdate = dateFormatter.date(from: "2018-12-24 14:25:03+00")
        UserDefaults.standard.set(lastDateUpdate, forKey: "lastDateUpdate")

        let lng = 3.8793329
        let lat = 43.6053862
        let accuracy = 20.0

        for day in 0...59 {
            let id = UUID().uuidString
            let dateCaptured = Calendar.current.date(byAdding: .day, value: -day, to: Date())

            let visitToSave = Visit(visitId: id, arrivalDate: dateCaptured, departureDate: Calendar.current.date(byAdding: .day, value: 1, to: dateCaptured!), latitude: lat, longitude: lng, dateCaptured: dateCaptured, accuracy: accuracy)

            let POIToSave = POI(locationId: id, city: "CityTest", zipCode: "CodeTest", distance: 10.0, latitude: lat, longitude: lng, dateCaptured: dateCaptured)

            let locationToSave = Location(locationId: id, latitude: lat, longitude: lng, dateCaptured: dateCaptured!, descriptionToSave: "mockLocation")

            Locations.addTest(location: locationToSave)
            POIs.addTest(poi: POIToSave)
            Visits.addTest(visit: visitToSave)
        }

        // Delete the old data
        let userDataCleaner = DataCleaner()
        userDataCleaner.cleanOldGeographicData()

        XCTAssert(Locations.getAll().count == 30)
        XCTAssert(POIs.getAll().count == 30)
        XCTAssert(Visits.getAll().count == 30)
    }

    func cleanDatabase() {
        Locations.deleteAll()
        Visits.deleteAll()
        ZOIs.deleteAll()
        POIs.deleteAll()
    }

}
