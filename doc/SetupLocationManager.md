## Check Payload

Check if in the payload you have the parameter "category = location" in the json.
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
In our case, we will create a CLLocationManager when we receive a notification in the didReceiveNotificationRequest method. The location manager performs his operations outside the mainThread. To execute its operations you must include it in the mainThread operation queue and wait for the end of the manager's operations execution.

By placing this operation in the main queue, we are sure that the configuration of eating takes place on the main thread.

On the callback event of location manager to update locations, we can get an An array of `CLLocation` objects containing the location data. After that, you must the location manager update by call the method :
```swift
// Stop location service
locationManager.stopUpdatingLocation()
locationManager.stopUpdatingHeading()
```
