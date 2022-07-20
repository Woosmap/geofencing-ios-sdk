import Foundation
import AdSupport
import CoreLocation
import RealmSwift

/**
 WoosmapGeofencingCore main class. Cannot be instanciated, use `shared` property to access singleton
 */
@objcMembers public class WoosmapGeofencingCore: NSObject {

    public var locationService: LocationService!
    public var sphericalMercator: SphericalMercator!
    public var visitPoint: LoadedVisit!
    var locationManager: CLLocationManager?

    /**
     Access singleton of Now object
     */
    public static let shared: WoosmapGeofencingCore = {
        let instance = WoosmapGeofencingCore()
        return instance
    }()

    private override init () {
        super.init()
        self.initServices()
        self.initRealm()
    }
    
    private func initRealm() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 10)
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
            self.locationService = LocationServiceCoreImpl(locationManger: self.locationManager)
        }
    }

    public func setTrackingEnable(enable: Bool) {
        if enable != getTrackingState() {
            trackingEnable = enable
            setModeHighfrequencyLocation(enable: false)
            trackingChanged(tracking: trackingEnable)
        }
    }

    public func getTrackingState() -> Bool {
        return trackingEnable
    }

    public func setWoosmapAPIKey(key: String) {
        WoosmapAPIKey = key
    }

    public func setGMPAPIKey(key: String) {
        GoogleStaticMapKey = key
    }

    public func setSearchWoosmapAPI(api: String) {
        searchWoosmapAPI = api
    }

    public func setDistanceWoosmapAPI(api: String) {
        distanceWoosmapAPI = api
    }
    
    public func setTrafficDistanceWoosmapAPI(api: String) {
        trafficDistanceWoosmapAPI = api
    }
    
    public func setDistanceProvider(provider: DistanceProvider) {
        if(provider != DistanceProvider.woosmapDistance || provider != DistanceProvider.woosmapTraffic){
            distanceProvider = provider
        }else {
            distanceProvider = DistanceProvider.woosmapDistance
        }
    }

    public func setDistanceAPIMode(mode: DistanceMode) {
        if(mode != DistanceMode.driving || mode != DistanceMode.cycling || mode != DistanceMode.truck || mode != DistanceMode.walking) {
            distanceMode = mode
        } else {
            distanceMode = DistanceMode.driving
        }
    }
    
    public func setTrafficDistanceAPIRouting(routing: TrafficDistanceRouting) {
        if(trafficDistanceRouting != TrafficDistanceRouting.fastest || trafficDistanceRouting != TrafficDistanceRouting.balanced) {
            trafficDistanceRouting = routing
        }else {
            trafficDistanceRouting = TrafficDistanceRouting.fastest
        }
    }
    
    public func setDistanceAPIUnits(units: DistanceUnits) {
        if(units != DistanceUnits.metric || units != DistanceUnits.imperial) {
            distanceUnits = units
        }else {
            distanceUnits = DistanceUnits.metric
        }
    }
    
    public func setDistanceAPILanguage(language: String) {
        distanceLanguage = language
    }
    
    public func setDistanceMaxAirDistanceFilter(distance: Int) {
        distanceMaxAirDistanceFilter = distance
    }
    
    public func setDistanceTimeFilter(time: Int) {
        distanceTimeFilter = time
    }

    public func setCurrentPositionFilter(distance: Double, time: Int) {
        currentLocationDistanceFilter = distance
        currentLocationTimeFilter = time
    }

    public func setSearchAPIRequestEnable(enable: Bool) {
        if enable != getSearchAPIRequestEnable() {
            searchAPIRequestEnable = enable
        }
    }

    public func getSearchAPIRequestEnable() -> Bool {
        return searchAPIRequestEnable
    }
    
    public func getSearchAPILastRequestTimeStamp() -> Double {
        return searchAPILastRequestTimeStamp
    }
    

    public func setDistanceAPIRequestEnable(enable: Bool) {
        if enable != getDistanceAPIRequestEnable() {
            distanceAPIRequestEnable = enable
        }
    }

    public func getDistanceAPIRequestEnable() -> Bool {
        return distanceAPIRequestEnable
    }
    

    public func getSearchAPIRefreshDelayDay() -> Int {
        return searchAPIRefreshDelayDay
    }

    public func setVisitEnable(enable: Bool) {
        visitEnable = enable
    }
    
    public func getVisitEnable() -> Bool {
        return visitEnable
    }

    public func setAccuracyVisitFilter(accuracy: Double) {
        accuracyVisitFilter = accuracy
    }

    public func setCreationOfZOIEnable(enable: Bool) {
        creationOfZOIEnable = enable
    }

    public func setClassification(enable: Bool) {
        classificationEnable = enable
    }
    
    public func setRadiusDetectionClassifiedZOI(radius: Double) {
        radiusDetectionClassifiedZOI = radius
    }

    public func startMonitoringInForeGround() {
        if self.locationService == nil {
            return
        }
        self.locationService?.startUpdatingLocation()
    }

    /**
     Call this method from the DidFinishLaunchWithOptions method of your App Delegate
     */
    public func startMonitoringInBackground() {
        if self.locationService == nil {
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
        if self.locationService == nil {
            NSLog("WoosmapGeofencing is not initiated")
            return
        }
        let userDataCleaner = DataCleaner()
        userDataCleaner.cleanOldGeographicData()
        self.startMonitoringInBackground()
    }

    public func trackingChanged(tracking: Bool) {
        if !tracking {
            self._stopAllMonitoring()
        } else {
            self.locationService?.locationManager = CLLocationManager()
            self.locationService?.initLocationManager()
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
    
    public func setModeHighfrequencyLocation(enable: Bool) {
        modeHighfrequencyLocation = enable
        
        if (modeHighfrequencyLocation == true) {
            self.locationService?.startUpdatingLocation()
            setSearchAPIRequestEnable(enable: false)
            setDistanceAPIRequestEnable(enable: false)
            setClassification(enable: false)
            self.locationService?.removeRegions(type: RegionType.position)
        } else {
            self.locationService?.stopUpdatingLocation()
            self.locationService?.startUpdatingLocation()
        }
    }
    
    public func getModeHighfrequencyLocation() -> Bool {
        return modeHighfrequencyLocation
    }
    
    public func refreshLocation(allTime: Bool) {
        self.locationService?.startUpdatingLocation()
        if(allTime){
            modeHighfrequencyLocation = true
        }
        
    }
    
    public func setSearchAPIParameters(parameters : [String: String]) {
        searchAPIParameters = parameters
    }
    
    public func setUserPropertiesFilter(properties : [String]) {
        userPropertiesFilter = properties
    }
        
}

extension WoosmapGeofencingCore {
    
    
}
