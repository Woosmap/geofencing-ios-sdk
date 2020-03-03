No need to collect a location and display a notification if it’s not the right time anymore. Verify first if the notification expedition time is not too different from the notification reception time on the mobile.

## Delay timeout

Set the out of time delay in second : 
```swift
let outOfTimeDelay = 300
```

## Compare with Server Timestamp

In the didReiceive method parse the notification payload to extract the timestamp provided by the notification server. Then compare it with the mobile local timestamp and the outOfTimeDelay you defined (the timestamp is the time in second in UTC since 1970) thanks to the following code:
```swift
if let timeStampServer = aps["timestamp"] as ? Int {
	let currentTime = Date().timeIntervalSince1970
	// convert to Integer
	let timeStampLocal = Int(currentTime)
	
	if (timeStampServer + outOfTimeDelay < timeStampLocal) {
		// the notification is too late, change the payload_
		bestAttemptContent?.body = "OUT OF TIME"
		// deliver the notifation
		contentHandler(bestAttemptContent!.copy() as! UNNotificationContent)
		return
	}
}
```
