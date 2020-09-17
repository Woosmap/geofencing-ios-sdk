//
//  DelayDataDurationTests.swift
//  
//
//  Created by Mac de Laurent on 14/09/2020.
//

import XCTest
import SampleGeofencing

class DelayDataDurationTests: XCTestCase {
    let dateFormatter = DateFormatter()

    override func setUp() {
        super.setUp()
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
        UserDefaults.standard.set(lastDateUpdate, forKey:"lastDateUpdate")
        
        let lng = 3.8793329
        let lat = 43.6053862
        let accuracy = 20.0

        for day in 0...59 {
            let id = UUID().uuidString
            let dateCaptured = Calendar.current.date(byAdding: .day, value: -day, to: Date())
        
            let visitToSave = VisitModel.init(visitId: id, arrivalDate: dateCaptured, departureDate: Calendar.current.date(byAdding: .day, value: 1, to: dateCaptured!), latitude: lat, longitude:  lng, dateCaptured:dateCaptured, accuracy: accuracy)
            
            let locationToSave = LocationModel.init(locationId: id, latitude: lat, longitude: lng, dateCaptured: dateCaptured, descriptionToSave: "mockLocation")
            
            DataVisit().createVisit(visit: visitToSave)
            DataLocation().createLocation(location: locationToSave)
        }
        
        waitForMainQueue()
        
        //Delete the old data
        let userDataCleaner = UserDataCleaner()
        userDataCleaner.cleanOldGeographicData()
        
        XCTAssert(DataLocation().readLocations().count == 30)
        XCTAssert(DataVisit().readVisits().count == 30)
    }
    
    func waitForMainQueue() {
        let expectation = self.expectation(description: "add Location in Database")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func cleanDatabase() {
        DataLocation().eraseLocations()
        DataVisit().eraseVisits()
        DataZOI().eraseZOIs()
    }
    
    
}
