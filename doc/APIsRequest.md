
## Find the Nearest POIs

After receiving the user location, the SDK automatically triggers a request to the searchAPI to get the nearest POIs (to disable this automatic trigger see: https://github.com/woosmap/woosmap-geofencing-ios-sdk/tree/doc/api_on_demand#retrieve-poi). Thanks to the flexibility of the Search API, several parameters can added and tuned to improve your results in the method `searchAPIRequest`: 
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

Informations about the Search API : https://developers.woosmap.com/products/search-api/get-started/

To send the POI, call the method `delegate.searchAPIResponseData` with the data result. 


## How to use Search API 

If you need to trigger search requests (to retrieve POIs) by your own, (e.g. if you've chosen to disable the automatic search request associated to each location collection), you can perform on demand requests to the Search API. To do so you must create a class delegate to retrieve a POI when the method `searchAPIRequest`is called.

In your `AppDelegate`, set keys, and set a delegate to monitor result of the Search API request :
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

### Request Parameters

Set parameter to narrow your results or filters it with the `query` parameter (see all parameters on the documentation https://developers.woosmap.com/products/search-api/get-started/): 
```swift
WoosmapGeofencing.shared.setSearchAPIParameters(parameters: ["radius":"20000","stores_by_page":"2", "query":"tag:rugby"])
```
Note you can create a maximum of 5 POI on each response of the SearchAPI request.  So the parameter "stores_by_page" can't be exceed 5.

### User_properties filter

Set the filter on the user_properties in the response : 
```swift
WoosmapGeofencing.shared.setUserPropertiesFilter(properties: ["creation_date","radius"])
```

### Radius of POI
On the creation of the region POI, you can set manually the radius with a value : 
```swift
WoosmapGeofencing.shared.setPoiRadius(radius: 200.0)
```
or set the radius of the region by defining the parameter name of the user_properties from the reponse : 
```swift
WoosmapGeofencing.shared.setPoiRadius(radius: "radiusPOI")
```

### Send Request
On a refresh location event or whenever you want :

```swift
let location = CLLocation(latitude: latitude, longitude: longitude)
WoosmapGeofencing.shared.getLocationService().searchAPIRequest(location: location)
```

### Retrieve data of the reponse 

Get the result of the Search API request in your class delagate `DataPOI` :
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

Informations about the Search API : https://developers.woosmap.com/products/search-api/get-started/


## How to use Distance API 

As for the Search API, request to the Distance API can be done on demand (e.g. if not enabled with each location collection or if needed on dedicated process of your own). To retrieve distance and duration values between origin(s) and destination(s), you must create a class delegate to retrieve the those data when the method `distanceAPIRequest`is called.

In your `AppDelegate`, set keys, and set a delegate to monitor result of the Distance API request :
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

Launch Distance API request:

```swift
let location = CLLocation(latitude: latitude, longitude: longitude)
let latDest = poi!.latitude
let lngDest = poi!.longitude
WoosmapGeofencing.shared.getLocationService().distanceAPIRequest(locationOrigin: location,coordinatesDest: [(latDest, lngDest)])
```

Get the result of the Distance API request in your class delagate `DataDistance` :
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

Informations about the Distance API :https://developers.woosmap.com/products/distance-api/get-started/


