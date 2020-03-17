import Foundation
import CoreLocation

public protocol LocationServiceDelegate {
    func tracingLocation(locations: [CLLocation], locationId: UUID)
    func tracingLocationDidFailWithError(error: Error)
}

public protocol SearchAPIDelegate {
    func searchAPIResponseData(searchAPIData: SearchAPIData, locationId: UUID)
    func serachAPIError(error: String)
}

public protocol RegionsServiceDelegate {
    func updateRegions(regions: Set<CLRegion>)
}

public protocol VisitServiceDelegate {
    func processVisit(visit: CLVisit)
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
    func startMonitoringVisits()
}

extension CLLocationManager: LocationManagerProtocol {}

public class LocationService: NSObject, CLLocationManagerDelegate {
    
    public var locationManager: LocationManagerProtocol?
    var currentLocation: CLLocation?
    var lastSearchLocation: CLLocation?
    var lastRegionUpdate: Date?
    
    public var locationServiceDelegate: LocationServiceDelegate?
    public var searchAPIDataDelegate: SearchAPIDelegate?
    public var regionDelegate: RegionsServiceDelegate?
    public var visitDelegate: VisitServiceDelegate?
    
    init(locationManger: LocationManagerProtocol?) {
        
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
        if visitEnable {
            myLocationManager.startMonitoringVisits()
        }
        
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
    
    func startUpdatingLocation() {
        self.requestAuthorization()
        self.locationManager?.startUpdatingLocation()
        self.locationManager?.startMonitoringVisits()
    }
    
    func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
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
    
    func updateRegionMonitoring () {
        if (self.currentLocation != nil ) {
            self.stopUpdatingLocation()
            self.stopMonitoringCurrentRegions()
            self.startMonitoringCurrentRegions(regions: RegionsGenerator().generateRegionsFrom(location: self.currentLocation!))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        updateVisit(visit: visit)
        self.startUpdatingLocation()
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
        self.handleRegionChange()
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.handleRegionChange()
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        self.startMonitoringSignificantLocationChanges()
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        self.regionDelegate?.updateRegions(regions: (self.locationManager?.monitoredRegions)!)
    }
    
    func updateVisit(visit: CLVisit) {
        guard let delegate = self.visitDelegate else {
            return
        }
        delegate.processVisit(visit: visit)
    }
    
    func updateLocation(locations: [CLLocation]){
        guard let delegate = self.locationServiceDelegate else {
            return
        }
        
        let location = locations.last!
        
        if (self.currentLocation != nil ) {

            let theLastLocation = self.currentLocation!
            
            let timeEllapsed = abs(locations.last!.timestamp.seconds(from: theLastLocation.timestamp))
            
            if (theLastLocation.distance(from: location) < currentLocationDistanceFilter && timeEllapsed < currentLocationTimeFilter) {
                return
            }
            
            if (timeEllapsed < 2 && locations.last!.horizontalAccuracy >= theLastLocation.horizontalAccuracy) {
                return
            }
        }
        //create Location ID
        let locationId = UUID()
        delegate.tracingLocation(locations: locations, locationId: locationId)
        self.currentLocation = location
        searchAPIRequest(locationId:locationId)
    }
    
    func searchAPIRequest(locationId: UUID){
        guard let delegate = self.searchAPIDataDelegate else {
            return
        }
        
        
        if (self.lastSearchLocation != nil ) {
            
            let theLastSearchLocation = self.lastSearchLocation!
            
            let timeEllapsed = abs(currentLocation!.timestamp.seconds(from: theLastSearchLocation.timestamp))
            
            if (lastSearchLocation!.distance(from: currentLocation!) < searchAPIDistanceFilter ) {
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
        let userLatitude: String = String(format: "%f", currentLocation!.coordinate.latitude)
        let userLongitude: String = String(format:"%f", currentLocation!.coordinate.longitude)
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
                    self.lastSearchLocation = self.currentLocation
                }
            }
        }
        task.resume()
        
    }
   
    public func tracingLocationDidFailWithError(error: Error){
        print("\(error)")
    }
    
    func updateLocationDidFailWithError(error: Error) {
        
        guard let delegate = self.locationServiceDelegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error: error)
    }
    
    func handleRegionChange() {
        self.lastRegionUpdate = Date()
        self.stopMonitoringCurrentRegions()
        self.startUpdatingLocation()
        self.startMonitoringSignificantLocationChanges()
    }

}
