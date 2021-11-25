## Woosmap Geofencing

<p align="center">
<a href="https://github.com/woosmap/woosmap-geofencing-ios-sdk/actions"><img alt="badge" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/workflows/WoosmapGeofencing/badge.svg?branch=master"></a>
<a href="https://developer.apple.com/swift"><img alt="badge" src="https://img.shields.io/badge/language-swift5-f48041.svg?style=flat"></a>
<a href="https://developer.apple.com/ios"><img alt="badge" src="https://img.shields.io/badge/platform-iOS%2010%2B-blue.svg?style=flat%22"></a>
<a href="https://swift.org/package-manager/"><img alt="badge" src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage"><img alt="badge" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/LICENSE.md"><img alt="badge" src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat"></a>
</p>

Location intelligence is one of the next revolutions to improve and "smoothen" user experience on mobile. 
Mobile operating systems use and provide multiple location services that might be tricky to handle or tune to achieve advanced location based services on mobile. And users are more and more aware of the capabilities of their mobile devices.
During the last two years, we analysed, exploited and followed the evolution of those location services, changes that occurred either on tech side or regulation side.

We are convinced that location is an effective way for App makers to propose tailor made and locally contextualised interactions with mobile users.
But knowing the location of a user is not enough. Knowing from what a user is close to or what he is visiting is the important part. So we decided to share our findings and tricks for location collection on mobile to help you focus on this real value of location. 

This repository is designed to share samples of codes and a SDK on iOS to take the best of location in your mobile apps. 
We had 3 main focus when developing and sharing this code: take full advantage of location capabilities of mobile devices, doing so in a battery friendly way and be fair with user privacy (see [Enabling Location](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/EnablingLocation.md)).

Woosmap Geofencing SDK and sample app should help you build Rich Push Notifications (highlighted with a Location context), analyse your mobile users surroundings (search for proximity to your assets, competitors, etc) and much more on iOS to go a step further on Location Intelligence.

### Use case where location matters:

As a banking company, you need to enrich the expense list with local information (logo, shop info, etc)? Use this repo to learn how to leverage locally enriched notification to retrieve local information where your users spend their money.

As a retailer company, you need to be informed when a user is close to one of your stores (or competitors’)? Find in this repo how to collect in background location of your users and build your own geofencing analysis.

As a retailer, insurance, banking or travel company, you need to add local context to your user profiles in your CRM? Build your own process of background location collection in your mobile app and analyze geographic behaviors of your mobile users.

As a retailer, insurance, banking or travel company, you want to be informed when a user is visiting specific POIs you decided to monitor (your own stores, your competitors, specific locations)? Use our SDK/code samples to not just collect location but directly obtain "visit triggers" and build advanced scenarios (e.g. a Bank being able to propose specific loans or services when users visits Real Estate agencies, Car Dealers, etc - an Insurance company proposing travel insurance when users visit airports, car insurance when users visit car dealers, etc)

##  Overview

### Get user location 

Collect in background user's locations and host them in a local database. Call the Woosmap Search API to retrieve closest stores to each location to locally contextualized users journeys.

<p align="center">
  <img alt="WoosmapGeofencing" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/WoosmapGeofencing1.png" width="30%">
</p>

### Enrich Notification with user location and POIs (Points of Interest)

Get the location of a user on notification reception, to complete the payload with local information from third parties APIs.  
In this sample, fetched location is then used to perform a request to the Woosmap Search API to get the closest POIs (Points of Interest) to the location of the user. In addition, a call to Google Static Map is performed to enrich the notification with a map displaying the user's location and the closest POIs.

<p align="center">
  <img alt="Notification Location" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/2Markers.png" width="50%">
</p>

### Detect Visits (spending time at one place) of your users 
Get the location and the time spent when a user is visiting places. Once again use the Woosmap Search API if needed to detect if your users visit your stores, your competitors or POI you may want to monitor. 

<p align="center">
  <img alt="Visit" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/visit.png" width="50%">
</p>

### Detect Zone of Interest (cluster) of your users
Identify areas of interest for your users (location where they spend time, once or recurrently).
<p align="center">
  <img alt="Visit" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master//assets/ZOI1.png" width="50%">
  <img alt="Visit" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master//assets/ZOI2.png" width="50%">
</p>

### Classification of Zone of Interest (cluster) 
The classification of zones of interest (zois) aims to assign them types. For now, two types are supported "home" (zone where a user is supposed to live) and "work" (zone where a user is supposed to work).
<p align="center">
  <img alt="Classification" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/Classification.png" width="50%">
</p>

Calculations for each zoi are performed to determine the number of different weeks that the user has spent there.
A zoi is considered to be recurrent if the number of weeks spent in the zone is greater than or equal to the average of the number of weeks spent in all the zones.

The creation of zois is enable by default. For disable that, in your `AppDelegate`, you can change the value in the settings of the SDK as follow:
```swift
// Set creation of zoi enable
WoosmapGeofencing.shared.creationOfZOIEnable(enable: false)
```

The classification of zois is enable by default. For disable that, in your `AppDelegate`, you can change the value in the settings of the SDK as follow:
```swift
// Set classification of zoi enable
WoosmapGeofencing.shared.setClassification(enable: false)
```

##  Pre-requisites

- iOS 10 and above
- Xcode 11 and above
- APNS Credentials
- Surge dependency [https://github.com/Jounce/Surge](https://github.com/Jounce/Surge) : A Swift library that uses the Accelerate framework to provide high-performance functions for matrix math, digital signal processing, and image manipulation. 
- Realm dependency [https://github.com/realm/realm-cocoa](https://github.com/realm/realm-cocoa) : Realm is a mobile database that runs directly inside phones, tablets or wearables.

## Installation
* Download the latest code version or add the repository as a git submodule to your git-tracked project.
* Open your Xcode project, then drag and drop source directory onto your project. Make sure to select Copy items when asked if you extracted the code archive outside of your project.
* Compile and install the mobile app onto your mobile device.

### Swift Package Manager

To integrate Woosmap Geofencing SDK into your project using [Swift Package Manager](https://swift.org/package-manager/), you can add the library as a dependency in Xcode (11 and above) – see the [docs](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app). The package repository URL is:

```bash
https://github.com/woosmap/woosmap-geofencing-ios-sdk.git
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Woosmap Geofencing into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "woosmap/woosmap-geofencing-ios-sdk" ~> 1.0.0
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Woosmap Geofencing SDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
target 'MyApp' do
  pod 'WoosmapGeofencing', :git => 'https://github.com/woosmap/woosmap-geofencing-ios-sdk.git'
end
```

## Get Keys

* If you don't use the Woosmap API with key, you can only get the location of the user.
* If you want to retrieve the closest store the user's location, load your assets in a Woosmap Project and get a Woosmap Key API [see Woosmap developer documentation](https://developers.woosmap.com/get-started).
<p align="center">
  <img alt="WoosmapGeofencing with POI from Search API" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/WoosmapGeofencing2.png" width="30%">
</p>
<p align="center">
  <img alt="Search API" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/UserLocationPOI.png" width="50%">
</p>

* If you want to display a map in the notification, get Google Maps API Key for requesting a static map [see Google documentation](https://developers.google.com/maps/documentation/maps-static/get-api-key).
<p align="center">
  <img alt="Google map Static" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/1Marker.png" width="50%">
</p>

* If you don't use any third party API and don’t define API keys, the notification will only display the location (lat/long) of the user.
<p align="center">
  <img alt="Google map Static" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/userLocation.png" width="50%">
</p>


## Usage 
If you plan to perform searches or distance calculations thanks to the Woosmap APIs, please be sure your Woosmap Private Key is set every time your app is launched (in Foreground AND Background). This should be done as early as possible in your didFinishLaunchingWithOptions App Delegate. Depending on your integration, you should call startMonitoringInBackground too. This method must also be called everytime your app is launched.
As soon as data is available, set the `locationServiceDelegate`, `searchAPIDataDelegate`, `visitDelegate` and  `distanceAPIDataDelegate` to retrieve location data, POIs from a Woosmap datasource, distance by road to those POIs and visit data if the Visit parameter is enabled. 
```swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataLocation = DataLocation()
    let dataPOI = DataPOI()
    let dataDistance = DataDistance()
    let dataRegion = DataRegion()
    let dataVisit = DataVisit()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
	
        // Set Woosmap API Private key
            WoosmapGeofencing.shared.setWoosmapAPIKey(key: WoosmapKey)
            WoosmapGeofencing.shared.setGMPAPIKey(key: GoogleStaticMapKey)
            
            // Set the Woosmap Search API url
            WoosmapGeofencing.shared.setSearchWoosmapAPI(api: searchWoosmapAPI)
            
            // Set the Woosmap Distance API url
            WoosmapGeofencing.shared.setDistanceWoosmapAPI(api: distanceWoosmapAPI)
            WoosmapGeofencing.shared.setDistanceAPIMode(mode: drivingModeDistance)
            
            // Set your filter on position location and search
            WoosmapGeofencing.shared.setCurrentPositionFilter(distance: 10.0, time: 10)
            WoosmapGeofencing.shared.setSearchAPIFilter(distance: 10.0, time: 10)
        
            // Set classification of zoi enable 
            WoosmapGeofencing.shared.setClassification(enable: true)
            
            // Set delegate of protocol Location, POI and Distance
            WoosmapGeofencing.shared.getLocationService().locationServiceDelegate = dataLocation
            WoosmapGeofencing.shared.getLocationService().searchAPIDataDelegate = dataPOI
            WoosmapGeofencing.shared.getLocationService().distanceAPIDataDelegate = dataDistance
            WoosmapGeofencing.shared.getLocationService().regionDelegate = dataRegion

            // Enable Visit and set delegate of protocol Visit
            WoosmapGeofencing.shared.setVisitEnable(enable: true)
            WoosmapGeofencing.shared.getLocationService().visitDelegate = dataVisit
     
             // Check the authorization Status of location Manager
             if (CLLocationManager.authorizationStatus() != .notDetermined) {
                 WoosmapGeofencing.shared.startMonitoringInBackground()
             }
        return true
    }
```

In order to avoid loosing data, you also need to call `startMonitoringInBackground` in the proper AppDelegate method : 
```swift
func applicationDidEnterBackground(_ application: UIApplication) {
    if (CLLocationManager.authorizationStatus() != .notDetermined) {
        WoosmapGeofencing.shared.startMonitoringInBackground()
    }
}
```

To keep the SDK up to date with user's data, you need to call `didBecomeActive` in the proper AppDelegate method too.
```swift
func applicationDidBecomeActive(_ application: UIApplication) {
    WoosmapGeofencing.shared.didBecomeActive()
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
```

The position tracking is enabled by default. To disable location collection, just change the value in the settings of the SDK as follow:
```swift
WoosmapGeofencing.shared.setTrackingEnable(enable: false)
```

### Retrieve Location 
In your class delegate, retrieve location data :
```swift
public class DataLocation:LocationServiceDelegate  {
    
    public init() {}
    
    public func tracingLocation(location: Location) {
        NotificationCenter.default.post(name: .newLocationSaved, object: self,userInfo: ["Location": location])
    }
    
    public func tracingLocationDidFailWithError(error: Error) {
        NSLog("\(error)")
    }
    
    public func readLocations()-> [Location] {
        return Locations.getAll()
    }
    
    public func eraseLocations() {
        Locations.deleteAll()
    }
    
}
```

### Retrieve POI 
In your class delegate, retrieve POI data :
```swift
public class DataPOI:SearchAPIDelegate  {
    public init() {}
    
    public func searchAPIResponse(poi: POI) {
        NotificationCenter.default.post(name: .newPOISaved, object: self, userInfo: ["POI": poi])
    }
    
    public func serachAPIError(error: String) {
        
    }
    
    public func readPOI()-> [POI] {
        return POIs.getAll()
    }
    
    func getPOIbyLocationID(locationId: String)-> POI? {
        return POIs.getPOIbyLocationID(locationId: locationId)
    }
    
    public func erasePOI() {
        POIs.deleteAll()
    }
    
}

```
The Search API request is enabled on all positions by default. To disable Search request, just change the value in the settings of the SDK as follow:
```swift
WoosmapGeofencing.shared.setSearchAPIRequestEnable(enable: false)
```

### Retrieve Distance API 
In your class delegate, retrieve Distance data :
```swift
public class DataDistance:DistanceAPIDelegate  {
    public init() {}
    
    public func distanceAPIResponseData(distanceAPIData: DistanceAPIData, locationId: String) {
        if (distanceAPIData.status == "OK") {
            if (distanceAPIData.rows?.first?.elements?.first?.status == "OK") {
                let distance = distanceAPIData.rows?.first?.elements?.first?.distance?.value!
                let duration = distanceAPIData.rows?.first?.elements?.first?.duration?.text!
                if(distance != nil && duration != nil) {
                    print(distance ?? 0)
                    print(duration ?? 0)
                }
            }
        }
    }
    
    public func distanceAPIError(error: String) {
        print(error)
    }
    
}
```
The Distance API request is enabled on all search results by default. If distance by road between the mobile and the retrieved Woosmap POIs is not necessary, settings of the SDK can be modified as follow:
```swift
WoosmapGeofencing.shared.setDistanceAPIRequestEnable(enable: false)
```

### Retrieve Visits 
For the visits, in the app delegate, you can retrieve the visit like this: 
```swift
public class DataVisit:VisitServiceDelegate  {
    
    public init() {}
    
    public func processVisit(visit: Visit) {
        NotificationCenter.default.post(name: .newVisitSaved, object: self,userInfo: ["Visit": visit])
    }
    
    public func readVisits()-> Array<Visit> {
        return Visits.getAll()
    }
    
    public func eraseVisits() {
        Visits.deleteAll()
    }
}

```

### Retrieve Zone of Interest
ZOIs are built from visits, grouped by proximity. We use the Fast Incremental Gaussian Mixture Model of classification Algorithm  [FIGMM](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0139931) to build and update our ZOI according to visits recurrency along time.

For the ZOIs, in the app delegate, you can retrieve zoi data like this: 
```swift
public class DataZOI {
    public init() {}
    
    public func readZOIs()-> [ZOI] {
        return ZOIs.getAll()
    }
    
    
    public func eraseZOIs() {
        ZOIs.deleteAll()
    }
}
```


Each ZOI includes the following informations:

 - The id of the ZOI

```swift
public var zoiId: UUID?
```
 - The list of id visits included in this ZOI
 
```swift
public var idVisits: [UUID]?
```

 - The latitude and longitude of the center of the ZOI (useful if you need to qualify the place of the visit with a search request over POIs or assets)
 
```swift
public var lngMean: Double
```

```swift
public var latMean: Double
```

- Age is used to determine if a ZOI should be deleted by the algorithm *(only for calculation of ZOI)*

```swift
public var age: Double
```

- Represents the number of visits used to build the ZOI  *(only for calculation of ZOI)*

```swift
public var accumulator: Double
```

- The covariance determinant  *(only for calculation of ZOI)*

```swift
public var covariance_det: Double
```

- Estimation of probability  *(only for calculation of ZOI)*

```swift
public var prior_probability: Double
```

- The covariance of a cluster  *(only for calculation of ZOI)*

```swift
public var x00Covariance_matrix_inverse: Double
```

```swift
public var x01Covariance_matrix_inverse: Double
```

```swift
public var x10Covariance_matrix_inverse: Double
```

```swift
public var x11Covariance_matrix_inverse: Double
```

- The entry date for the first ZOI visit

```swift
public var startTime: Date?
```

 - The exit date of the last ZOI visit
 
```swift
public var endTime: Date?
```

 - The weekly density of the ZOI visit  *(only for classification of ZOI)*
```swift
public var weekly_density: [Double]?
```

- The duration of all the accumulated visits of the ZOI

```swift
public var duration: Int64
```

- This is the [Well-known text representation of geometry](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry) of the ZOI polygon.
 For your tests, if you need to explore those WKT and see what they look like on a map, you can use this tool [https://arthur-e.github.io/Wicket/sandbox-gmaps3.html](https://arthur-e.github.io/Wicket/sandbox-gmaps3.html).
 
```swift
public var wktPolygon: String?
```

## Simulate Notification

* Get the notification token in the log debug or on the main screen of the demo app.
* Install the app PushNotification from the github: <https://github.com/noodlewerk/NWPusher>. This desktop app will help you simulate notification sending if you do not have any other Notification Solutions.
* Enter your push certificate: <https://github.com/noodlewerk/NWPusher#certificate>
* Enter a message in json format like this "{"location":"1","timestamp":"1589288354"}". The object "location" allows to have a location (lat/long) displayed in the notification. The "timestamp" object validates the delay between the server time and the mobile time to check if the retrieved location is not outdated (if difference between server and mobile time is greater than 300 sec, notification will not be displayed).
* If you want to send notification directly from an iOS app, you can use this project: <https://github.com/noodlewerk/NWPusher#push-from-ios>. Follow instructions to change the p12 file and enter the token of the notification app.


## GPX files
To test geolocation in an iOS app, you can mock a route to simulate locations.  
To create a gpx files, the following tool converts a Google Maps link (also works with Google Maps Directions) to a .gpx file: <https://mapstogpx.com/mobiledev.php>
To emulate, follow instructions here:  <http://www.madebyuppercut.com/testing-geolocation-ios-app/>


## Additional Documentation

* [Enabling Location](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/EnablingLocation.md): To use location, first thing is enabling associated services on the user device. Find out here how to do it and more importantly what are the different permissions and consequences of choices made by the user
* [Enabling the Push Notification Service](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/EnablingPushNotificationService.md): As for location, user has to accept Push Notification, you can find here what to set in your app, associated permissions for the user, APNS registering process and tips to test it all.
* [Notifications Service Extensions](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/NotificationsServiceExtensions.md): if you are here, it’s because you want custom notifications. Find out here how to handle those.
* [Setup the location manager](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/SetupLocationManager.md): how to configure the Location Manager in the Notification Service Extension. 
* [Check Timestamp of the payload](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/CheckTimestampPayload.md): because differences may occur between sending time and reception time, you may need to check it before retrieving a location.
* [Enabling Location in different lifecycle](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/EnablingLocationLifecycle.md): how to use location manager in different lifecycle (Foreground, Background) of the app
* [Get Location with optimizations](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/GetLocationOptimizations.md): to optimize detection mouvement with battery usage.
* [APIs request](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/APIsRequest.md): find out here how to use Woosmap Search API to “geo contextualize” the location of your users. 
* [Notification APIs request](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/APIsRequestInNotification.md): in use of a notification, Location of the mobile is one thing but knowing from what the mobile is close to is another thing. Find out here how to use Woosmap Search API to “geo contextualize” the location of your users.
* [Create and monitor geofences](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/GeofencingRegions.md): Use region monitoring to determine when the user enters or leaves a geographic region.
* [ZOI Algorithm](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/ZOIAlgorithm.md): Find out how ZOI are built from visits.
* [ZOI Classification](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/Classification.md): Find out how Classification are built from duration of ZOI.
* [Geographic Data Lifecycle and import data from a CSV](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/GeographicDataLifecycle.md): Find out how to manage the data lifecycle to be in compliance with GDPR and how to import data from a CSV.
* [Airship Integration](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/airship.md): Track location data and generate contextual events using custom event types.
* [Salesforce MarketingCloud Integration](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/MarketingCloudConnector.md): Track location data and generate contextual events using custom event types and push it to SFMC.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
Thank you for your suggestions!

## License
Woosmap Geofencing is released under the MIT License. See [LICENSE](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/LICENSE.md) file for details.
