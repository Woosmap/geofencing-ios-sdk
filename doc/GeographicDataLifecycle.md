## Geographic Data Lifecycle and import data from a CSV

### Geographic Data Lifecycle

To be in compliance with GDPR, you must erase all data about locations, visits and ZOIs beyond 30 days. The database is in the Geofencing SDK,
so its your responsability to manage the duration of data. 

In the sample App, you have an example to how manage data lifecycle. In the Settings class of the app, you have a parameter to set about the delay of duration data :
```swift
//Delay of Duration data
public var dataDurationDelay = 30// number of day
```

When the app become active, the SDK check the last update of data lifecycle calling the UserDataCleaner class : 
```swift
func applicationDidBecomeActive(_ application: UIApplication) {
    WoosmapGeofencing.shared.didBecomeActive()
}
```

### Import data from a CSV

In the package of the app, 2 CSV files are included to simulate location and visits to create ZOI classified. 
On push button "Test Data" the app call the method mockVisitData() to import data from the CSV "Visit_qualif.csv" which contains 637 visits.
The method mockLocationsData() import data from the CSV "Locations.csv" which contains locations and visits.
