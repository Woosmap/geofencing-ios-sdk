In order to retrieve the mobile location when necessary (a notification payload asking for the location), you need to set temporarilythe Location Manager in the main thread when receiving proper notifications. Here is a trick to do so.

## Check Payload

Check presence of the parameter "category = location" in the payload Json.
```swift
if let category = aps["category"] as? NSString {
	if (category == "location") {
	setupLocationManager()
	return
	}
}
```

## Setup the location manager

```swift
// Setup The location manager
func setupLocationManager(){
	let queue = OperationQueue()
	queue.addOperation {
		let _ = self.locationManager
	}
	queue.waitUntilAllOperationsAreFinished()
	locationManager.delegate = self
	locationManager.startUpdatingLocation()
}
```
In our case, we will create a CLLocationManager when we receive a notification in the didReceiveNotificationRequest method. The location manager performs its operations outside of the mainThread. To execute these operations, you must include it in the mainThread operation queue and wait for the end of the manager's operations execution.
By placing this operation on the main queue, you ensure that setting up the manager happens on the main thread.
On the callback event of location manager to update locations, we can get an array of CLLocation objects containing the location data. After that, you must stop the location manager update by call the method :
```swift
// Stop location service
locationManager.stopUpdatingLocation()
locationManager.stopUpdatingHeading()
```
