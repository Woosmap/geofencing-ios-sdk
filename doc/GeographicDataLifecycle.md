## Geographic Data Lifecycle and import data from a CSV

### Geographic Data Lifecycle

To be in compliance with GDPR, you must erase all data about locations, visits and ZOIs beyond 30 days. The database is on the app not in the Geofencing SDK,
so its your responsability to manage the data. 

In the sample App, you have an example to how manage data lifecycle. In the Settings class of the app, you have a parameter to set about the delay of duration data :
```swift
//Delay of Duration data
public var dataDurationDelay = 30// number of day
```

When the app become active, the app check the last update of data lifecycle calling the UserDataCleaner class : 
```swift
func applicationDidBecomeActive(_ application: UIApplication) {
    WoosmapGeofencing.shared.didBecomeActive()
    let userDataCleaner = UserDataCleaner()
    userDataCleaner.cleanOldGeographicData()
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
```

The method cleanOldGeographicData() save in the UserDefaults the date of the last check for cleanning of the database.
If the date of the last check is more than one day, the database is cleanned : 
```swift
let lastDateUpdate = UserDefaults.standard.object(forKey: "lastDateUpdate") as? Date
if (lastDateUpdate != nil) {
       let dateComponents = Calendar.current.dateComponents([.day], from: lastDateUpdate!, to: Date())
       //update date if no updating since 1 day
       if (dateComponents.day! >= 1) {
           //Cleanning database
           removeLocationOlderThan(days: dataDurationDelay)
           removeVisitOlderThan(days: dataDurationDelay)
           NotificationCenter.default.post(name: .reloadData, object: self)
       }
}
//Update date
UserDefaults.standard.set(Date(), forKey:"lastDateUpdate")
```

### Import data from a CSV

In the package of the app, 2 CSV files are included to simulate location and visits to create ZOI classified. 
On push button "Test Data" the app call the method mockVisitData() to import data from the CSV "Visit_qualif.csv" which contains 637 visits.
The method mockLocationsData() import data from the CSV "Locations.csv" which contains locations and visits.