//
//  LocationServiceTests.swift
//  WoosmapGeofencingTests
//
//

import Foundation
import XCTest
import WoosmapGeofencing
import CoreLocation


class MockedLocationManager: LocationManagerProtocol {
    
    var monitoringSignificantLocationChanges = false
    var monitoringLocation = false
    var monitoringRegions = false
    
    
    
    var desiredAccuracy: CLLocationAccuracy
    var allowsBackgroundLocationUpdates: Bool
    var distanceFilter: CLLocationDistance
    var pausesLocationUpdatesAutomatically: Bool
    var delegate: CLLocationManagerDelegate?
    var monitoredRegions: Set<CLRegion>
    func requestAlwaysAuthorization() {}
    func startUpdatingLocation() { monitoringLocation = true }
    func stopUpdatingLocation() { monitoringLocation = false }
    func startMonitoringSignificantLocationChanges() { monitoringSignificantLocationChanges = true}
    func stopMonitoringSignificantLocationChanges() { monitoringSignificantLocationChanges = false}
    func stopMonitoring(for region: CLRegion) {
        monitoredRegions.remove(region)
    }
    func startMonitoring(for region: CLRegion) {
        monitoredRegions.insert(region)
    }
    
    public init () {
        monitoredRegions = Set()
        desiredAccuracy = kCLLocationAccuracyHundredMeters
        pausesLocationUpdatesAutomatically = false
        distanceFilter = 50
        allowsBackgroundLocationUpdates = false
    }
}

class FakeDelegate: LocationServiceDelegate {

    var error: Error?
    var locations: [CLLocation]?
    
    func tracingLocation(locations: [CLLocation], locationId: String) {
        self.locations = locations
    }
    
    func tracingLocationDidFailWithError(error: Error) {
        self.error = error
    }
}

class FakeVisitDelegate: VisitServiceDelegate {
    var visit: WGSVisit?
    func processVisit(visit: WGSVisit) {
        self.visit = visit
    }
    
    
}

class FakeError: Error {
    
}

class LocationServiceTests: XCTestCase {
    
    var locationManager: MockedLocationManager!
    var locationService: LocationService!
    
    
    override func setUp() {
        super.setUp()
        locationManager = MockedLocationManager()
        locationService = LocationService(locationManger: locationManager)
        locationService.locationServiceDelegate = FakeDelegate()
        locationService.visitDelegate = FakeVisitDelegate()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitShouldConfigureLocationManager() {
        
        XCTAssertEqual(locationManager.desiredAccuracy,kCLLocationAccuracyBestForNavigation, "desired accuracy should be kCLLocationAccuracyBestForNavigation")
        XCTAssertTrue(locationManager.allowsBackgroundLocationUpdates, "Should allow background location update")
        XCTAssertTrue(locationManager.pausesLocationUpdatesAutomatically, "Should allow to pause location update")
        XCTAssertEqual(locationManager.distanceFilter,10, "distance filter should be kCLDistanceFilterNone")
        
    }
    
    
    func testStartAndStopUpdatingLocationChangesCallsLocationManager() {
        locationService.startUpdatingLocation()
        XCTAssertTrue(locationManager.monitoringLocation, "Did not start monitoring location changes")
        locationService.stopUpdatingLocation()
        XCTAssertFalse(locationManager.monitoringLocation, "Did not stop monitoring location changes")
    }
    
    func testHandleRegionChange() {
        locationManager.monitoringRegions = true
        locationManager.monitoredRegions.insert(CLCircularRegion(center: CLLocationCoordinate2D(latitude: 1, longitude: 1), radius: 1, identifier: "1"))
        XCTAssertFalse(locationManager.monitoringLocation, "Already monitoring location changes")
        XCTAssertFalse(locationManager.monitoringSignificantLocationChanges, "Already monitoring significant location changes")
        locationService.handleRegionChange()
        XCTAssertTrue(locationManager.monitoringLocation, "Did not start monitoring location changes")
        XCTAssertTrue(locationManager.monitoringSignificantLocationChanges, "Did not start monitoring significant location changes")
        XCTAssertEqual(locationManager.monitoredRegions.count, 0, "Did not stop monitoring regions")
        
        
        
    }
    
    func testUpdateRegionMonitoringWithLocation() {
        locationService.currentLocation = CLLocation(latitude: 1, longitude: 1)
 
        locationManager.monitoredRegions.insert(CLCircularRegion(center: CLLocationCoordinate2D(latitude: 1, longitude: 1), radius: 1, identifier: "1"))
        
        locationService.updateRegionMonitoring()
        XCTAssertFalse(locationManager.monitoringLocation, "Did not stop monitoring location changes")
        XCTAssertTrue(locationManager.monitoredRegions.count > 1, "Did not monitor new regions")
        
    }
    
    func testUpdateRegionMonitoringWithoutLocation() {
        locationService.currentLocation = nil
        locationManager.monitoringLocation = true
        locationManager.monitoredRegions.insert(CLCircularRegion(center: CLLocationCoordinate2D(latitude: 1, longitude: 1), radius: 1, identifier: "1"))
        
        locationService.updateRegionMonitoring()
        
        XCTAssertTrue(locationManager.monitoringLocation, "SHould not have Stopped monitoring location changes")
        XCTAssertEqual(locationManager.monitoredRegions.count, 1, "Should not have monitored new regions")
        
    }
    
    func testUpdateLocationDidFailWithErrorShouldCallDelegate() {
        let lsd = locationService.locationServiceDelegate as! FakeDelegate
        XCTAssertNil(lsd.error, "Delegate error should be nil")
        let fakeError = FakeError()
        locationService.updateLocationDidFailWithError(error: fakeError)
        XCTAssertNotNil(lsd.error, "Delegate error should not be nil")
    }
    
    func testUpdateLocationShouldCallDelegate() {
        let lsd = locationService.locationServiceDelegate as! FakeDelegate
        XCTAssertNil(lsd.locations, "Delegate locations should be nil")
        let fakeLocations = [CLLocation(latitude: 1, longitude: 1)]
        locationService.updateLocation(locations: fakeLocations)
        XCTAssertNotNil(lsd.locations, "Delegate locations should not be nil")
    }
    
    
    func testVisitAlogithm() {
        let lsd = locationService.locationServiceDelegate as! FakeDelegate
        let vsd = locationService.visitDelegate as! FakeVisitDelegate
        XCTAssertNil(lsd.locations, "Delegate locations should be nil")
        
        let fakeLocations = [CLLocation(latitude: 1, longitude: 1)]
        locationService.updateLocation(locations: fakeLocations)
        Thread.sleep(forTimeInterval: 2)
        
        let fake2Locations = [CLLocation(latitude: 1, longitude: 1)]
        locationService.updateLocation(locations: fake2Locations)
        Thread.sleep(forTimeInterval: 2)
        
        let fake3Locations = [CLLocation(latitude: 1, longitude: 1)]
        locationService.updateLocation(locations: fake3Locations)
        Thread.sleep(forTimeInterval: 2)
        
        let fake4Locations = [CLLocation(latitude: 2, longitude: 2)]
        locationService.updateLocation(locations: fake4Locations)
        Thread.sleep(forTimeInterval: 2)

        XCTAssert(vsd.visit?.nbPoint! == 2)
        
        locationService.updateLocation(locations: fakeLocations)
        Thread.sleep(forTimeInterval: 2)
        
        locationService.updateLocation(locations: fake2Locations)
        Thread.sleep(forTimeInterval: 2)
        
        locationService.updateLocation(locations: fake3Locations)
        Thread.sleep(forTimeInterval: 2)
        
        locationService.updateLocation(locations: fake4Locations)
        Thread.sleep(forTimeInterval: 2)
        
        XCTAssert(vsd.visit?.nbPoint! == 2)

    }
    
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
    
    func testVisitWithMockData() {
        let lsd = locationService.locationServiceDelegate as! FakeDelegate
        let vsd = locationService.visitDelegate as! FakeVisitDelegate
        XCTAssertNil(lsd.locations, "Delegate locations should be nil")
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "home_work.csv", ofType: nil)!
        let dataLocations = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let testDatas = csv(data: dataLocations)
       
        var index = 0
        for linePoint in testDatas {
            index+=1

            let lat = Double(linePoint[0])
            let lng = Double(linePoint[1])
            let accuracy = Double(linePoint[2])

            let currentLocation = [CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: lng!), altitude: -1, horizontalAccuracy: accuracy!, verticalAccuracy: 0, timestamp: Date())]
            locationService.updateLocation(locations: currentLocation)
            Thread.sleep(forTimeInterval: 2)

            if(vsd.visit?.endTime != nil) {
                if(index == 12) {
                    XCTAssert(vsd.visit?.nbPoint! == 10)
                } else if (index == 35){
                    XCTAssert(vsd.visit?.nbPoint! == 15)
                }
            }
            
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
   
    
}
