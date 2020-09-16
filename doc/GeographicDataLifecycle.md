## Geographic Data Lifecycle and import data from a CSV

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

The method cleanOldGeographicData() save in the UserDefaults the date of the l