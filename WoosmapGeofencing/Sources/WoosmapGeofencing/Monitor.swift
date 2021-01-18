import Foundation
import CoreLocation
import UserNotifications

public protocol LocationServiceDelegate {
    func tracingLocation(locations: [CLLocation], locationId: String)
    func tracingLocationDidFailWithError(error: Error)
}

public protocol SearchAPIDelegate {
    func searchAPIResponseData(searchAPIData: SearchAPIData, locationId: String)
    func serachAPIError(error: String)
}

public protocol DistanceAPIDelegate {
    func distanceAPIResponseData(distanceAPIData: DistanceAPIData, locationId: String)
    func distanceAPIError(error: String)
}

public protocol RegionsServiceDelegate {
    func updateRegions(regions: Set<CLRegion>)
    func didEnterPOIRegion(POIregion: CLRegion )
    func didExitPOIRegion(POIregion: CLRegion )
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
    public enum regionType : String {
        case POSITION_REGION
        case CUSTOM_REGION
        case POI_REGION
        case NONE
    }
    
    public var locationManager: LocationManagerProtocol?
    var currentLocation: CLLocation?
    var lastSearchLocation: CLLocation?
    var lastRegionUpdate: Date?
    
    public var locationServiceDelegate: LocationServiceDelegate?
    public var searchAPIDataDelegate: SearchAPIDelegate?
    public var distanceAPIDataDelegate: DistanceAPIDelegate?
    public var regionDelegate: RegionsServiceDelegate?
    public var visitDelegate: VisitServiceDelegate?
    
    init(locationManger: LocationManagerProtocol?) {
        
        super.init()
        
        self.locationManager = locationManger
        initLocationManager()
        
    }
    
    func initLocationManager() {
        
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
        if visitEnable {
            self.locationManager?.startMonitoringVisits()
        }
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
                if(getRegionType(identifier: region.identifier) == regionType.POSITION_REGION) {
                    self.locationManager?.stopMonitoring(for: region)
                }
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
        if( (getRegionType(identifier: region.identifier) == regionType.CUSTOM_REGION) || (getRegionType(identifier: region.identifier) == regionType.POI_REGION))  {
            self.regionDelegate?.didExitPOIRegion(POIregion: region)
        }
        self.handleRegionChange()
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if( (getRegionType(identifier: region.identifier) == regionType.CUSTOM_REGION) || (getRegionType(identifier: region.identifier) == regionType.POI_REGION))  {
            self.regionDelegate?.didEnterPOIRegion(POIregion: region)
        }
        self.handleRegionChange()
    }
    
    public func addRegion(identifier: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) -> (isCreate : Bool, identifier: String) {
        if (self.locationManager?.monitoredRegions != nil) {
            if ((self.locationManager?.monitoredRegions.count)! < 20) {
                let id = regionType.CUSTOM_REGION.rawValue + "_" + identifier
                self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: radius, identifier: id ))
                return (true,regionType.CUSTOM_REGION.rawValue + "_" + identifier)
            } else {
                return (false,"")
            }
        }
        return (false,"")
    }
    
    public func removeRegion(center: CLLocationCoordinate2D) {
        if (self.locationManager?.monitoredRegions != nil) {
            for region in (self.locationManager?.monitoredRegions)! {
                let latRegion = (region as! CLCircularRegion).center.latitude
                let lngRegion = (region as! CLCircularRegion).center.longitude
                if (center.latitude == latRegion && center.longitude == lngRegion){
                    self.locationManager?.stopMonitoring(for: region)
                    self.handleRegionChange()
                }
            }
        }
    }
    
    public func removeRegions(type: regionType) {
        if (self.locationManager?.monitoredRegions != nil) {
            if(regionType.NONE == type) {
                for region in (self.locationManager?.monitoredRegions)! {
                    if(!region.identifier.contains(regionType.POSITION_REGION.rawValue)){
                        self.locationManager?.stopMonitoring(for: region)
                    }
                }
            } else {
                for region in (self.locationManager?.monitoredRegions)! {
                    if(region.identifier.contains(type.rawValue)){
                        self.locationManager?.stopMonitoring(for: region)
                    }
                }
            }
        }
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
        if(visit.horizontalAccuracy < accuracyVisitFilter ) {
            delegate.processVisit(visit: visit)
        }
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
        let locationId = UUID().uuidString
        delegate.tracingLocation(locations: locations, locationId: locationId)
        self.currentLocation = location
        
        if (searchAPIRequestEnable) {
            searchAPIRequest(location: currentLocation!, locationId:locationId)
        }
        
    }
    
    public func searchAPIRequest(location: CLLocation, locationId: String = ""){
        guard let delegate = self.searchAPIDataDelegate else {
            return
        }
        
        
        if (self.lastSearchLocation != nil && locationId.isEmpty ) {
            
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
        let userLatitude: String = String(format: "%f", location.coordinate.latitude)
        let userLongitude: String = String(format:"%f", location.coordinate.longitude)
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
                    
                    for feature in (responseJSON?.features)! {
                        let latitude = (feature.geometry?.coordinates![1])!
                        let longitude = (feature.geometry?.coordinates![0])!
                        if (distanceAPIRequestEnable) {
                            self.distanceAPIRequest(locationOrigin: location, coordinatesDest: [(latitude,longitude)],locationId: locationId)
                        }
                        if(searchAPICreationRegionEnable){
                            let POIname = (feature.properties?.store_id)! + "_" + (feature.properties?.name)!
                            self.createRegionPOI(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), name: POIname)
                        }
                    }
                }
            }
        }
        task.resume()
        
    }
    
    public func createRegionPOI(center: CLLocationCoordinate2D, name: String){
        var POIRegionExist = false
        if (self.locationManager?.monitoredRegions != nil) {
            for region in (self.locationManager?.monitoredRegions)! {
                let latRegion = (region as! CLCircularRegion).center.latitude
                let lngRegion = (region as! CLCircularRegion).center.longitude
                if (center.latitude == latRegion && center.longitude == lngRegion){
                    POIRegionExist = true
                }
            }
        }
        if(!POIRegionExist){
            if (self.locationManager?.monitoredRegions != nil) {
                for region in (self.locationManager?.monitoredRegions)! {
                    if( (getRegionType(identifier: region.identifier) == regionType.POI_REGION))  {
                        self.locationManager?.stopMonitoring(for: region)
                    }
                }
            }
            let identifier = regionType.POI_REGION.rawValue + "_" + name
            self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: CLLocationDistance(firstSearchAPIRegionRadius), identifier: identifier + " - " + String(firstSearchAPIRegionRadius) + " m"))
            self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: CLLocationDistance(secondSearchAPIRegionRadius), identifier: identifier + " - " + String(secondSearchAPIRegionRadius) + " m"))
            self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: CLLocationDistance(thirdSearchAPIRegionRadius), identifier: identifier + " - " + String(thirdSearchAPIRegionRadius) + " m"))
        }
    }
    
    public func distanceAPIRequest(locationOrigin: CLLocation, coordinatesDest: [(Double,Double)], locationId: String = "") {
        
        guard let delegate = self.distanceAPIDataDelegate else {
            return
        }
        
        let userLatitude: String = String(format: "%f", locationOrigin.coordinate.latitude)
        let userLongitude: String = String(format:"%f", locationOrigin.coordinate.longitude)
        var coordinateDest = ""
        for coordinate in coordinatesDest {
            let destLatitude: String = String(format:"%f", Double(coordinate.0))
            let destLongitude: String = String(format:"%f",  Double(coordinate.1))
            coordinateDest += destLatitude + "," + destLongitude
            if(coordinatesDest.last! != coordinate){
                coordinateDest += "|"
            }
        }
        
        let storeAPIUrl: String = String(format: distanceWoosmapAPI,userLatitude,userLongitude,coordinateDest)
        let url = URL(string: storeAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    
        // Call API search
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if (response.statusCode != 200) {
                    NSLog("statusCode: \(response.statusCode)")
                    delegate.distanceAPIError(error:"Error Distance API " + String(response.statusCode))
                    return
                }
                if let error = error {
                    NSLog("error: \(error)")
                } else {
                    let responseJSON = try? JSONDecoder().decode(DistanceAPIData.self, from: data!)
                    delegate.distanceAPIResponseData(distanceAPIData: responseJSON!, locationId: locationId)
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
    
    public func getRegionType(identifier: String) -> regionType {
        if (identifier.contains(regionType.POSITION_REGION.rawValue)) {
            return regionType.POSITION_REGION
        } else if (identifier.contains(regionType.CUSTOM_REGION.rawValue)) {
            return regionType.CUSTOM_REGION
        } else if (identifier.contains(regionType.POI_REGION.rawValue)) {
            return regionType.POI_REGION
        }
        return regionType.NONE
    }
    
}
