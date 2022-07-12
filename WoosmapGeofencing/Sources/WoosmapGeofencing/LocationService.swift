//
//  LocationService.swift
//  WoosmapGeofencing

import Foundation
import CoreLocation
import Network

public enum RegionType: String {
    case position
    case custom
    case poi
    case none
}

public class LastSearhLocation {
    public var date: Date = Date()
    public var latitude: Double = 0.0
    public var locationId: String = ""
    public var longitude: Double = 0.0
}
internal protocol LocationServiceInternal {
    
    func requestAuthorization()
    
    func setRegionDelegate(delegate: RegionsServiceDelegate)
    
    func startMonitoringCurrentRegions(regions: Set<CLRegion>)
    
    func updateRegionMonitoring ()
    
    func updateVisit(visit: CLVisit)
    
    func updateLocation(locations: [CLLocation])
    
    func updateLocationDidFailWithError(error: Error)
    
    func handleRegionChange()
    
    func checkIfPositionIsInsideGeofencingRegions(location: CLLocation)
    
    func addRegionLogTransition(region: CLRegion, didEnter: Bool, fromPositionDetection: Bool)
    
    func detectVisitInZOIClassified(visit: CLVisit)
    
    func sendASVisitEvents(visit: Visit)
    
    func sendASPOIEvents(poi: POI)
    
    func sendASRegionEvents(region: Region)
    
    func sendASZOIClassifiedEvents(region: Region)
    
    func setDataFromPOI(poi: POI, propertyDictionary: inout Dictionary <String, Any>)
    
    func updateRegionWithDistance(distanceAr: [Distance])
    
    func getNumberOfAvailableSlotsGeofence() -> Int
    
    func createRegionPOI(center: CLLocationCoordinate2D, name: String, radius: Double)
    
    func removeOldPOIRegions(newPOIS: [POI])
    
}


public protocol LocationService: NSObject {
    
    var locationManager: LocationManagerProtocol? { get set }
    //MARK: weak
    var locationServiceDelegate: LocationServiceDelegate? { get set }
    var searchAPIDataDelegate: SearchAPIDelegate? { get set }
    var distanceAPIDataDelegate: DistanceAPIDelegate? { get set }
    var regionDelegate: RegionsServiceDelegate? { get set }
    var visitDelegate: VisitServiceDelegate? { get set }
//    var airshipEventsDelegate: AirshipEventsDelegate? { get set }
    var marketingCloudEventsDelegate: MarketingCloudEventsDelegate? { get set }
    //MARK:  -
    
    //MARK: Public functions
    init(locationManger: LocationManagerProtocol?)
    
    func initLocationManager()
    
    func startUpdatingLocation()
    
    func stopUpdatingLocation()
    
    func startMonitoringSignificantLocationChanges()
    
    func stopMonitoringSignificantLocationChanges()
    
    func stopMonitoringCurrentRegions()
    
    func getRegionType(identifier: String) -> RegionType
    
    func searchAPIRequest(location: Location)
    
    func sendSearchAPIRequest(location: Location)
    
    func refreshSystemGeofencePOI(addCustomGeofence: Bool, locationId: String)
    
    
    func calculateDistance(locationOrigin: CLLocation,
                           coordinatesDest: [(Double, Double)],
                           distanceProvider : DistanceProvider,
                           distanceMode: DistanceMode,
                           distanceUnits: DistanceUnits,
                           distanceLanguage: String,
                           trafficDistanceRouting: TrafficDistanceRouting,
                           locationId: String,
                           regionIsochroneToUpdate: Bool)
    
    func calculateDistance(locationOrigin: CLLocation,
                           coordinatesDest: [(Double, Double)],
                           locationId: String)
    
    
    func tracingLocationDidFailWithError(error: Error)
    
    func addRegion(identifier: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) -> (isCreate: Bool, identifier: String)
    
    func removeRegion(identifier: String)
    
    func addRegion(identifier: String, center: CLLocationCoordinate2D, radius: Int, type: String) -> (isCreate: Bool, identifier: String)
    
    // func addRegionIsochrone(identifier: String, center: CLLocationCoordinate2D, radius: Int) -> Bool
    
    // func removeRegionIsochrone(identifier: String)
    
    func removeRegion(center: CLLocationCoordinate2D)
    
    func removeRegions(type: RegionType)
    
    func checkIfUserIsInRegion(region: CLCircularRegion)
    
    //MARK: Location manager
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit)
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager)
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)
}

public extension LocationService {
    func refreshSystemGeofencePOI(locationId: String){
        refreshSystemGeofencePOI(addCustomGeofence: false, locationId: locationId)
    }
    
    func calculateDistance(locationOrigin: CLLocation,
                           coordinatesDest: [(Double, Double)],
                           distanceProvider : DistanceProvider = distanceProvider,
                           distanceMode: DistanceMode = distanceMode,
                           distanceUnits: DistanceUnits = distanceUnits,
                           distanceLanguage: String = distanceLanguage,
                           trafficDistanceRouting: TrafficDistanceRouting = trafficDistanceRouting,
                           locationId: String = "",
                           regionIsochroneToUpdate: Bool = false){
        calculateDistance(locationOrigin: locationOrigin,
                          coordinatesDest: coordinatesDest,
                          distanceProvider: distanceProvider,
                          distanceMode: distanceMode,
                          distanceUnits: distanceUnits,
                          distanceLanguage: distanceLanguage,
                          trafficDistanceRouting: trafficDistanceRouting,
                          locationId: locationId,
                          regionIsochroneToUpdate: regionIsochroneToUpdate)
        
    }
}
