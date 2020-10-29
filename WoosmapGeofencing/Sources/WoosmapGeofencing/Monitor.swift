import Foundation
import CoreLocation
import UserNotifications

public class WGSVisit {
    public var uuid : String? = nil
    public var currentLocation: CLLocation? = nil
    public var startTime : Date! = nil
    public var endTime : Date? = nil
    public var nbPoint : Int? = nil
    public let duration : Int? = nil
}

public protocol LocationServiceDelegate {
    func tracingLocation(locations: [CLLocation], locationId: String)
    func tracingLocationDidFailWithError(error: Error)
}

public protocol SearchAPIDelegate {
    func searchAPIResponseData(searchAPIData: SearchAPIData, locationId: String)
    func serachAPIError(error: String)
}

public protocol RegionsServiceDelegate {
    func updateRegions(regions: Set<CLRegion>)
}

public protocol VisitServiceDelegate {
    func processVisit(visit: WGSVisit)
}

public extension Date {
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}

public protocol LocationManagerProtocol {
    var desiredAccuracy: CLLocationAccuracy  { get set }
    var allowsBackgroundLocationUpdates: Bool { get set }
    var distanceFilter: CLLocationDistance { get set }
    var pausesLocationUpdatesAutomatically: Bool { get set }
    var delegate: CLLocationManagerDelegate? { get set }
    var monitoredRegions: Set<CLRegion> { get }
    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func startMonitoringSignificantLocationChanges()
    func stopMonitoringSignificantLocationChanges()
    func stopMonitoring(for: CLRegion)
    func startMonitoring(for: CLRegion)
}

extension CLLocationManager: LocationManagerProtocol {}

public class LocationService: NSObject, CLLocationManagerDelegate {
    
    public var locationManager: LocationManagerProtocol?
    public var beforeLastLocation: CLLocation?
    public var lastLocation: CLLocation?
    var currentVisit: WGSVisit?
    var lastSearchLocation: CLLocation?
    var lastRegionUpdate: Date?
    
    public var locationServiceDelegate: LocationServiceDelegate?
    public var searchAPIDataDelegate: SearchAPIDelegate?
    public var regionDelegate: RegionsServiceDelegate?
    public var visitDelegate: VisitServiceDelegate?
    
    public init(locationManger: LocationManagerProtocol?) {
        
        super.init()
        
        self.locationManager = locationManger
        guard var myLocationManager = self.locationManager else {
            return
        }
        
        myLocationManager.allowsBackgroundLocationUpdates = true
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        myLocationManager.distanceFilter = 10
        myLocationManager.pausesLocationUpdatesAutomatically = true
        myLocationManager.delegate = self
    }
    
    func requestAuthorization () {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    func setRegionDelegate(delegate: RegionsServiceDelegate) {
        self.regionDelegate = delegate
        if (self.locationManager?.monitoredRegions != nil) {
            delegate.updateRegions(regions: (self.locationManager?.monitoredRegions)!)
        }
        
    }
    
    public func startUpdatingLocation() {
        self.requestAuthorization()
        self.locationManager?.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
    }
    
    public func startMonitoringSignificantLocationChanges() {
        self.requestAuthorization()
        self.locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        self.locationManager?.stopMonitoringSignificantLocationChanges()
    }
    
    
    func stopMonitoringCurrentRegions() {
        if (self.locationManager?.monitoredRegions != nil) {
            for region in (self.locationManager?.monitoredRegions)! {
                self.locationManager?.stopMonitoring(for: region)
            }
        }
    }
    
    func startMonitoringCurrentRegions(regions: Set<CLRegion>) {
        self.requestAuthorization()
        for region in regions {
            self.locationManager?.startMonitoring(for: region)
        }
        self.regionDelegate?.updateRegions(regions: (self.locationManager?.monitoredRegions)!)
    }
    
    public func updateRegionMonitoring () {
        if (self.lastLocation != nil ) {
            self.stopUpdatingLocation()
            self.stopMonitoringCurrentRegions()
            self.startMonitoringCurrentRegions(regions: RegionsGenerator().generateRegionsFrom(location: self.lastLocation!))
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard locations.last != nil else {
            return
        }
        
        self.stopUpdatingLocation()
        updateLocation(locations: locations)
        self.updateRegionMonitoring()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateLocationDidFailWithError(error: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("=>>>>> exit ")
        print(region.description)
        self.handleRegionChange()
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("=>>>>> enter ")
        print(region.description)
        self.handleRegionChange()
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        self.startMonitoringSignificantLocationChanges()
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        self.regionDelegate?.updateRegions(regions: (self.locationManager?.monitoredRegions)!)
    }
    
    func updateVisit(visit: WGSVisit) {
        guard let delegate = self.visitDelegate else {
            return
        }
        if(visit.currentLocation!.horizontalAccuracy < accuracyVisitFilter ) {
            delegate.processVisit(visit: visit)
        }
    }
    
    public func updateLocation(locations: [CLLocation]){
        guard let delegate = self.locationServiceDelegate else {
            return
        }
        
        let location = locations.last!
        
        
        if (self.lastLocation != nil ) {
            
            let theLastLocation = self.lastLocation!
            
            let timeEllapsed = abs(locations.last!.timestamp.seconds(from: theLastLocation.timestamp))
            
            if (theLastLocation.distance(from: location) < currentLocationDistanceFilter && timeEllapsed < currentLocationTimeFilter) {
                return
            }
            
            if (timeEllapsed < 2 && locations.last!.horizontalAccuracy >= theLastLocation.horizontalAccuracy) {
                return
            }
        }
        
        
        if (visitEnable) {
            visitsDetectionAlgo(newLocation: location)
        }
        
        //create Location ID
        let locationId = UUID().uuidString
        delegate.tracingLocation(locations: locations, locationId: locationId)
        self.beforeLastLocation = lastLocation
        self.lastLocation = location
        searchAPIRequest(locationId:locationId)
    }
    
    func visitsDetectionAlgo(newLocation: CLLocation) {
        
        if(currentVisit != nil) {
            // Visit is active
            if (currentVisit!.endTime == nil) {
                let distance = currentVisit!.currentLocation?.distance(from: newLocation)
                let accuracy = newLocation.horizontalAccuracy
                // Test if we are still in visit
                if (distance! <= accuracy * 2) {
                    //if new position accuracy is better than the visit, we do an Update
                    if (currentVisit!.currentLocation!.horizontalAccuracy >= newLocation.horizontalAccuracy) {
                        currentVisit!.currentLocation = lastLocation
                    }
                    currentVisit!.nbPoint! += 1
                    print("if we are still in visit")
                    print("Distance " + String(distance!))
                    return
                }
                //Visit out
                else {
                    //Close the current visit
                    currentVisit!.endTime = lastLocation?.timestamp
                    print("visit out")
                    //print(currentVisit!.endTime)
                    updateVisit(visit: currentVisit!)
                }
            }
        }
        
        if(lastLocation == nil || beforeLastLocation == nil){
            return
        }
        
        let distance = lastLocation!.distance(from: newLocation)
        print("distance " + String(distance))
        NSLog("=>>>Distance last position and current position : \(distance)")
        if (distance >= distanceDetectionThresholdVisits) {
            print("We're Moving")
            currentVisit = nil
        } else { //Create a new visit
            let distanceVisit = beforeLastLocation?.distance(from: newLocation)
            print("distanceVisit " + String(distanceVisit!))
            if (distanceVisit! <= distanceDetectionThresholdVisits) {
                // less than distance of dectection visit of before last position, they are a visit
                currentVisit = WGSVisit()
                currentVisit!.uuid = UUID().uuidString
                currentVisit!.currentLocation = beforeLastLocation
                currentVisit!.startTime = beforeLastLocation!.timestamp
                currentVisit!.endTime = nil
                currentVisit!.nbPoint = 3
                print("Create new Visit")
            }
        }
        
    }
    
    func searchAPIRequest(locationId: String){
        guard let delegate = self.searchAPIDataDelegate else {
            return
        }
        
        
        if (self.lastSearchLocation != nil ) {
            
            let theLastSearchLocation = self.lastSearchLocation!
            
            let timeEllapsed = abs(lastLocation!.timestamp.seconds(from: theLastSearchLocation.timestamp))
            
            if (lastSearchLocation!.distance(from: lastLocation!) < searchAPIDistanceFilter ) {
                return
            }
            
            if timeEllapsed < searchAPITimeFilter {
                return
            }
            
            if (timeEllapsed < 2 && lastSearchLocation!.horizontalAccuracy >= lastSearchLocation!.horizontalAccuracy) {
                return
            }
        }
        
        
        // Get POI nearest
        // Get the current coordiante
        let userLatitude: String = String(format: "%f", lastLocation!.coordinate.latitude)
        let userLongitude: String = String(format:"%f", lastLocation!.coordinate.longitude)
        let storeAPIUrl: String = String(format: searchWoosmapAPI,userLatitude,userLongitude)
        let url = URL(string: storeAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
        // Call API search
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if (response.statusCode != 200) {
                    NSLog("statusCode: \(response.statusCode)")
                    delegate.serachAPIError(error:"Error Search API " + String(response.statusCode))
                    return
                }
                if let error = error {
                    NSLog("error: \(error)")
                } else {
                    let responseJSON = try? JSONDecoder().decode(SearchAPIData.self, from: data!)
                    delegate.searchAPIResponseData(searchAPIData: responseJSON!, locationId: locationId)
                    self.lastSearchLocation = self.lastLocation
                }
            }
        }
        task.resume()
        
    }
    
    public func tracingLocationDidFailWithError(error: Error){
        print("\(error)")
    }
    
    public func updateLocationDidFailWithError(error: Error) {
        
        guard let delegate = self.locationServiceDelegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error: error)
    }
    
    public func handleRegionChange() {
        self.lastRegionUpdate = Date()
        self.stopMonitoringCurrentRegions()
        self.startUpdatingLocation()
        self.startMonitoringSignificantLocationChanges()
    }
    
}
