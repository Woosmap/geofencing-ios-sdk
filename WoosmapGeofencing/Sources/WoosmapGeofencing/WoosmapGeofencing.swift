import Foundation
import AdSupport
import CoreLocation
import RealmSwift
import JSONSchema

/**
 WoosmapGeofencing main class. Cannot be instanciated, use `shared` property to access singleton
 */
@objcMembers public class WoosmapGeofencing: NSObject {

    public var locationService: LocationService!
    public var sphericalMercator: SphericalMercator!
    public var visitPoint: LoadedVisit!
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
        self.initRealm()
    }
    
    private func initRealm() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 3)
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

    public func setSearchAPICreationRegionEnable(enable: Bool) {
        if enable != getSearchAPICreationRegionEnable() {
            searchAPICreationRegionEnable = enable
        }
    }
    public func getSearchAPICreationRegionEnable() -> Bool {
        return searchAPICreationRegionEnable
    }
    
    public func setSearchAPILastRequestTimeStamp(time: Double) {
        searchAPILastRequestTimeStamp = time
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

    public func setSearchAPIFilter(distance: Double, time: Int) {
        searchAPIDistanceFilter = distance
        searchAPITimeFilter = time
    }
    
    public func setSearchAPIRefreshDelayDay(day: Int) {
        searchAPIRefreshDelayDay = day
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
            setSearchAPICreationRegionEnable(enable: false)
            self.locationService?.removeRegions(type: LocationService.RegionType.position)
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
    
    public func setSFMCCredentials(credentials : [String: String]) {
        SFMCCredentials = credentials
    }
    
    public func setPoiRadius(radius: Any) {
        poiRadius = radius
    }
    
    public func stopTracking() {
        trackingEnable = false
        setModeHighfrequencyLocation(enable: false)
        trackingChanged(tracking: trackingEnable)
    }
    
    
    public func startCustomTracking(url:String) -> (status: Bool, errors: [String]) {
        guard let myURL = URL(string: url) else {
                return (false,["Error: \(url) doesn't seem to be a valid URL"])
            }
        
        do {
            let jsonData = try Data(contentsOf: myURL)
            let object = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0))
            let test = try validate(object, schema: TRACKING_SCHEMA)
            if(test.valid == false) {
                var errors:[String] = []
                for reason in test.errors! {
                    errors.append("Geofencing SDK - Custom profil: " + reason.instanceLocation.path + " - " + reason.description)
                }
                return (false, errors)
            }
            let configJSON = try? JSONDecoder().decode(ConfigModel.self, from: jsonData)
            setTrackingEnable(enable: configJSON?.trackingEnable ?? false)
            setModeHighfrequencyLocation(enable: configJSON?.modeHighFrequencyLocation ?? false)

            setVisitEnable(enable: configJSON?.visitEnable ?? false)
            setClassification(enable: configJSON?.classificationEnable ?? false)
            setRadiusDetectionClassifiedZOI(radius: configJSON?.radiusDetectionClassifiedZOI ?? 100.0)
            setCreationOfZOIEnable(enable: configJSON?.creationOfZOIEnable ?? false)
            setAccuracyVisitFilter(accuracy: configJSON?.accuracyVisitFilter ?? 50.0)

            setCurrentPositionFilter(distance: configJSON?.currentLocationDistanceFilter ?? 0, time: Int(configJSON?.currentLocationTimeFilter ?? 0))

            setSearchAPIRequestEnable(enable: configJSON?.searchAPI?.searchAPIEnable ?? false)
            setSearchAPICreationRegionEnable(enable: configJSON?.searchAPI?.searchAPICreationRegionEnable ?? false)
            setSearchAPIFilter(distance: Double(configJSON?.searchAPI?.searchAPIDistanceFilter ?? 0), time: Int(configJSON?.searchAPI?.searchAPITimeFilter ?? 0))
            setSearchAPIRefreshDelayDay(day: Int(configJSON?.searchAPI?.searchAPIRefreshDelayDay ?? 1))

            if let distanceConfig = configJSON?.distance {
                setDistanceProvider(provider: DistanceProvider(rawValue: (distanceConfig.distanceProvider)!) ?? DistanceProvider.woosmapDistance)
                setDistanceAPIRequestEnable(enable: configJSON?.distanceAPIEnable ?? false)
                setDistanceAPIMode(mode: DistanceMode(rawValue: (distanceConfig.distanceMode)!) ?? DistanceMode.driving)
                setDistanceAPIUnits(units: DistanceUnits(rawValue: (distanceConfig.distanceUnits)!) ?? DistanceUnits.metric)
                setTrafficDistanceAPIRouting(routing: TrafficDistanceRouting(rawValue: (distanceConfig.distanceRouting)!) ?? TrafficDistanceRouting.fastest)
                setDistanceAPILanguage(language: distanceConfig.distanceLanguage ?? "en")
                setDistanceMaxAirDistanceFilter(distance: distanceConfig.distanceMaxAirDistanceFilter ?? 1000000)
                setDistanceTimeFilter(time: distanceConfig.distanceTimeFilter ?? 0)
            }
            else {
                setDistanceProvider(provider: DistanceProvider(rawValue: DistanceProvider.woosmapDistance.rawValue)!)
                setDistanceAPIRequestEnable(enable: false)
                setDistanceAPIMode(mode: DistanceMode(rawValue: DistanceMode.driving.rawValue)!)
                setDistanceAPIUnits(units: DistanceUnits(rawValue: DistanceUnits.metric.rawValue)!)
                setTrafficDistanceAPIRouting(routing: TrafficDistanceRouting(rawValue:  TrafficDistanceRouting.fastest.rawValue)!)
                setDistanceAPILanguage(language: "en")
                setDistanceMaxAirDistanceFilter(distance:  1000000)
                setDistanceTimeFilter(time: 0)
            }

            
            outOfTimeDelay = configJSON?.outOfTimeDelay ?? 300
            dataDurationDelay = configJSON?.dataDurationDelay ?? 30

        } catch {
            return(false, ["Geofencing SDK - Custom profil: " + error.localizedDescription])
            
        }
        return (true,[""])
    }
    
    public func startTracking(configurationProfile: ConfigurationProfile){
        
        let bundle = Bundle(for: Self.self)
        let url = bundle.url(forResource: configurationProfile.rawValue, withExtension: ".json")
        do {
            let jsonData = try Data(contentsOf: url!)
            let object = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0))
            let test = try! validate(object, schema: TRACKING_SCHEMA)
            if(test.valid == false) {
                for reason in test.errors! {
                    print("Geofencing SDK - profil: " + reason.instanceLocation.path + " - " + reason.description)
                }
                return
            }
            let configJSON = try? JSONDecoder().decode(ConfigModel.self, from: jsonData)
            setTrackingEnable(enable: configJSON?.trackingEnable ?? false)
            setModeHighfrequencyLocation(enable: configJSON?.modeHighFrequencyLocation ?? false)

            setVisitEnable(enable: configJSON?.visitEnable ?? false)
            setClassification(enable: configJSON?.classificationEnable ?? false)
            setRadiusDetectionClassifiedZOI(radius: configJSON?.radiusDetectionClassifiedZOI ?? 100.0)
            setCreationOfZOIEnable(enable: configJSON?.creationOfZOIEnable ?? false)
            setAccuracyVisitFilter(accuracy: configJSON?.accuracyVisitFilter ?? 50.0)

            setCurrentPositionFilter(distance: configJSON?.currentLocationDistanceFilter ?? 0, time: Int(configJSON?.currentLocationTimeFilter ?? 0))

            setSearchAPIRequestEnable(enable: configJSON?.searchAPI?.searchAPIEnable ?? false)
            setSearchAPICreationRegionEnable(enable: configJSON?.searchAPI?.searchAPICreationRegionEnable ?? false)
            setSearchAPIFilter(distance: Double(configJSON?.searchAPI?.searchAPIDistanceFilter ?? 0), time: Int(configJSON?.searchAPI?.searchAPITimeFilter ?? 0))
            setSearchAPIRefreshDelayDay(day: Int(configJSON?.searchAPI?.searchAPIRefreshDelayDay ?? 1))
            
            if let distanceConfig = configJSON?.distance {
                setDistanceProvider(provider: DistanceProvider(rawValue: (distanceConfig.distanceProvider)!) ?? DistanceProvider.woosmapDistance)
                setDistanceAPIRequestEnable(enable: configJSON?.distanceAPIEnable ?? false)
                setDistanceAPIMode(mode: DistanceMode(rawValue: (distanceConfig.distanceMode)!) ?? DistanceMode.driving)
                setDistanceAPIUnits(units: DistanceUnits(rawValue: (distanceConfig.distanceUnits)!) ?? DistanceUnits.metric)
                setTrafficDistanceAPIRouting(routing: TrafficDistanceRouting(rawValue: (distanceConfig.distanceRouting)!) ?? TrafficDistanceRouting.fastest)
                setDistanceAPILanguage(language: distanceConfig.distanceLanguage ?? "en")
                setDistanceMaxAirDistanceFilter(distance: distanceConfig.distanceMaxAirDistanceFilter ?? 1000000)
                setDistanceTimeFilter(time: distanceConfig.distanceTimeFilter ?? 0)
            }
            else {
                setDistanceProvider(provider: DistanceProvider(rawValue: DistanceProvider.woosmapDistance.rawValue)!)
                setDistanceAPIRequestEnable(enable: false)
                setDistanceAPIMode(mode: DistanceMode(rawValue: DistanceMode.driving.rawValue)!)
                setDistanceAPIUnits(units: DistanceUnits(rawValue: DistanceUnits.metric.rawValue)!)
                setTrafficDistanceAPIRouting(routing: TrafficDistanceRouting(rawValue:  TrafficDistanceRouting.fastest.rawValue)!)
                setDistanceAPILanguage(language: "en")
                setDistanceMaxAirDistanceFilter(distance:  1000000)
                setDistanceTimeFilter(time: 0)
            }

            
            outOfTimeDelay = configJSON?.outOfTimeDelay ?? 300
            dataDurationDelay = configJSON?.dataDurationDelay ?? 30
            
        } catch { print(error) }
    }


}
let TRACKING_SCHEMA: [String: Any] = {
    let bundle = Bundle(identifier: "WebGeoServices.WoosmapGeofencing")
    let url = bundle!.url(forResource: "TrackingSchema", withExtension: ".json")
    let jsonData = try! Data(contentsOf: url!)
    let object = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0))
      return object as! [String: Any]
}()
