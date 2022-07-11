//
//  WoosmapGeofencing.swift
//  WoosmapGeofencing

import Foundation
import AdSupport
import CoreLocation
import RealmSwift
@objcMembers public class WoosmapGeofencingEn: NSObject {
    public var locationService: LocationService!
    public var sphericalMercator: SphericalMercator!
    public var visitPoint: LoadedVisit!
    var locationManager: CLLocationManager?

    /**
     Access singleton of Now object
     */
    public static let shared: WoosmapGeofencingEn = {
        let instance = WoosmapGeofencingEn()
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
            self.locationService = LocationServiceImpl(locationManger: self.locationManager)
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
    
    public func setSFMCCredentials(credentials : [String: String]) {
        SFMCCredentials = credentials
    }
    
    public func setPoiRadius(radius: Any) {
        poiRadius = radius
    }
    
    public var OptimizeDistanceRequest: Bool {
        get {
            return optimizeDistanceRequest
        }
        set {
            optimizeDistanceRequest = newValue
        }
    }
}

extension WoosmapGeofencingEn {
    
    public func startTracking(configurationProfile: ConfigurationProfile){
        
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: configurationProfile.rawValue, withExtension: ".json") else {
            print(["Error: \(configurationProfile.rawValue) profil loading"])
            return
        }
        do {
            let jsonData = try Data(contentsOf: url)
            let object = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0))
            let test = try! validateSchema(object, schema: TRACKING_SCHEMA as [String: Any])
            if(test.valid == false) {
                for reason in test.errors! {
                    print("Geofencing SDK - profil: " + reason.instanceLocation.path + " - " + reason.description)
                }
                return
            }
            
            let configJSON = try? JSONDecoder().decode(ConfigModel.self, from: jsonData)
            setTrackingEnable(enable: configJSON?.trackingEnable ?? false)
            setModeHighfrequencyLocation(enable: configJSON?.modeHighFrequencyLocation ?? false)

            setWoosmapAPIKey(key: configJSON?.woosmapKey ?? WoosmapAPIKey)
            setVisitEnable(enable: configJSON?.visitEnable ?? visitEnable)
            setClassification(enable: configJSON?.classificationEnable ?? classificationEnable)
            setRadiusDetectionClassifiedZOI(radius: configJSON?.radiusDetectionClassifiedZOI ?? radiusDetectionClassifiedZOI)
            setCreationOfZOIEnable(enable: configJSON?.creationOfZOIEnable ?? creationOfZOIEnable)
            setAccuracyVisitFilter(accuracy: configJSON?.accuracyVisitFilter ?? accuracyVisitFilter)

            setCurrentPositionFilter(distance: configJSON?.currentLocationDistanceFilter ?? currentLocationDistanceFilter, time: Int(configJSON?.currentLocationTimeFilter ?? Double(currentLocationTimeFilter)))
            
            if let searchAPI = configJSON?.searchAPI {
                setSearchAPIRequestEnable(enable: searchAPI.searchAPIEnable ?? searchAPIRequestEnable)
                setSearchAPICreationRegionEnable(enable: searchAPI.searchAPICreationRegionEnable ?? searchAPICreationRegionEnable)
                setSearchAPIFilter(distance: Double(searchAPI.searchAPIDistanceFilter ?? Int(searchAPIDistanceFilter)), time: Int(searchAPI.searchAPITimeFilter ?? searchAPITimeFilter))
                setSearchAPIRefreshDelayDay(day: Int(searchAPI.searchAPIRefreshDelayDay ?? searchAPIRefreshDelayDay))
                if let paramArray = searchAPI.searchAPIParameters {
                    for param in paramArray {
                        searchAPIParameters.updateValue(param.value!, forKey: param.key!)
                    }
                }
            }
        
            if let distanceConfig = configJSON?.distance {
                setDistanceProvider(provider: DistanceProvider(rawValue: (distanceConfig.distanceProvider)!) ?? distanceProvider)
                setDistanceAPIRequestEnable(enable: configJSON?.distanceAPIEnable ?? distanceAPIRequestEnable)
                setDistanceAPIMode(mode: DistanceMode(rawValue: (distanceConfig.distanceMode)!) ?? distanceMode)
                setDistanceAPIUnits(units: DistanceUnits(rawValue: (distanceConfig.distanceUnits)!) ?? distanceUnits)
                setTrafficDistanceAPIRouting(routing: TrafficDistanceRouting(rawValue: (distanceConfig.distanceRouting)!) ?? trafficDistanceRouting)
                setDistanceAPILanguage(language: distanceConfig.distanceLanguage ?? distanceLanguage)
                setDistanceMaxAirDistanceFilter(distance: distanceConfig.distanceMaxAirDistanceFilter ?? distanceMaxAirDistanceFilter)
                setDistanceTimeFilter(time: distanceConfig.distanceTimeFilter ?? distanceTimeFilter)
            }
            else {
                setDistanceProvider(provider:distanceProvider)
                setDistanceAPIRequestEnable(enable: distanceAPIRequestEnable)
                setDistanceAPIMode(mode: distanceMode)
                setDistanceAPIUnits(units: distanceUnits)
                setTrafficDistanceAPIRouting(routing: trafficDistanceRouting)
                setDistanceAPILanguage(language: distanceLanguage)
                setDistanceMaxAirDistanceFilter(distance:  distanceMaxAirDistanceFilter)
                setDistanceTimeFilter(time: distanceTimeFilter)
            }
            
            if let SFMC = configJSON?.sfmcCredentials {
                SFMCCredentials.updateValue(SFMC.authenticationBaseURI!, forKey: "authenticationBaseURI")
                SFMCCredentials.updateValue(SFMC.restBaseURI!, forKey: "restBaseURI")
                SFMCCredentials.updateValue(SFMC.client_id!, forKey: "client_id")
                SFMCCredentials.updateValue(SFMC.client_secret!, forKey: "client_secret")
                
                SFMCCredentials.updateValue(SFMC.regionEnteredEventDefinitionKey ?? "", forKey: "regionEnteredEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.regionExitedEventDefinitionKey ?? "", forKey: "regionExitedEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.poiEventDefinitionKey ?? "", forKey: "poiEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.zoiClassifiedEnteredEventDefinitionKey ?? "", forKey: "zoiClassifiedEnteredEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.zoiClassifiedExitedEventDefinitionKey ?? "", forKey: "zoiClassifiedExitedEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.visitEventDefinitionKey ?? "", forKey: "visitEventDefinitionKey")
            }

            
            outOfTimeDelay = configJSON?.outOfTimeDelay ?? outOfTimeDelay
            dataDurationDelay = configJSON?.dataDurationDelay ?? dataDurationDelay
            
        } catch { print(error) }
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
            let test = try validateSchema(object, schema: TRACKING_SCHEMA)
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

            setWoosmapAPIKey(key: configJSON?.woosmapKey ?? WoosmapAPIKey)
            setVisitEnable(enable: configJSON?.visitEnable ?? visitEnable)
            setClassification(enable: configJSON?.classificationEnable ?? classificationEnable)
            setRadiusDetectionClassifiedZOI(radius: configJSON?.radiusDetectionClassifiedZOI ?? radiusDetectionClassifiedZOI)
            setCreationOfZOIEnable(enable: configJSON?.creationOfZOIEnable ?? creationOfZOIEnable)
            setAccuracyVisitFilter(accuracy: configJSON?.accuracyVisitFilter ?? accuracyVisitFilter)

            setCurrentPositionFilter(distance: configJSON?.currentLocationDistanceFilter ?? currentLocationDistanceFilter, time: Int(configJSON?.currentLocationTimeFilter ?? Double(currentLocationTimeFilter)))
            
            if let searchAPI = configJSON?.searchAPI {
                setSearchAPIRequestEnable(enable: searchAPI.searchAPIEnable ?? searchAPIRequestEnable)
                setSearchAPICreationRegionEnable(enable: searchAPI.searchAPICreationRegionEnable ?? searchAPICreationRegionEnable)
                setSearchAPIFilter(distance: Double(searchAPI.searchAPIDistanceFilter ?? Int(searchAPIDistanceFilter)), time: Int(searchAPI.searchAPITimeFilter ?? searchAPITimeFilter))
                setSearchAPIRefreshDelayDay(day: Int(searchAPI.searchAPIRefreshDelayDay ?? searchAPIRefreshDelayDay))
                if let paramArray = searchAPI.searchAPIParameters {
                    for param in paramArray {
                        searchAPIParameters.updateValue(param.value!, forKey: param.key!)
                    }
                }
            }
        
            if let distanceConfig = configJSON?.distance {
                setDistanceProvider(provider: DistanceProvider(rawValue: (distanceConfig.distanceProvider)!) ?? distanceProvider)
                setDistanceAPIRequestEnable(enable: configJSON?.distanceAPIEnable ?? distanceAPIRequestEnable)
                setDistanceAPIMode(mode: DistanceMode(rawValue: (distanceConfig.distanceMode)!) ?? distanceMode)
                setDistanceAPIUnits(units: DistanceUnits(rawValue: (distanceConfig.distanceUnits)!) ?? distanceUnits)
                setTrafficDistanceAPIRouting(routing: TrafficDistanceRouting(rawValue: (distanceConfig.distanceRouting)!) ?? trafficDistanceRouting)
                setDistanceAPILanguage(language: distanceConfig.distanceLanguage ?? distanceLanguage)
                setDistanceMaxAirDistanceFilter(distance: distanceConfig.distanceMaxAirDistanceFilter ?? distanceMaxAirDistanceFilter)
                setDistanceTimeFilter(time: distanceConfig.distanceTimeFilter ?? distanceTimeFilter)
            }
            else {
                setDistanceProvider(provider:distanceProvider)
                setDistanceAPIRequestEnable(enable: distanceAPIRequestEnable)
                setDistanceAPIMode(mode: distanceMode)
                setDistanceAPIUnits(units: distanceUnits)
                setTrafficDistanceAPIRouting(routing: trafficDistanceRouting)
                setDistanceAPILanguage(language: distanceLanguage)
                setDistanceMaxAirDistanceFilter(distance:  distanceMaxAirDistanceFilter)
                setDistanceTimeFilter(time: distanceTimeFilter)
            }
            
            if let SFMC = configJSON?.sfmcCredentials {
                SFMCCredentials.updateValue(SFMC.authenticationBaseURI!, forKey: "authenticationBaseURI")
                SFMCCredentials.updateValue(SFMC.restBaseURI!, forKey: "restBaseURI")
                SFMCCredentials.updateValue(SFMC.client_id!, forKey: "client_id")
                SFMCCredentials.updateValue(SFMC.client_secret!, forKey: "client_secret")
                
                SFMCCredentials.updateValue(SFMC.regionEnteredEventDefinitionKey ?? "", forKey: "regionEnteredEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.regionExitedEventDefinitionKey ?? "", forKey: "regionExitedEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.poiEventDefinitionKey ?? "", forKey: "poiEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.zoiClassifiedEnteredEventDefinitionKey ?? "", forKey: "zoiClassifiedEnteredEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.zoiClassifiedExitedEventDefinitionKey ?? "", forKey: "zoiClassifiedExitedEventDefinitionKey")
                SFMCCredentials.updateValue(SFMC.visitEventDefinitionKey ?? "", forKey: "visitEventDefinitionKey")
            }

            
            outOfTimeDelay = configJSON?.outOfTimeDelay ?? outOfTimeDelay
            dataDurationDelay = configJSON?.dataDurationDelay ?? dataDurationDelay

        } catch {
            return(false, ["Geofencing SDK - Custom profil: " + error.localizedDescription])
            
        }
        return (true,[""])
    }
}
