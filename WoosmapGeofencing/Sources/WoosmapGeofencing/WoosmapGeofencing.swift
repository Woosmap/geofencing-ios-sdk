
import Foundation
import AdSupport
import CoreLocation

/**
 WoosmapGeofencing main class. Cannot be instanciated, use `shared` property to access singleton
 */
@objcMembers public class WoosmapGeofencing: NSObject {
    
    public var locationService : LocationService!
    public var sphericalMercator : SphericalMercator!
    public var visitPoint : LoadedVisit!
    var locationManager: CLLocationManager? = CLLocationManager()
    
    
    /**
     Access singleton of Now object
     */
    public static let shared: WoosmapGeofencing = {
        let instance = WoosmapGeofencing()
        return instance
    }()
    
    private override init () {
        super.init()
        self.initServices()
        
    }
    
    public func getLocationService() -> LocationService {
        return locationService
    }
    
    public func getSphericalMercator() -> SphericalMercator {
        return sphericalMercator
    }
    
    public func getVisitPoint() -> LoadedVisit {
        return visitPoint
    }
    
    public func initServices() {
        if self.locationService == nil {
            self.locationService = LocationService(locationManger: self.locationManager)
        }
    }
    
    public func setTrackingEnable(enable: Bool) {
        if (enable != getTrackingState()) {
            trackingEnable = enable
            trackingChanged(tracking: trackingEnable)
        }
    }
    
    public func getTrackingState() -> Bool {
        return trackingEnable
    }
    
    public func setWoosmapAPIKey(key: String) {
        searchWoosmapKey = key
    }
    
    public func setGMPAPIKey(key: String) {
        GoogleStaticMapKey = key
    }
    
    public func setSearchWoosmapAPI(api: String) {
        searchWoosmapAPI = api
    }
    
    public func setCurrentPositionFilter(distance: Double, time: Int) {
        currentLocationDistanceFilter = distance
        currentLocationTimeFilter = time
    }
    
    public func setSearchAPIRequestEnable(enable: Bool) {
        if (enable != getSearchAPIRequestEnable()) {
            searchAPIRequestEnable = enable
        }
    }
    
    public func getSearchAPIRequestEnable() -> Bool {
        return searchAPIRequestEnable
    }
    
    public func setSearchAPIFilter(distance: Double, time: Int) {
        searchAPIDistanceFilter = distance
        searchAPITimeFilter = time
    }
    
    public func setVisitEnable(enable: Bool) {
        visitEnable = enable
    }
    
    public func setAccuracyVisitFilter(accuracy:Double) {
        accuracyVisitFilter = accuracy
    }
    
    public func setClassification(enable: Bool) {
        classificationEnable = enable
    }
       
    public func startMonitoringInForeGround() {
        if self.locationService == nil  {
            return
        }
        self.locationService?.startUpdatingLocation()
    }
    
    /**
     Call this method from the DidFinishLaunchWithOptions method of your App Delegate
     */
    public func startMonitoringInBackground() {
        if self.locationService == nil  {
            NSLog("WoosmapGeofencing is not initiated")
            return
        }
        self.locationService?.startUpdatingLocation()
        self.locationService?.startMonitoringSignificantLocationChanges()
    }
    
    /**
     Call this method from the applicationDidBecomeActive method of your App Delegate
     */
    public func didBecomeActive() {
        if self.locationService == nil  {
            NSLog("WoosmapGeofencing is not initiated")
            return
        }
        self.startMonitoringInBackground()
    }
    
    public func trackingChanged(tracking: Bool) {
        if !tracking {
            self._stopAllMonitoring()
        } else {
            self.locationService?.locationManager = CLLocationManager()
            self.locationService?.locationManager?.allowsBackgroundLocationUpdates = true
            self.locationService?.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.locationService?.locationManager?.distanceFilter = 10
            self.locationService?.locationManager?.pausesLocationUpdatesAutomatically = true

            self.locationService?.startUpdatingLocation()
            self.locationService?.startMonitoringSignificantLocationChanges()
        }
    }
    
    func _stopAllMonitoring() {
        self.locationService.stopUpdatingLocation()
        self.locationService.stopMonitoringCurrentRegions()
        self.locationService.stopMonitoringSignificantLocationChanges()
        self.locationService.locationManager = nil
        self.locationService.locationManager?.delegate = nil
    }
    
    func _logDenied() {
        self._stopAllMonitoring()
        NSLog("User has activated DNT")
    }
    
}
