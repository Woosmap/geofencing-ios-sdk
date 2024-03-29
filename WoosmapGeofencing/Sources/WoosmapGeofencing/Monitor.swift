import Foundation
import CoreLocation
import UserNotifications

public protocol LocationServiceDelegate: AnyObject {
    func tracingLocation(location: Location)
    func tracingLocationDidFailWithError(error: Error)
}

public protocol SearchAPIDelegate: AnyObject {
    func searchAPIResponse(poi: POI)
    func serachAPIError(error: String)
}

public protocol DistanceAPIDelegate: AnyObject {
    func distanceAPIResponse(distance: [Distance])
    func distanceAPIError(error: String)
}

public protocol RegionsServiceDelegate: AnyObject {
    func updateRegions(regions: Set<CLRegion>)
    func didEnterPOIRegion(POIregion: Region)
    func didExitPOIRegion(POIregion: Region)
    func workZOIEnter(classifiedRegion: Region)
    func homeZOIEnter(classifiedRegion: Region)
    
    
}

public protocol VisitServiceDelegate: AnyObject {
    func processVisit(visit: Visit)
}

public protocol AirshipEventsDelegate: AnyObject {
    func poiEvent(POIEvent: Dictionary <String, Any>, eventName: String)
    func regionEnterEvent(regionEvent: Dictionary <String, Any>, eventName: String)
    func regionExitEvent(regionEvent: Dictionary <String, Any>, eventName: String)
    func visitEvent(visitEvent: Dictionary <String, Any>, eventName: String)
    func ZOIclassifiedEnter(regionEvent: Dictionary <String, Any>, eventName: String)
    func ZOIclassifiedExit(regionEvent: Dictionary <String, Any>, eventName: String)
}

public protocol MarketingCloudEventsDelegate: AnyObject {
    func poiEvent(POIEvent: Dictionary <String, Any>, eventName: String)
    func regionEnterEvent(regionEvent: Dictionary <String, Any>, eventName: String)
    func regionExitEvent(regionEvent: Dictionary <String, Any>, eventName: String)
    func visitEvent(visitEvent: Dictionary <String, Any>, eventName: String)
    func ZOIclassifiedEnter(regionEvent: Dictionary <String, Any>, eventName: String)
    func ZOIclassifiedExit(regionEvent: Dictionary <String, Any>, eventName: String)
}


public extension Date {
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}

public protocol LocationManagerProtocol {
    var desiredAccuracy: CLLocationAccuracy { get set }
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
    public enum RegionType: String {
        case position
        case custom
        case poi
        case none
    }

    public var locationManager: LocationManagerProtocol?
    var currentLocation: CLLocation?
    var lastSearchLocation: CLLocation?
    var lastRegionUpdate: Date?

    public weak var locationServiceDelegate: LocationServiceDelegate?
    public weak var searchAPIDataDelegate: SearchAPIDelegate?
    public weak var distanceAPIDataDelegate: DistanceAPIDelegate?
    public weak var regionDelegate: RegionsServiceDelegate?
    public weak var visitDelegate: VisitServiceDelegate?
    public weak var airshipEventsDelegate: AirshipEventsDelegate?
    public weak var marketingCloudEventsDelegate: MarketingCloudEventsDelegate?

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
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        delegate.updateRegions(regions: monitoredRegions)
    }

    func startUpdatingLocation() {
        self.requestAuthorization()
        self.locationManager?.startUpdatingLocation()
        if visitEnable {
            self.locationManager?.startMonitoringVisits()
        }
    }

    func stopUpdatingLocation() {
        if (!modeHighfrequencyLocation) {
            self.locationManager?.stopUpdatingLocation()
        }
    }

    func startMonitoringSignificantLocationChanges() {
        self.requestAuthorization()
        self.locationManager?.startMonitoringSignificantLocationChanges()
    }

    func stopMonitoringSignificantLocationChanges() {
        self.locationManager?.stopMonitoringSignificantLocationChanges()
    }

    func stopMonitoringCurrentRegions() {
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        for region in monitoredRegions {
            if getRegionType(identifier: region.identifier) == RegionType.position {
                self.locationManager?.stopMonitoring(for: region)
            }
        }
    }

    func startMonitoringCurrentRegions(regions: Set<CLRegion>) {
        self.requestAuthorization()
        for region in regions {
            self.locationManager?.startMonitoring(for: region)
        }
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        self.regionDelegate?.updateRegions(regions: monitoredRegions)
    }

    func updateRegionMonitoring () {
        if self.currentLocation != nil {
            self.stopUpdatingLocation()
            self.stopMonitoringCurrentRegions()
            if(!modeHighfrequencyLocation) {
                self.startMonitoringCurrentRegions(regions: RegionsGenerator().generateRegionsFrom(location: self.currentLocation!))
            }
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
        if (modeHighfrequencyLocation) {
            self.handleRegionChange()
            return
        }
        if  (getRegionType(identifier: region.identifier) == RegionType.custom) || (getRegionType(identifier: region.identifier) == RegionType.poi) {
            addRegionLogTransition(region: region, didEnter: false,fromPositionDetection: false)
        }
        self.handleRegionChange()
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if (modeHighfrequencyLocation) {
            self.handleRegionChange()
            return
        }
        if  (getRegionType(identifier: region.identifier) == RegionType.custom) || (getRegionType(identifier: region.identifier) == RegionType.poi) {
            addRegionLogTransition(region: region, didEnter: true, fromPositionDetection: false)
        }
        self.handleRegionChange()
    }

    public func addRegion(identifier: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) -> Bool {
        guard let monitoredRegions = locationManager?.monitoredRegions else { return false }
        
        if (monitoredRegions.count < 20) {
            let id = RegionType.custom.rawValue + "<id>" + identifier
            self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: radius, identifier: id ))
            checkIfUserIsInRegion(region: CLCircularRegion(center: center, radius: radius, identifier: id ))
            return true
        } else {
            return false
        }
    }
    
    public func removeRegion(identifier: String) {
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        for region in monitoredRegions {
            if (region.identifier == identifier) {
                self.locationManager?.stopMonitoring(for: region)
                self.handleRegionChange()
            }
        }
    }
    
    public func addRegion(identifier: String, center: CLLocationCoordinate2D, radius: Int, type: String) -> (isCreate: Bool, identifier: String){
        if(type == "isochrone"){
            let regionIsCreated = addRegionIsochrone(identifier: identifier, center: center, radius: radius)
            return (regionIsCreated, identifier)
        } else if(type == "circle"){
            let regionIsCreated = addRegion(identifier: identifier, center: center, radius: Double(radius))
            return (regionIsCreated, identifier)
        }
        return (false, "the type is incorrect")
    }
    
    public func addRegionIsochrone(identifier: String, center: CLLocationCoordinate2D, radius: Int) -> Bool  {
        if (RegionIsochrones.getRegionFromId(id: identifier) != nil) {
            print("Identifier already exist")
            return false
        }
        
        let regionIso = RegionIsochrone()
        regionIso.identifier = identifier
        regionIso.date = Date()
        regionIso.latitude = center.latitude
        regionIso.longitude = center.longitude
        regionIso.radius = radius
        regionIso.type = "isochrone"
        RegionIsochrones.add(regionIsochrone: regionIso)
        
        return true
    }
    
    public func removeRegionIsochrone(identifier: String) {
        RegionIsochrones.removeRegionIsochrone(id: identifier)
    }

    public func removeRegion(center: CLLocationCoordinate2D) {
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        for region in monitoredRegions {
            let latRegion = (region as! CLCircularRegion).center.latitude
            let lngRegion = (region as! CLCircularRegion).center.longitude
            if center.latitude == latRegion && center.longitude == lngRegion {
                self.locationManager?.stopMonitoring(for: region)
                self.handleRegionChange()
            }
        }
    }

    public func removeRegions(type: RegionType) {
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        if RegionType.none == type {
            for region in monitoredRegions {
                if !region.identifier.contains(RegionType.position.rawValue) {
                    self.locationManager?.stopMonitoring(for: region)
                }
            }
        } else {
            for region in monitoredRegions {
                if region.identifier.contains(type.rawValue) {
                    self.locationManager?.stopMonitoring(for: region)
                }
            }
        }
        self.handleRegionChange()
    }
    
    public func checkIfUserIsInRegion(region: CLCircularRegion) {
        guard let location = currentLocation else { return }
        if(region.contains(location.coordinate)) {
            let regionEnter = Regions.add(POIregion: region, didEnter: true, fromPositionDetection: true)
            sendASRegionEvents(region: regionEnter)
            self.regionDelegate?.didEnterPOIRegion(POIregion: regionEnter)
        }
    }

    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        self.startMonitoringSignificantLocationChanges()
    }

    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        self.regionDelegate?.updateRegions(regions: monitoredRegions)
    }

    func updateVisit(visit: CLVisit) {
        guard let delegate = self.visitDelegate else {
            return
        }
        if visit.horizontalAccuracy < accuracyVisitFilter {
            detectVisitInZOIClassified(visit: visit)
            let visitRecorded = Visits.add(visit: visit)
            if visitRecorded.visitId != nil {
                delegate.processVisit(visit: visitRecorded)
                sendASVisitEvents(visit: visitRecorded)
            }
        }
    }

    func updateLocation(locations: [CLLocation]) {
        guard let delegate = self.locationServiceDelegate else {
            return
        }

        let location = locations.last!

        if self.currentLocation != nil {

            let theLastLocation = self.currentLocation!

            let timeEllapsed = abs(locations.last!.timestamp.seconds(from: theLastLocation.timestamp))

            if theLastLocation.distance(from: location) < currentLocationDistanceFilter && timeEllapsed < currentLocationTimeFilter {
                return
            }

            if timeEllapsed < 2 && locations.last!.horizontalAccuracy >= theLastLocation.horizontalAccuracy {
                return
            }
        }
        // Save in database
        let locationSaved = Locations.add(locations: locations)

        if locationSaved.locationId == nil {
            return
        }

        // Retrieve location
        delegate.tracingLocation(location: locationSaved)

        self.currentLocation = location

        if searchAPIRequestEnable {
            searchAPIRequest(location: currentLocation!, locationId: locationSaved.locationId!)
        }
        
        checkIfPositionIsInsideGeofencingRegions(location: location)
        
        detectRegionIsochrone(location: location, locationId: locationSaved.locationId!)

    }

    public func searchAPIRequest(location: CLLocation, locationId: String = "") {
        guard let delegate = self.searchAPIDataDelegate else {
            return
        }
        
        if(WoosmapAPIKey.isEmpty) {
            return
        }
        
        let lastPOI = POIs.getAll().last

        if lastPOI != nil && !locationId.isEmpty && lastSearchLocation != nil {
            if(searchAPILastRequestTimeStamp > lastPOI!.date!.timeIntervalSince1970) {
                if ((searchAPILastRequestTimeStamp - lastPOI!.date!.timeIntervalSince1970) < Double(searchAPIRefreshDelayDay*3600*24)) {
                    return
                }
            }
            
            let timeEllapsed = abs(currentLocation!.timestamp.seconds(from: lastPOI!.date!))
        
            if (timeEllapsed < searchAPIRefreshDelayDay*3600*24) {
                let distanceLimit = lastPOI!.distance - lastPOI!.radius
                let distanceTraveled = lastSearchLocation!.distance(from: currentLocation!)
                
                if distanceTraveled < distanceLimit {
                    return
                }
                
                if distanceTraveled < searchAPIDistanceFilter {
                    return
                }

                if timeEllapsed < searchAPITimeFilter {
                   return
                }
            }
                                                             
        }

        // Get POI nearest
        // Get the current coordiante
        let userLatitude: String = String(format: "%f", location.coordinate.latitude)
        let userLongitude: String = String(format: "%f", location.coordinate.longitude)
        let storeAPIUrl: String = String(format: searchWoosmapAPI, userLatitude, userLongitude)
        
        var components = URLComponents(string: storeAPIUrl)!

        for (key, value) in searchAPIParameters {
            if(key == "stores_by_page") {
               let storesByPage =  Int(value) ?? 0
                if (storesByPage > 5){
                    components.queryItems?.append(URLQueryItem(name: "stores_by_page", value: "5" ))
                } else {
                    components.queryItems?.append(URLQueryItem(name: "stores_by_page", value: value ))
                }
            } else {
                components.queryItems?.append(URLQueryItem(name: key, value: value ))
            }
        }
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let url = URLRequest(url: components.url!)

        // Call API search
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    NSLog("statusCode: \(response.statusCode)")
                    delegate.serachAPIError(error: "Error Search API " + String(response.statusCode))
                    return
                }
                if let error = error {
                    NSLog("error: \(error)")
                } else {
                    let pois = POIs.addFromResponseJson(searchAPIResponse: data!, locationId: locationId)

                    if(pois.isEmpty) {
                        searchAPILastRequestTimeStamp = Date().timeIntervalSince1970
                        return
                    }
                    
                    for poi in pois {
                        self.sendASPOIEvents(poi: poi)
                        delegate.searchAPIResponse(poi: poi)

                        if distanceAPIRequestEnable {
                            self.calculateDistance(locationOrigin: location, coordinatesDest:[(poi.latitude, poi.longitude)], locationId: locationId)
                        }
                        if searchAPICreationRegionEnable {
                            let POIname = (poi.idstore ?? "")  + "<id>" + (poi.name ?? "")
                            self.createRegionPOI(center: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude), name: POIname, radius: poi.radius)
                        }
                    }
                    self.removeOldPOIRegions(newPOIS: pois)
                    self.lastSearchLocation = self.currentLocation
                }
            }
        }
        task.resume()

    }
    

    public func createRegionPOI(center: CLLocationCoordinate2D, name: String, radius: Double) {
        let identifier = RegionType.poi.rawValue + "<id>" + name
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        var exist = false
        for region in monitoredRegions {
            if (region.identifier.contains(identifier)) {
               exist = true
            }
        }
        if !exist {
            self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: CLLocationDistance(radius), identifier: identifier + " - " + String(radius) + " m"))
            checkIfUserIsInRegion(region:  CLCircularRegion(center: center, radius: CLLocationDistance(radius), identifier: identifier + " - " + String(radius) + " m"))
        }
    }
    
    public func removeOldPOIRegions(newPOIS: [POI]) {
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        for region in monitoredRegions {
            var exist = false
            for poi in newPOIS {
                let identifier = "<id>" + (poi.idstore ?? "") + "<id>" + (poi.name ?? "")
                if (region.identifier.contains(identifier)) {
                    exist = true
                }
            }
            if(!exist) {
                if region.identifier.contains(LocationService.RegionType.poi.rawValue) {
                    self.locationManager?.stopMonitoring(for: region)
                }
            }
        }
    }

    public func calculateDistance(locationOrigin: CLLocation,
                                  coordinatesDest: [(Double, Double)],
                                  distanceProvider : DistanceProvider = distanceProvider,
                                  distanceMode: DistanceMode = distanceMode,
                                  distanceUnits: DistanceUnits = distanceUnits,
                                  distanceLanguage: String = distanceLanguage,
                                  trafficDistanceRouting: TrafficDistanceRouting = trafficDistanceRouting,
                                  locationId: String = "",
                                  regionIsochroneToUpdate: Bool = false) {

        guard let delegateDistance = self.distanceAPIDataDelegate else {
            return
        }

        let userLatitude: String = String(format: "%f", locationOrigin.coordinate.latitude)
        let userLongitude: String = String(format: "%f", locationOrigin.coordinate.longitude)
        var coordinatesDestList: [String] = []
        coordinatesDest.forEach { item in
            coordinatesDestList.append("\(item.0),\(item.1)")
        }
        let coordinateDestinations = coordinatesDestList.joined(separator: "|")
        
        var storeAPIUrl = ""
        if(distanceProvider == DistanceProvider.woosmapDistance) {
            storeAPIUrl = String(format: distanceWoosmapAPI, distanceMode.rawValue, distanceUnits.rawValue, distanceLanguage, userLatitude, userLongitude, coordinateDestinations)
        } else {
            storeAPIUrl = String(format: trafficDistanceWoosmapAPI, distanceMode.rawValue, distanceUnits.rawValue,trafficDistanceRouting.rawValue,distanceLanguage, userLatitude, userLongitude, coordinateDestinations)
        }
        
        let url = URL(string: storeAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
        // Call API Distance
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        delegateDistance.distanceAPIError(error: "Error Distance API " + String(response.statusCode))
                        return
                    }
                    if let error = error {
                        NSLog("error: \(error)")
                    } else {
                        let distance = Distances.addFromResponseJson(APIResponse: data!,
                                                                     locationId: locationId,
                                                                     origin: locationOrigin,
                                                                     destination: coordinatesDest,
                                                                     distanceProvider: distanceProvider,
                                                                     distanceMode: distanceMode,
                                                                     distanceUnits: distanceUnits,
                                                                     distanceLanguage: distanceLanguage,
                                                                     trafficDistanceRouting: trafficDistanceRouting)
                                                                    
                        
                        if (regionIsochroneToUpdate) {
                            self?.updateRegionWithDistance(distanceAr: distance)
                        }
                        
                        delegateDistance.distanceAPIResponse(distance: distance)
                        
                        if(locationId != "" && !distance.isEmpty) {
                            guard let delegateSearch = self?.searchAPIDataDelegate else {
                                return
                            }
                            if let calculatedDistance = distance.first {
                                let distanceValue = calculatedDistance.distance
                                let duration = calculatedDistance.durationText ?? ""
                                let poiUpdated = POIs.updatePOIWithDistance(distance: Double(distanceValue), duration: duration, locationId: locationId)
                                if poiUpdated.locationId != nil {
                                    delegateSearch.searchAPIResponse(poi: poiUpdated)
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        task.resume()

    }
    
    public func updateRegionWithDistance(distanceAr: [Distance]) {
        var regionIsoTodelete:[String] = []
        for regionIso in RegionIsochrones.getAll() {
            for distance in distanceAr {
                if(distance.destinationLatitude == regionIso.latitude && distance.destinationLongitude == regionIso.longitude) {
                    if(distance.status != "OK"){
                        print("Respone status = " + (distance.status ?? "NOK") + " Region Isochrone " + regionIso.identifier! + " is delete")
                        regionIsoTodelete.append(regionIso.identifier!)
                    }else {
                        var didEnter = regionIso.didEnter
                        let lastStatedidEnter = regionIso.didEnter
                        if(distance.duration <= regionIso.radius) {
                            if(regionIso.didEnter == false) {
                                didEnter = true
                                
                            }
                        } else {
                            if(regionIso.didEnter == true) {
                                didEnter = false
                            }
                        }
                        let regionUpdated = RegionIsochrones.updateRegion(id: regionIso.identifier!, didEnter: didEnter, distanceInfo: distance)
                        if(regionUpdated.didEnter != lastStatedidEnter) {
                            didEventRegionIsochrone(regionIsochrone: regionUpdated)
                        }
                    }
                }
            }
        }
        
        for regionIsoIdentifer in regionIsoTodelete {
            RegionIsochrones.removeRegionIsochrone(id: regionIsoIdentifer)
        }
    }
    
    public func didEventRegionIsochrone(regionIsochrone: RegionIsochrone) {
        let newRegionLog = Regions.add(regionIso: regionIsochrone)
        sendASRegionEvents(region: newRegionLog)
        if newRegionLog.identifier != "" {
            if (newRegionLog.didEnter) {
                self.regionDelegate?.didEnterPOIRegion(POIregion: newRegionLog)
            } else {
                self.regionDelegate?.didExitPOIRegion(POIregion: newRegionLog)
            }
        }
    }
    
    public func tracingLocationDidFailWithError(error: Error) {
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

    public func getRegionType(identifier: String) -> RegionType {
        if identifier.contains(RegionType.position.rawValue) {
            return RegionType.position
        } else if identifier.contains(RegionType.custom.rawValue) {
            return RegionType.custom
        } else if identifier.contains(RegionType.poi.rawValue) {
            return RegionType.poi
        }
        return RegionType.none
    }
    
    func checkIfPositionIsInsideGeofencingRegions(location: CLLocation) {
        guard let monitoredRegions = locationManager?.monitoredRegions else { return }
        for region in monitoredRegions {
            if (!region.identifier.contains(RegionType.position.rawValue)) {
                let latRegion = (region as! CLCircularRegion).center.latitude
                let lngRegion = (region as! CLCircularRegion).center.longitude
                let distance = location.distance(from: CLLocation(latitude: latRegion, longitude: lngRegion)) - location.horizontalAccuracy
                if(distance < (region as! CLCircularRegion).radius) {
                    addRegionLogTransition(region: region, didEnter: true, fromPositionDetection: true)
                }else {
                    addRegionLogTransition(region: region, didEnter: false, fromPositionDetection: true)
                }
            }
        }
    }
    
    func addRegionLogTransition(region: CLRegion, didEnter: Bool, fromPositionDetection: Bool) {
        if let regionLog = Regions.getRegionFromId(id: region.identifier) {
            if (regionLog.date.timeIntervalSinceNow > -5) {
                return
            }
            if (regionLog.didEnter != didEnter) {
                let newRegionLog = Regions.add(POIregion: region, didEnter: didEnter, fromPositionDetection:fromPositionDetection)
                sendASRegionEvents(region: newRegionLog)
                if newRegionLog.identifier != "" {
                    if (didEnter) {
                        self.regionDelegate?.didEnterPOIRegion(POIregion: newRegionLog)
                    } else {
                        self.regionDelegate?.didExitPOIRegion(POIregion: newRegionLog)
                    }
                }
            }
        } else if (didEnter) {
            let newRegionLog = Regions.add(POIregion: region, didEnter: didEnter, fromPositionDetection:fromPositionDetection)
            if newRegionLog.identifier != "" {
                sendASRegionEvents(region: newRegionLog)
                if (didEnter) {
                    self.regionDelegate?.didEnterPOIRegion(POIregion: newRegionLog)
                } else {
                    self.regionDelegate?.didExitPOIRegion(POIregion: newRegionLog)
                }
            }
        }
    }
    
    func detectRegionIsochrone(location: CLLocation, locationId: String = "") {
        let regionsIsochrones = RegionIsochrones.getAll()
        var regionsBeUpdated = false
        for regionIso in regionsIsochrones {
            if regionIso.locationId == nil
            {
                regionsBeUpdated = true
            }
            let distance = location.distance(from: CLLocation(latitude: regionIso.latitude,
                                                              longitude: regionIso.longitude))
            if (distance < Double(distanceMaxAirDistanceFilter)) {
                let spendtime = -regionIso.date!.timeIntervalSinceNow
                let timeLimit = (regionIso.duration - regionIso.radius)/2
                if (spendtime > Double(timeLimit)) {
                    if(spendtime > Double(distanceTimeFilter)) {
                        regionsBeUpdated = true
                    }
                }
                else{
                    if (!optimizeDistanceRequest){
                        var distanceFromTheLastRefresh = Double(0)
                        if let regionIsoLocationId = regionIso.locationId
                        {
                            if let locationFromTheLastRefresh = Locations.getLocationFromId(id: regionIsoLocationId)
                                {
                                    distanceFromTheLastRefresh = location.distance(from: CLLocation(
                                        latitude:  locationFromTheLastRefresh.latitude,
                                        longitude: locationFromTheLastRefresh.longitude))
                                }
                        }
                        if (spendtime > 60){ //1 minute
                            let averageSpeed:Double = distanceFromTheLastRefresh/spendtime
                            let averageSpeedLimit:Double = regionIso.expectedAverageSpeed * 2
                            if(averageSpeed > averageSpeedLimit){
                                regionsBeUpdated = true
                            }
                        }
                    }
                }
            }
            if(regionsBeUpdated) {
                break
            }
        }
        
        if(regionsBeUpdated) {
            calculateDistanceWithRegion(location: location, locationId: locationId)
        }
    }
    
    func calculateDistanceWithRegion(location: CLLocation, locationId: String = "") {
        var dest:[(Double, Double)] = [(Double, Double)]()
        for regionIso in  RegionIsochrones.getAll() {
            dest.append((regionIso.latitude, regionIso.longitude))
        }
        calculateDistance(locationOrigin: location, coordinatesDest: dest, locationId: locationId, regionIsochroneToUpdate: true)
    }
        
       
    
    func detectVisitInZOIClassified(visit: CLVisit) {
        let visitLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        let classifiedZOIs = ZOIs.getWorkHomeZOI()
        let calendar = Calendar.current
        for classifiedZOI in classifiedZOIs {
            let sMercator = SphericalMercator()
            let latitude = sMercator.y2lat(aY: classifiedZOI.lngMean)
            let longitude = sMercator.x2lon(aX: classifiedZOI.latMean)
            let distance = visitLocation.distance(from: CLLocation(latitude: latitude, longitude: longitude))
            if(distance < radiusDetectionClassifiedZOI) {
                let classifiedRegion = Region()
                classifiedRegion.date = Date()
                if(calendar.component(.year, from: visit.departureDate) != 4001) {
                    classifiedRegion.didEnter = false
                } else {
                    classifiedRegion.didEnter = true
                }
                classifiedRegion.radius = radiusDetectionClassifiedZOI
                classifiedRegion.latitude = latitude
                classifiedRegion.longitude = longitude
                classifiedRegion.identifier = classifiedZOI.period ?? ""
                Regions.add(classifiedRegion: classifiedRegion)
                self.regionDelegate?.homeZOIEnter(classifiedRegion: classifiedRegion)
                sendASZOIClassifiedEvents(region: classifiedRegion)
            }
        }

    }
    // For test only
//    func detectLocationInZOIClassified(location: CLLocation, enter: Bool) {
//        let classifiedZOIs = ZOIs.getWorkHomeZOI()
//        for classifiedZOI in classifiedZOIs {
//            let sMercator = SphericalMercator()
//            let latitude = sMercator.y2lat(aY: classifiedZOI.lngMean)
//            let longitude = sMercator.x2lon(aX: classifiedZOI.latMean)
//            print(latitude)
//            print(longitude)
//            print(classifiedZOI.period!)
//            print("distance = ")
//
//            let distance = location.distance(from: CLLocation(latitude: latitude, longitude: longitude))
//            print(distance)
//            if(distance < radiusDetectionClassifiedZOI) {
//                let classifiedRegion = Region()
//                classifiedRegion.date = Date()
//                if(enter) {
//                    classifiedRegion.didEnter = true
//                } else {
//                    classifiedRegion.didEnter = false
//                }
//                classifiedRegion.radius = radiusDetectionClassifiedZOI
//                classifiedRegion.latitude = latitude
//                classifiedRegion.longitude = longitude
//                classifiedRegion.identifier = classifiedZOI.period
//                Regions.add(classifiedRegion: classifiedRegion)
//                self.regionDelegate?.homeZOIEnter(classifiedRegion: classifiedRegion)
//            }
//        }
//
//    }
    
    func sendASVisitEvents(visit: Visit) {
        
        var propertyDictionary = Dictionary <String, Any>()
        propertyDictionary["ContactKey"] = SFMCCredentials["contactKey"] ?? ""
        propertyDictionary["event"] = "woos_visit_event"
        propertyDictionary["date"] = visit.date?.stringFromDate()
        propertyDictionary["arrivalDate"] = visit.arrivalDate?.stringFromDate()
        propertyDictionary["departureDate"] = visit.departureDate?.stringFromDate()
        propertyDictionary["id"] = visit.visitId
        propertyDictionary["lat"] = visit.latitude
        propertyDictionary["lng"] = visit.longitude
        
        if let ASdelegate = self.airshipEventsDelegate {
            propertyDictionary["date"] = visit.date?.stringFromDate()
            ASdelegate.visitEvent(visitEvent: propertyDictionary, eventName: "woos_visit_event")
        }
        
        if let MCdelegate = self.marketingCloudEventsDelegate {
            propertyDictionary["date"] = visit.date?.stringFromISO8601Date()
            MCdelegate.visitEvent(visitEvent: propertyDictionary, eventName: "woos_visit_event")
        }
        
        if((SFMCCredentials["visitEventDefinitionKey"]) != nil) {
            propertyDictionary["date"] = visit.date?.stringFromISO8601Date()
            SFMCAPIclient.pushDataToMC(poiData: propertyDictionary,eventDefinitionKey: SFMCCredentials["visitEventDefinitionKey"]!)
        }
        
    }
    
    func sendASPOIEvents(poi: POI) {
        var propertyDictionary = Dictionary <String, Any>()
        propertyDictionary["ContactKey"] = SFMCCredentials["contactKey"] ?? ""
        propertyDictionary["event"] = "woos_poi_event"
        propertyDictionary["name"] = poi.name
        propertyDictionary["lat"] = poi.latitude
        propertyDictionary["lng"] = poi.longitude
        propertyDictionary["city"] = poi.city
        propertyDictionary["distance"] = poi.distance
        propertyDictionary["tags"] = poi.tags
        propertyDictionary["types"] = poi.types
        propertyDictionary["radius"] = poi.radius
        
        setDataFromPOI(poi: poi, propertyDictionary: &propertyDictionary)

        if let ASdelegate = self.airshipEventsDelegate {
            propertyDictionary["date"] = poi.date?.stringFromDate()
            ASdelegate.poiEvent(POIEvent: propertyDictionary, eventName: "woos_poi_event")
        }
        
        if let MCdelegate = self.marketingCloudEventsDelegate {
            propertyDictionary["date"] = poi.date?.stringFromISO8601Date()
            MCdelegate.poiEvent(POIEvent: propertyDictionary, eventName: "woos_poi_event")
        }
        
        if((SFMCCredentials["poiEventDefinitionKey"]) != nil) {
            propertyDictionary["date"] = poi.date?.stringFromISO8601Date()
            SFMCAPIclient.pushDataToMC(poiData: propertyDictionary,eventDefinitionKey: SFMCCredentials["poiEventDefinitionKey"]!)
        }
    }
    
    func sendASRegionEvents(region: Region) {
        var propertyDictionary = Dictionary <String, Any>()
        propertyDictionary["ContactKey"] = SFMCCredentials["contactKey"] ?? ""
        propertyDictionary["lat"] = region.latitude
        propertyDictionary["lng"] = region.longitude
        propertyDictionary["radius"] = region.radius
        
        if(region.origin == "POI") {
            guard let poi = POIs.getPOIbyIdStore(idstore: region.identifier) else {
                return
            }
            setDataFromPOI(poi: poi, propertyDictionary: &propertyDictionary)
        } else {
            propertyDictionary["id"] = region.identifier
        }
        
        if let ASdelegate = self.airshipEventsDelegate {
            propertyDictionary["date"] = region.date.stringFromDate()
            if(region.didEnter) {
                propertyDictionary["event"] = "woos_geofence_entered_event"
                ASdelegate.regionEnterEvent(regionEvent: propertyDictionary, eventName: "woos_geofence_entered_event")
            } else {
                propertyDictionary["event"] = "woos_geofence_exited_event"
                ASdelegate.regionExitEvent(regionEvent: propertyDictionary, eventName: "woos_geofence_exited_event")
            }
        }
        
        if let MCdelegate = self.marketingCloudEventsDelegate {
            propertyDictionary["date"] = region.date.stringFromISO8601Date()
            if(region.didEnter) {
                propertyDictionary["event"] = "woos_geofence_entered_event"
                MCdelegate.regionEnterEvent(regionEvent: propertyDictionary, eventName: "woos_geofence_entered_event")
            } else {
                propertyDictionary["event"] = "woos_geofence_exited_event"
                MCdelegate.regionExitEvent(regionEvent: propertyDictionary, eventName: "woos_geofence_exited_event")
            }
        }
        
        if((SFMCCredentials["regionEnteredEventDefinitionKey"]) != nil && region.didEnter) {
            propertyDictionary["date"] = region.date.stringFromISO8601Date()
            propertyDictionary["event"] = "woos_geofence_entered_event"
            SFMCAPIclient.pushDataToMC(poiData: propertyDictionary,eventDefinitionKey: SFMCCredentials["regionEnteredEventDefinitionKey"]!)
        }
        
        if((SFMCCredentials["regionExitedEventDefinitionKey"]) != nil && !region.didEnter) {
            propertyDictionary["date"] = region.date.stringFromISO8601Date()
            propertyDictionary["event"] = "woos_geofence_exited_event"
            SFMCAPIclient.pushDataToMC(poiData: propertyDictionary,eventDefinitionKey: SFMCCredentials["regionExitedEventDefinitionKey"]!)
        }
    }
    
    func setDataFromPOI(poi: POI, propertyDictionary: inout Dictionary <String, Any>) {
        let jsonStructure = try? JSONDecoder().decode(JSONAny.self, from:  poi.jsonData ?? Data.init())
        if let value = jsonStructure!.value as? [String: Any] {
            if let features = value["features"] as? [[String: Any]] {
                for feature in features {
                    if let properties = feature["properties"] as? [String: Any] {
                        let idstoreFromJson = properties["store_id"] as? String ?? ""
                        if let userProperties = properties["user_properties"] as? [String: Any] {
                            if (idstoreFromJson == poi.idstore) {
                                for (key, value) in userProperties {
                                      if(userPropertiesFilter.isEmpty || userPropertiesFilter.contains(key)) {
                                          propertyDictionary["user_properties_" + key] = value
                                      }
                                }
                            }
                        }
                    }
                }
            }
        }
        propertyDictionary["city"] = poi.city
        propertyDictionary["zipCode"] = poi.zipCode
        propertyDictionary["distance"] = poi.distance
        propertyDictionary["idStore"] = poi.idstore
        propertyDictionary["name"] = poi.name
        propertyDictionary["country_code"] = poi.countryCode
        propertyDictionary["tags"] = poi.tags
        propertyDictionary["types"] = poi.types
        propertyDictionary["address"] = poi.address
        propertyDictionary["contact"] = poi.contact
        propertyDictionary["openNow"] = poi.openNow
    }
    
    func sendASZOIClassifiedEvents(region: Region) {
        var propertyDictionary = Dictionary <String, Any>()
        propertyDictionary["ContactKey"] = SFMCCredentials["contactKey"] ?? ""
        propertyDictionary["id"] = region.identifier
        propertyDictionary["lat"] = region.latitude
        propertyDictionary["lng"] = region.longitude
        propertyDictionary["radius"] = region.radius
        
        if let ASdelegate = self.airshipEventsDelegate {
            propertyDictionary["date"] = region.date.stringFromDate()
            if(region.didEnter) {
                propertyDictionary["event"] = "woos_zoi_classified_entered_event"
                ASdelegate.ZOIclassifiedEnter(regionEvent: propertyDictionary, eventName: "woos_zoi_classified_entered_event")
            } else {
                propertyDictionary["event"] = "woos_zoi_classified_exited_event"
                ASdelegate.ZOIclassifiedExit(regionEvent: propertyDictionary, eventName: "woos_zoi_classified_exited_event")
            }
        }
        
        if let MCdelegate = self.marketingCloudEventsDelegate {
            propertyDictionary["date"] = region.date.stringFromISO8601Date()
            if(region.didEnter) {
                propertyDictionary["event"] = "woos_zoi_classified_entered_event"
                MCdelegate.ZOIclassifiedEnter(regionEvent: propertyDictionary, eventName: "woos_zoi_classified_entered_event")
            } else {
                propertyDictionary["event"] = "woos_zoi_classified_exited_event"
                MCdelegate.ZOIclassifiedExit(regionEvent: propertyDictionary, eventName: "woos_zoi_classified_exited_event")
            }
        }
        
        if((SFMCCredentials["zoiClassifiedEnteredEventDefinitionKey"]) != nil && region.didEnter) {
            propertyDictionary["date"] = region.date.stringFromISO8601Date()
            propertyDictionary["event"] = "woos_zoi_classified_entered_event"
            SFMCAPIclient.pushDataToMC(poiData: propertyDictionary,eventDefinitionKey: SFMCCredentials["zoiClassifiedEnteredEventDefinitionKey"]!)
        }
        
        if((SFMCCredentials["zoiClassifiedExitedEventDefinitionKey"]) != nil && !region.didEnter) {
            propertyDictionary["date"] = region.date.stringFromISO8601Date()
            propertyDictionary["event"] = "woos_zoi_classified_exited_event"
            SFMCAPIclient.pushDataToMC(poiData: propertyDictionary,eventDefinitionKey: SFMCCredentials["zoiClassifiedExitedEventDefinitionKey"]!)
        }
    }
    
}

public extension Date {
    func stringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy HH:mm:ss"
        let stringDate = formatter.string(from: self) // string purpose I add here
        return stringDate
    }
    
    func stringFromISO8601Date() -> String {
        let formatter = ISO8601DateFormatter()
        let stringDate = formatter.string(from: self) // string purpose I add here
        return stringDate
    }
}

