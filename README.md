## Woosmap Geofencing

Location intelligence is one of the next revolutions to improve and "smoothen" user experience on mobile. 
Mobile operating systems use and provide multiple location services that might be tricky to handle or tune to achieve advanced location based services on mobile. And users are more and more aware of the capabilities of their mobile devices.
During the last two years, we analysed, exploited and followed the evolution of those location services, changes that occurred either on tech side or regulation side.

We are convinced that location is an effective way for App makers to propose tailor made and locally contextualised interactions with mobile users.
But knowing the location of a user is not enough. Knowing from what a user is close to or what he is visiting is the important part. So we decided to share our findings and tricks for location collection on mobile to help you focus on this real value of location. 

This repository is designed to share samples of codes and a SDK on iOS to take the best of location in your mobile apps. 
We had 3 main focus when developing and sharing this code: take full advantage of location capabilities of mobile devices, doing so in a battery friendly way and be fair with user privacy (see [Enabling Location](./doc/EnablingLocation.md)).

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

##  Pre-requisites

- iOS 11 and above
- Xcode 11 and above
- APNS Credentials

## Installation
* Download the latest code version or add the repository as a git submodule to your git-tracked project.
* Open your Xcode project, then drag and drop source directory onto your project. Make sure to select Copy items when asked if you extracted the code archive outside of your project.
* Compile and install the mobile app onto your mobile device.

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

## Simulate Notification

* Get the notification token in the log debug or on the main screen of the demo app.
* Install the app PushNotification from the github : https://github.com/noodlewerk/NWPusher. This desktop app will help you simulate notification sending if you do not have any other Notification Solutions.
* Enter your push certificate : https://github.com/noodlewerk/NWPusher#certificate
* Enter a message in json format like this "{"location":"1","timestamp":"1589288354"}". The object "location" allows to have a location (lat/long) displayed in the notification. The "timestamp" object validates the delay between the server time and the mobile time to check if the retrieved location is not outdated (if difference between server and mobile time is greater than 300 sec, notification will not be displayed).
* If you want to send notification directly from an iOS app, you can use this project : https://github.com/noodlewerk/NWPusher#push-from-ios. Follow instructions to change the p12 file and enter the token of the notification app.


## GPX files
To test geolocation in an iOS app, you can mock a route to simulate locations.  
To create a gpx files, the following tool converts a Google Maps link (also works with Google Maps Directions) to a .gpx file: https://mapstogpx.com/mobiledev.php
To emulate, follow instructions here :  http://www.madebyuppercut.com/testing-geolocation-ios-app/


## Additional Documentation

* [Enabling Location](./doc/EnablingLocation.md): To use location, first thing is enabling associated services on the user device. Find out here how to do it and more importantly what are the different permissions and consequences of choices made by the user
* [Enabling the Push Notification Service](./doc/EnablingPushNotificationService.md): As for location, user has to accept Push Notification, you can find here what to set in your app, associated permissions for the user, APNS registering process and tips to test it all.
* [Notifications Service Extensions](./doc/NotificationsServiceExtensions.md): if you are here, it’s because you want custom notifications. Find out here how to handle those.
* [Setup the location manager](./doc/SetupLocationManager.md): how to configure the Location Manager in the Notification Service Extension. 
* [Check Timestamp of the payload](./doc/CheckTimestampPayload.md): because differences may occur between sending time and reception time, you may need to check it before retrieving a location.
* [Enabling Location in different lifecycle](./doc/EnablingLocationLifecycle.md): how to use location manager in different lifecycle (Foreground, Background) of the app
* [Get Location with optimizations](./doc/GetLocationOptimizations.md): to optimize detection mouvement with battery usage.
* [APIs request](./doc/APIsRequest.md): find out here how to use Woosmap Search API to “geo contextualize” the location of your users. 
* [Notification APIs request](./doc/APIsRequestInNotification.md): in use of a notification, Location of the mobile is one thing but knowing from what the mobile is close to is another thing. Find out here how to use Woosmap Search API to “geo contextualize” the location of your users.


## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
Thank you for your suggestions!

## License
Woosmap Geofencing is released under the MIT License. See [LICENSE](https://github.com/woosmap/woosmap-geofencing-ios-sdk/blob/master/LICENSE.md) file for details.
