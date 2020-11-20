## How to use SearchAPI 

To obtain on demand the closest POI from a location, you must create a class delegate to retrieve a POI when the method `searchAPIRequest`was called.

In your `AppDelegate`, set keys, and set a delegate to monitor result of the SearchAPI request :
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set Woosmap API Private key
        WoosmapGeofencing.shared.setWoosmapAPIKey(key: WoosmapKey)

         // Set delegate of protocol POI 
        WoosmapGeofencing.shared.getLocationService().searchAPIDataDelegate = DataPOI()

         // Check the authorization Status of location Manager
         if (CLLocationManager.authorizationStatus() != .notDetermined) {
             WoosmapGeofencing.shared.startMonitoringInBackground()
         }
        return true
}
```

On a refresh location event or ever you want :

```swift
let location = CLLocation(latitude: latitude, longitude: longitude)
WoosmapGeofencing.shared.getLocationService().searchAPIRequest(location: location)
```

Get the result of the request Search API in your class delagate `DataPOI` :
```swift
public class DataPOI:SearchAPIDelegate  {
    
    public init() {}
    
    public func searchAPIResponseData(searchAPIData: SearchAPIData, locationId: String) {
        for feature in (searchAPIData.features)! {
            let city = feature.properties!.address!.city!
            let zipCode = feature.properties!.address!.zipcode!
            let distance = feature.properties!.distance!
            let latitude = (feature.geometry?.coordinates![1])!
            let longitude = (feature.geometry?.coordinates![0])!
            let dateCaptured = Date()
            ...
        }
    }
    
    public func serachAPIError(error: String) {
        
    }
}
```

Informations about the search API : https://developers.woosmap.com/products/search-api/get-started/


## How to use DistanceAPI 

To obtain on demand a distance and duration between an origin and destinations, you must create a class delegate to retrieve the data of distance and duration when the method `distanceAPIRequest`was called.

In your `AppDelegate`, set keys, and set a delegate to monitor result of the DistanceAPI request :
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set Woosmap API Private key
        WoosmapGeofencing.shared.setWoosmapAPIKey(key: WoosmapKey)

         // Set delegate of protocol Distance
        WoosmapGeofencing.shared.getLocationService().distanceAPIDataDelegate = DataDistance()
        
        //Specifies the mode of transport to use when calculating distance. Valid values are "driving", "cycling", "walking". (if not specified default is driving)
        WoosmapGeofencing.shared.setDistanceAPIMode(mode: drivingModeDistance)

         // Check the authorization Status of location Manager
         if (CLLocationManager.authorizationStatus() != .notDetermined) {
             WoosmapGeofencing.shared.startMonitoringInBackground()
         }
        return true
}
```

Launch request DistanceAPI :

```swift
let location = CLLocation(latitude: latitude, longitude: longitude)
let latDest = poi!.latitude
let lngDest = poi!.longitude
WoosmapGeofencing.shared.getLocationService().distanceAPIRequest(locationOrigin: location,coordinatesDest: [(latDest, lngDest)])
```

Get the result of the request Distance API in your class delagate `DataDistance` :
```swift
public class DataDistance:DistanceAPIDelegate  {
    public func distanceAPIResponseData(distanceAPIData: DistanceAPIData, locationId: String) {
        if (distanceAPIData.status == "OK") {
            let distance = distanceAPIData.rows?.first?.elements?.first?.distance?.value!
            let duration = distanceAPIData.rows?.first?.elements?.first?.duration?.text!
        }
    }
    
    
    public func distanceAPIError(error: String) {
        print(error)
    }
}
```

Informations about the Distance API :https://developers.woosmap.com/products/distance-api/get-started/


## Find the Nearest POIs

After receiving the user location, the SDK makes a request to the searchAPI to get the nearest POI. We can modify the request and add other filters to improve your results in the method `searchAPIRequest`: 
```swift
func searchAPIRequest(locationId: UUID){
        guard let delegate = self.searchAPIDataDelegate else {
            return
        }
        
        
        if (self.lastSearchLocation != nil ) {
            
            let theLastSearchLocation = self.lastSearchLocation!
            
            let timeEllapsed = abs(currentLocation!.timestamp.seconds(from: theLastSearchLocation.timestamp))
            
            if (lastSearchLocation!.distance(from: currentLocation!) < searchAPIDistanceFilter ) {
                return
            }
            
            if timeEllapsed < searchAPITimeFilter {
                return
            }
            
            if (timeEllapsed < 2 && lastSearchLocation!.horizontalAccuracy >= lastSearchLocation!.horizontalAccuracy) {
                return
            }
        }
        
        
        // Get POI nearest
        // Get the current coordiante
        let userLatitude: String = String(format: "%f", currentLocation!.coordinate.latitude)
        let userLongitude: String = String(format:"%f", currentLocation!.coordinate.longitude)
        let storeAPIUrl: String = String(format: searchWoosmapAPI,userLatitude,userLongitude)
        let url = URL(string: storeAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
        // Call API search
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if (response.statusCode != 200) {
                    NSLog("statusCode: \(response.statusCode)")
                    delegate.serachAPIError(error:"Error Search API " + String(response.statusCode))
                    return
                }
                if let error = error {
                    NSLog("error: \(error)")
                } else {
                    let responseJSON = try? JSONDecoder().decode(SearchAPIData.self, from: data!)
                    delegate.searchAPIResponseData(searchAPIData: responseJSON!, locationId: locationId)
                    self.lastSearchLocation = self.currentLocation
                }
            }
        }
        task.resume()
    }
```

To send the POI, call the method `delegate.searchAPIResponseData` with the data result. 

