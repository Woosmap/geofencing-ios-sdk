import Foundation
import CoreLocation
import UserNotifications

public protocol LocationServiceDelegate: class {
    func tracingLocation(location: Location)
    func tracingLocationDidFailWithError(error: Error)
}

public protocol SearchAPIDelegate: class {
    func searchAPIResponse(poi: POI)
    func serachAPIError(error: String)
}

public protocol DistanceAPIDelegate: class {
    func distanceAPIResponseData(distanceAPIData: DistanceAPIData, locationId: String)
    func distanceAPIError(error: String)
}

public protocol RegionsServiceDelegate: class {
    func updateRegions(regions: Set<CLRegion>)
    func didEnterPOIRegion(POIregion: Region )
    func didExitPOIRegion(POIregion: Region )
}

public protocol VisitServiceDelegate: class {
    func processVisit(visit: Visit)
}

public protocol AirshipEventsDelegate: class {
    func poiEvent(POIEvent: Dictionary <String, Any>)
    func regionEnterEvent(regionEvent: Dictionary <String, Any>)
    func regionExitEvent(regionEvent: Dictionary <String, Any>)
    func visitEvent(visitEvent: Dictionary <String, Any>)
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
        if self.locationManager?.monitoredRegions != nil {
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
        if self.locationManager?.monitoredRegions != nil {
            for region in (self.locationManager?.monitoredRegions)! {
                if getRegionType(identifier: region.identifier) == RegionType.position {
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
        if self.currentLocation != nil {
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
        if  (getRegionType(identifier: region.identifier) == RegionType.custom) || (getRegionType(identifier: region.identifier) == RegionType.poi) {
            let regionExit = Regions.add(POIregion: region, didEnter: false)
            sendASRegionEvents(region: regionExit)
            if regionExit.identifier != nil {
                self.regionDelegate?.didExitPOIRegion(POIregion: regionExit)
            }
        }
        self.handleRegionChange()
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if  (getRegionType(identifier: region.identifier) == RegionType.custom) || (getRegionType(identifier: region.identifier) == RegionType.poi) {
            let regionEnter = Regions.add(POIregion: region, didEnter: true)
            sendASRegionEvents(region: regionEnter)
            if regionEnter.identifier != nil {
                self.regionDelegate?.didEnterPOIRegion(POIregion: regionEnter)
            }
        }
        self.handleRegionChange()
    }

    public func addRegion(identifier: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) -> (isCreate: Bool, identifier: String) {
        if self.locationManager?.monitoredRegions != nil {
            if (self.locationManager?.monitoredRegions.count)! < 20 {
                let id = RegionType.custom.rawValue + "_" + identifier
                self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: radius, identifier: id ))
                return (true, RegionType.custom.rawValue + "_" + identifier)
            } else {
                return (false, "")
            }
        }
        return (false, "")
    }

    public func removeRegion(center: CLLocationCoordinate2D) {
        if self.locationManager?.monitoredRegions != nil {
            for region in (self.locationManager?.monitoredRegions)! {
                let latRegion = (region as! CLCircularRegion).center.latitude
                let lngRegion = (region as! CLCircularRegion).center.longitude
                if center.latitude == latRegion && center.longitude == lngRegion {
                    self.locationManager?.stopMonitoring(for: region)
                    self.handleRegionChange()
                }
            }
        }
    }

    public func removeRegions(type: RegionType) {
        if self.locationManager?.monitoredRegions != nil {
            if RegionType.none == type {
                for region in (self.locationManager?.monitoredRegions)! {
                    if !region.identifier.contains(RegionType.position.rawValue) {
                        self.locationManager?.stopMonitoring(for: region)
                    }
                }
            } else {
                for region in (self.locationManager?.monitoredRegions)! {
                    if region.identifier.contains(type.rawValue) {
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
        if visit.horizontalAccuracy < accuracyVisitFilter {
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

    }

    public func searchAPIRequest(location: CLLocation, locationId: String = "") {
        guard let delegate = self.searchAPIDataDelegate else {
            return
        }

        if self.lastSearchLocation != nil && locationId.isEmpty {

            let theLastSearchLocation = self.lastSearchLocation!

            let timeEllapsed = abs(currentLocation!.timestamp.seconds(from: theLastSearchLocation.timestamp))

            if lastSearchLocation!.distance(from: currentLocation!) < searchAPIDistanceFilter {
                return
            }

            if timeEllapsed < searchAPITimeFilter {
                return
            }

            if timeEllapsed < 2 && lastSearchLocation!.horizontalAccuracy >= lastSearchLocation!.horizontalAccuracy {
                return
            }
        }

        // Get POI nearest
        // Get the current coordiante
        let userLatitude: String = String(format: "%f", location.coordinate.latitude)
        let userLongitude: String = String(format: "%f", location.coordinate.longitude)
        let storeAPIUrl: String = String(format: searchWoosmapAPI, userLatitude, userLongitude)
        let url = URL(string: storeAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!

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
                    let poi = POIs.addFromResponseJson(searchAPIResponse: data!, locationId: locationId)
                    if(poi.locationId == nil) {
                        return
                    }
                    self.sendASPOIEvents(poi: poi)
                    delegate.searchAPIResponse(poi: poi)
                    self.lastSearchLocation = self.currentLocation

                    if distanceAPIRequestEnable {
                        self.distanceAPIRequest(locationOrigin: location, coordinatesDest: [(poi.latitude, poi.longitude)], locationId: locationId)
                    }
                    if searchAPICreationRegionEnable {
                        let POIname = (poi.idstore ?? "")  + "_" + (poi.name ?? "")
                        self.createRegionPOI(center: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude), name: POIname)
                    }
                }
            }
        }
        task.resume()

    }

    public func createRegionPOI(center: CLLocationCoordinate2D, name: String) {
        var POIRegionExist = false
        if self.locationManager?.monitoredRegions != nil {
            for region in (self.locationManager?.monitoredRegions)! {
                let latRegion = (region as! CLCircularRegion).center.latitude
                let lngRegion = (region as! CLCircularRegion).center.longitude
                if center.latitude == latRegion && center.longitude == lngRegion {
                    POIRegionExist = true
                }
            }
        }
        if !POIRegionExist {
            if self.locationManager?.monitoredRegions != nil {
                for region in (self.locationManager?.monitoredRegions)! {
                    if  getRegionType(identifier: region.identifier) == RegionType.poi {
                        self.locationManager?.stopMonitoring(for: region)
                    }
                }
            }
            let identifier = RegionType.poi.rawValue + "_" + name
            self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: CLLocationDistance(firstSearchAPIRegionRadius), identifier: identifier + " - " + String(firstSearchAPIRegionRadius) + " m"))
            self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: CLLocationDistance(secondSearchAPIRegionRadius), identifier: identifier + " - " + String(secondSearchAPIRegionRadius) + " m"))
            self.locationManager?.startMonitoring(for: CLCircularRegion(center: center, radius: CLLocationDistance(thirdSearchAPIRegionRadius), identifier: identifier + " - " + String(thirdSearchAPIRegionRadius) + " m"))
        }
    }

    public func distanceAPIRequest(locationOrigin: CLLocation, coordinatesDest: [(Double, Double)], locationId: String = "") {

        guard let delegateDistance = self.distanceAPIDataDelegate else {
            return
        }

        guard let delegateSearch = self.searchAPIDataDelegate else {
            return
        }

        let userLatitude: String = String(format: "%f", locationOrigin.coordinate.latitude)
        let userLongitude: String = String(format: "%f", locationOrigin.coordinate.longitude)
        var coordinateDest = ""
        for coordinate in coordinatesDest {
            let destLatitude: String = String(format: "%f", Double(coordinate.0))
            let destLongitude: String = String(format: "%f", Double(coordinate.1))
            coordinateDest += destLatitude + "," + destLongitude
            if coordinatesDest.last! != coordinate {
                coordinateDest += "|"
            }
        }

        let storeAPIUrl: String = String(format: distanceWoosmapAPI, userLatitude, userLongitude, coordinateDest)
        let url = URL(string: storeAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!

        // Call API search
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    NSLog("statusCode: \(response.statusCode)")
                    delegateDistance.distanceAPIError(error: "Error Distance API " + String(response.statusCode))
                    return
                }
                if let error = error {
                    NSLog("error: \(error)")
                } else {
                    let responseJSON = try? JSONDecoder().decode(DistanceAPIData.self, from: data!)
                    delegateDistance.distanceAPIResponseData(distanceAPIData: responseJSON!, locationId: locationId)
                    // update POI
                    if responseJSON!.status == "OK" {
                        if responseJSON?.rows?.first?.elements?.first?.status == "OK" {
                            let distance = responseJSON?.rows?.first?.elements?.first?.distance?.value!
                            let duration = responseJSON?.rows?.first?.elements?.first?.duration?.text!
                            if distance != nil && duration != nil {
                                let poiUpdated = POIs.updatePOIWithDistance(distance: Double(distance!), duration: duration!, locationId: locationId)
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
    
    func sendASVisitEvents(visit: Visit) {
        guard let delegate = self.airshipEventsDelegate else {
            return
        }
        var propertyDictionary = Dictionary <String, Any>()
        propertyDictionary["date"] = visit.date?.stringFromDate()
        propertyDictionary["arrivalDate"] = visit.arrivalDate?.stringFromDate()
        propertyDictionary["departureDate"] = visit.departureDate?.stringFromDate()
        propertyDictionary["id"] = visit.visitId
        propertyDictionary["latitude"] = visit.latitude
        propertyDictionary["longitude"] = visit.longitude
        
        delegate.visitEvent(visitEvent: propertyDictionary)
    }
    
    func sendASPOIEvents(poi: POI) {
        guard let delegate = self.airshipEventsDelegate else {
            return
        }
        var propertyDictionary = Dictionary <String, Any>()
        propertyDictionary["date"] = poi.date?.stringFromDate()
        propertyDictionary["name"] = poi.name
        propertyDictionary["idStore"] = poi.idstore
        propertyDictionary["city"] = poi.city
        propertyDictionary["distance"] = poi.distance
        let responseJSON = try? JSONDecoder().decode(SearchAPIData.self, from: poi.jsonData ?? Data.init())
        for feature in (responseJSON?.features)! {
            propertyDictionary["tag"] = feature.properties?.tags
            propertyDictionary["type"] = feature.properties?.types
        }
        delegate.poiEvent(POIEvent: propertyDictionary)
    }
    
    func sendASRegionEvents(region: Region) {
        guard let delegate = self.airshipEventsDelegate else {
            return
        }
        var propertyDictionary = Dictionary <String, Any>()
        propertyDictionary["date"] = region.date?.stringFromDate()
        propertyDictionary["id"] = region.identifier
        propertyDictionary["latitude"] = region.latitude
        propertyDictionary["longitude"] = region.longitude
        propertyDictionary["radius"] = region.radius
        
        if(region.didEnter) {
            delegate.regionEnterEvent(regionEvent: propertyDictionary)
        } else {
            delegate.regionExitEvent(regionEvent: propertyDictionary)
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
}

