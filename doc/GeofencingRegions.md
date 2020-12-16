  
##  Create and monitor geofences
  
Use region monitoring to determine when the user enters or leaves a geographic region.

Region monitoring (also known as geofencing) combines awareness of the user's current location with awareness of the user's proximity to locations that may be of interest. This region is a way for your app to be alerted when the user enters or exits a geographical region. To mark a location of interest, you specify its latitude and longitude. To adjust the proximity for the location, you add a radius. The latitude, longitude, and radius define a geofence, creating a circular area, or fence, around the location of interest.

In iOS, regions are monitored by the system, which wakes up your app as needed when the user crosses a defined region boundary. 

<p align="center">
  <img alt="POI Region" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/POIPenetration.png" width="50%">
</p>

### Set up for geofence monitoring

The first step in requesting geofence monitoring is to set `regionDelegate`, this should be done as early as possible in your didFinishLaunchingWithOptions App Delegate.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
	
	// Set Woosmap API Private key
        WoosmapGeofencing.shared.setWoosmapAPIKey(key: WoosmapKey)
        WoosmapGeofencing.shared.setGMPAPIKey(key: GoogleStaticMapKey)
        
        // Set the Woosmap Search API url
        WoosmapGeofencing.shared.setSearchWoosmapAPI(api: searchWoosmapAPI)
        
        // Set the Woosmap Distance API url
        WoosmapGeofencing.shared.setDistanceWoosmapAPI(api: distanceWoosmapAPI)
        WoosmapGeofencing.shared.setDistanceAPIMode(mode: drivingModeDistance)
	
	// Set classification of zoi enable 
        WoosmapGeofencing.shared.setClassification(enable: true)
        
        // Set delegate of protocol Location, POI and Distance
        WoosmapGeofencing.shared.getLocationService().locationServiceDelegate = DataLocation()
        WoosmapGeofencing.shared.getLocationService().searchAPIDataDelegate = DataPOI()
        WoosmapGeofencing.shared.getLocationService().distanceAPIDataDelegate = DataDistance()
	WoosmapGeofencing.shared.getLocationService().regionDelegate  =  DataRegion()
``` 


### Retrieve Region events
In your class delegate, retrieve Region data : 
```swift
public class DataRegion:RegionsServiceDelegate  {
    
    public func updateRegions(regions: Set<CLRegion>) {
        NotificationCenter.default.post(name: .updateRegions, object: self,userInfo: ["Regions": regions])
    }
    
    public func didEnterPOIRegion(POIregion: CLRegion) {
        createRegion(POIregion: POIregion, didEnter: true)
    }
    
    public func didExitPOIRegion(POIregion: CLRegion) {
        createRegion(POIregion: POIregion, didEnter: false)
    }
    ...

```

Whenever the user crosses the boundary of one of your app's registered regions, the system notifies your app.

Boundary crossing notifications are delivered to your region delegate object. Specifically, `(_:didEnterRegion:)` or `(_:didExitRegion:)` methods.

When determining whether a boundary crossing happened, the system waits to be sure before sending the notification. Specifically, the user must travel a minimum distance over the boundary and remain on the same side of the boundary for at least 20 seconds. These conditions help eliminate spurious calls to your delegate object’s methods.

Regions have an associated identifier, which this method uses to look up information related to the region and perform the associated action.

Regions creation is enabled on the nearest result of the SearchAPI request . On each POI result, 3 regions is created (100 m, 200m, and 300 m). If the creation regions between the mobile and the retrieved Woosmap POIs is not necessary, settings of the SDK can be modified as follow:
```swift
WoosmapGeofencing.shared.setSearchAPICreationRegionEnable(enable: false)
```

### Create a custom region

A region is a circular area centered on a geographic coordinate, and you define one using a `CLLocationCoordinate2D` object. The radius of the region object defines its boundary. You define the regions you want to monitor and register them with the system by calling the `addRegion(center: CLLocationCoordinate2D, radius: CLLocationDistance)` method of `WoosmapGeofencing.shared.locationService`. The system monitors your regions until you explicitly ask it to stop or until the device reboots.

```swift
let (regionIsCreated, identifier) = WoosmapGeofencing.shared.locationService.addRegion(center: coordinate, radius: 100)
```

This method returns the state of creation (true or false) and the identifier of the region created by the SDK. If this method return false that the limit of numbers of regions monitored is exceed. Indeed, regions are shared resources that rely on specific hardware capabilities. To ensure that all apps can participate in region monitoring, Core Location prevents any single app from monitoring more than 20 regions simultaneously. The SDK create 13 regions to monitor the user location, so you have only 7 slot regions available.

 To work around this limitation, monitor only regions that are close to the user’s current location. As the user moves, update the list based on the user’s new location.

### Remove regions

To remove all regions created, you can use this method  : 
```swift
WoosmapGeofencing.shared.locationService.removeRegions(type: LocationService.regionType.NONE)
```

To remove only POI regions created by the result of the searchAPI, you can use this method  :  
```swift
WoosmapGeofencing.shared.locationService.removeRegions(type: LocationService.regionType.POI_REGION)
```

To remove only custom regions created, you can use this method  : 
```swift
WoosmapGeofencing.shared.locationService.removeRegions(type: LocationService.regionType.CUSTOM_REGION)
```
