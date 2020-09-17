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
Be sure your Private Key for the Woosmap Search API is set every time your app is launched (in Foreground AND Background). This should be done as early as possible in your didFinishLaunchingWithOptions App Delegate. Depending on your integration, you should call startMonitoringInBackground too. This method must also be called everytime your app is launched.
Set the `locationServiceDelegate`, `searchAPIDataDelegate` and  `visitDelegate` to retrieve data of location, POI when the data is ready and visit data if the the visit is enabled. 
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set private key Search API
        WoosmapGeofencing.shared.setWoosmapAPIKey(key: "YOUR_WOOSMAP_KEY")
        
        // Set your filter on position location and search
        WoosmapGeofencing.shared.setCurrentPositionFilter(distance: 10.0, time: 10)
        WoosmapGeofencing.shared.setSearchAPIFilter(distance: 10.0, time: 10)
	
	// Set classification of zoi enable 
        WoosmapGeofencing.shared.setClassification(enable: true)
        
        // Initialize the framework
        WoosmapGeofencing.shared.initServices()
        
        // Set delegate of protocol Location and POI
        WoosmapGeofencing.shared.getLocationService().locationServiceDelegate = DataLocation()
        WoosmapGeofencing.shared.getLocationService().searchAPIDataDelegate = DataPOI()
        
        // Enable Visit and set delegate of protocol Visit
        WoosmapGeofencing.shared.setVisitEnable(enable: true)
        WoosmapGeofencing.shared.getLocationService().visitDelegate = DataVisit()
 
         // Check if the authorization Status of location Manager
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

In your class delegate, retrieve location data and POI date:
```swift
func tracingLocation(locations: [CLLocation], locationId: UUID) {
        let location = locations.last!
  
        let locationToSave = LocationModel(locationId: locationId, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, dateCaptured: Date(), descriptionToSave: "description")
        print("location to save = " + locationToSave.dateCaptured.stringFromDate())
        createLocation(location: locationToSave)
        self.lastLocation = location
    }
    
    func tracingLocationDidFailWithError(error: Error) {
        NSLog("\(error)")
    }

func searchAPIResponseData(searchAPIData: SearchAPIData, locationId: UUID) {
    for feature in (searchAPIData.features)! {        
    	let city = feature.properties!.address!.city!
        let zipCode = feature.properties!.address!.zipcode!
        let distance = feature.properties!.distance!
        let latitude = (feature.geometry?.coordinates![1])!
        let longitude = (feature.geometry?.coordinates![0])!
        let dateCaptured = Date()
        let POIToSave = POIModel(locationId: locationId,city: city,zipCode: zipCode,distance: distance,latitude: latitude, longitude: longitude,dateCaptured: dateCaptured)
        createPOI(POImodel: POIToSave)
    }
}
func serachAPIError(error: String) {
       // Catch Error
       NSLog("\(error)")
}
```

For the visits, in the app delegate, you can retrieve the visit like this: 
```swift
func processVisit(visit: CLVisit) {
    let calendar = Calendar.current
    let departureDate = calendar.component(.year, from: visit.departureDate) != 4001 ? visit.departureDate : nil
    let arrivalDate = calendar.component(.year, from: visit.arrivalDate) != 4001 ? visit.arrivalDate : nil
    let visitToSave = VisitModel(arrivalDate: arrivalDate, departureDate: departureDate, latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude, dateCaptured:Date() , accuracy: visit.horizontalAccuracy)
    
    createVisit(visit: visitToSave)
}
```

Retrieve Zone of Interest
ZOIs are built from visits, grouped by proximity. We use the Fast Incremental Gaussian Mixture Model of classification Algorithm  [FIGMM](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0139931) to build and update our ZOI according to visits recurrency along time.

Create the ZOI when a visit is created :
```swift
func createVisit(visit: VisitModel) {
	...
    DataZOI().createZOIFromVisit(visit: newVisit)
}
```

To create ZOI, you must retrieve all the ZOI in database, calculate the new ZOIs, erase the old ZOIs in database, save the new ZOIs:
```swift
func createZOIFromVisit(visit : Visit) {
   	//Retrieve the zois in database
    let sMercator = SphericalMercator()
    var zoisFromDB: [Dictionary<String, Any>] = []
    for zoiFromDB in readZOIs(){
        var zoiToAdd = Dictionary<String, Any>()
        zoiToAdd["prior_probability"] = zoiFromDB.prior_probability
        zoiToAdd["mean"] = [zoiFromDB.latMean, zoiFromDB.lngMean]
        zoiToAdd["age"] = zoiFromDB.age
        zoiToAdd["accumulator"] = zoiFromDB.accumulator
        zoiToAdd["idVisits"] = zoiFromDB.idVisits
        zoiToAdd["startTime"] = zoiFromDB.startTime
        zoiToAdd["endTime"] = zoiFromDB.endTime
        zoiToAdd["covariance_det"] = zoiFromDB.covariance_det
        zoiToAdd["x00Covariance_matrix_inverse"] = zoiFromDB.x00Covariance_matrix_inverse
        zoiToAdd["x01Covariance_matrix_inverse"] = zoiFromDB.x01Covariance_matrix_inverse
        zoiToAdd["x10Covariance_matrix_inverse"] = zoiFromDB.x10Covariance_matrix_inverse
        zoiToAdd["x11Covariance_matrix_inverse"] = zoiFromDB.x11Covariance_matrix_inverse
        zoisFromDB.append(zoiToAdd)
        
    }
    
    // Set the data zois for calculation
    setListZOIsFromDB(zoiFromDB: zoisFromDB)

	// Calculation
    let list_zoi = figmmForVisit(newVisitPoint: MyPoint(x: sMercator.lon2x(aLong: visit.longitude), y: sMercator.lat2y(aLat:visit.latitude),accuracy: visit.accuracy, id:visit.visitId!, startTime: visit.arrivalDate!, endTime: visit.departureDate!))
    
    // Erase the old data
    eraseZOIs()
    
    // Store zoi in database
    for zoi in list_zoi{
        createZOIFrom(zoi: zoi)
    }
    
}
```

When you store a ZOI in database, you must define the duration the ZOI, the departure and arrival date time like that: 
```swift
func createZOIFrom(zoi: Dictionary<String, Any>) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "ZOI", in: context)!
    let newZOi = ZOI(entity: entity, insertInto: context)
    newZOi.setValue(UUID(), forKey: "zoiId")
    newZOi.setValue(zoi["idVisits"], forKey: "idVisits")
    
    var visitArrivalDate = [Date]()
    var visitDepartureDate = [Date]()
    var duration = 0
    for id in zoi["idVisits"] as! [UUID] {
        let visit = DataVisit().getVisitFromUUID(id: id)
        visitArrivalDate.append(visit!.arrivalDate!)
        visitDepartureDate.append(visit!.departureDate!)
        duration += visit!.departureDate!.seconds(from: visit!.arrivalDate!)
    }
    let startTime = visitArrivalDate.reduce(visitArrivalDate[0], { $0.timeIntervalSince1970 < $1.timeIntervalSince1970 ? $0 : $1 } )
    let endTime = visitDepartureDate.reduce(visitDepartureDate[0], { $0.timeIntervalSince1970 > $1.timeIntervalSince1970 ? $0 : $1 } )
    
    newZOi.setValue(startTime , forKey: "startTime")
    newZOi.setValue(endTime, forKey: "endTime")
    newZOi.setValue(duration, forKey: "duration")
    newZOi.setValue((zoi["mean"] as! Array<Any>)[0] as! Double, forKey: "latMean")
    newZOi.setValue((zoi["mean"] as! Array<Any>)[1] as! Double, forKey: "lngMean")
    newZOi.setValue(zoi["age"] , forKey: "age")
    newZOi.setValue(zoi["accumulator"] , forKey: "accumulator")
    newZOi.setValue(zoi["covariance_det"] , forKey: "covariance_det")
    newZOi.setValue(zoi["prior_probability"] , forKey: "prior_probability")
    newZOi.setValue(zoi["x00Covariance_matrix_inverse"], forKey: "x00Covariance_matrix_inverse")
    newZOi.setValue(zoi["x01Covariance_matrix_inverse"], forKey: "x01Covariance_matrix_inverse")
    newZOi.setValue(zoi["x10Covariance_matrix_inverse"], forKey: "x10Covariance_matrix_inverse")
    newZOi.setValue(zoi["x11Covariance_matrix_inverse"], forKey: "x11Covariance_matrix_inverse")
    newZOi.setValue(zoi["WktPolygon"], forKey: "wktPolygon")
    
    do {
        try context.save()
    }
    catch let error as NSError {
        print("Could not insert. \(error), \(error.userInfo)")
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
* [ZOI Algorithm](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/ZOIAlgorithm.md): Find out how ZOI are built from visits.
* [ZOI Classification](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/Classification.md): Find out how Classification are built from duration of ZOI.
* [Geographic Data Lifecycle and import data from a CSV](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/doc/GeographicDataLifecycle.md): Find out how to manage the data lifecycle to be in compliance with GDPR and how to import data from a CSV.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
Thank you for your suggestions!

## License
Woosmap Geofencing is released under the MIT License. See [LICENSE](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/LICENSE.md) file for details.
