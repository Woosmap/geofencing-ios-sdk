## Overview

Notification extensions allow you to change the payload for notifications, and content extensions allow you to display a custom interface for notifications. They give a delay to process the notification payloads before the notification is displayed to the user. For example, upload an image, GIF, Video, decrypt the text to display it in the notification.

The entry point is the UNNotificationServiceExtension class. 2 methods must be overloaded:
```swift
(void)didReceive:(_request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
```
This method is called when the extension starts. Here you can do the required processing on the notification, for example: change all the basic properties of a notification, including title, subtitle, body, number of badges, userInfo, audio download, images, GIFs, video once the media has been downloaded to the disc, define the media path by initializing an instance of [UNNotificationAttachment].
```swift
(void)serviceExtensionTimeWillExpire
```
The system gives you a limited time to process a notification. If this processing is not completed within the time limit, the expiration methods are called.

## Check Location permissions

In the `didReceive` method, check if Location services is enable and the authorization status :
```swift
if (!CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied
	|| CLLocationManager.authorizationStatus() == .notDetermined) {
	// deliver the notification
	contentHandler(bestAttemptContent!.copy() as! UNNotificationContent)
	return
} 
```
If the users don't give the permissions for location, modify the payload and deliver the notification.
