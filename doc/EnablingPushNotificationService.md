## Overview

You need to create an App ID in your developer account and enable the push notification entitlement. Xcode has a simple way to do this, click the  **_Capabilities_**  tab and set the  _**Push Notifications**_  switch  **_On_**.

After loading, it should look like this:
![Capability](https://raw.githubusercontent.com/woosmap/woosmap-geofencing-ios-sdk/master/assets/Push-Notification-Capability.png)

## Asking for User Notifications Permission

Two steps to register for push notifications: first, you must get the user’s permission to show notifications. Then, you can register the device to receive remote (push) notifications. If all goes well, the system will then provide you with a  **_device token_**, which you can think of as an “address” of this device.

You’ll register for push notifications immediately after the app launches. Ask for user permissions first.

Open  **_AppDelegate.swift_**  and add the following to the top of the file:
```swift
    import UserNotifications
```
Then, add the following method to the end of `AppDelegate`:
```swift
func application(_application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
	if #available(iOS 10, *) {
		UNUserNotificationCenter.current().delegate = self as? 		
		UNUserNotificationCenterDelegate
		UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { granted, error in }
	} else {
		application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: **nil**))
	}
	application.registerForRemoteNotifications()
```
Going over the code above:

1.  `UNUserNotificationCenter`  handles all notification-related activities in the app.
2.  You invoke  `requestAuthorization(options:completionHandler:)`  to request authorization to show notifications (you guessed it). The passed  `options` indicate the types of notifications you want your app to use – here you’re requesting alert, sound and badge.
3.  The completion handler receives a Bool which indicates if authorization was successful. In this case, you just print the result.

Build and run. When the app launches, you should receive a prompt that asks for permission to send you notifications. (see illustration below)
<p align="center">
  <img alt="Notification Allow" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/notifallow.png" width="30%">
</p>


Calling `registerForPushNotifications()` here ensures the app will attempt to register for push notifications any time it’s launched.

##  Registering With APNs

Add the following two methods to the end of `AppDelegate`. iOS will call these to inform you about the result of `registerForRemoteNotifications()`:
```swift
// Handle remote notification registration. (succes)_
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
	let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
	print("this will return '32 bytes' in iOS 13+ rather than the token \			(tokenString)")
	NSLog("%%%%% THE the token: %@", tokenString);
}

// Handle remote notification registration. (failed)_
func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
	NSLog("Error on getting remote notification token : \(error.localizedDescription)")
}
```
Once the registration completes, iOS calls  `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` if successful. If not, it calls  `application(_:didFailToRegisterForRemoteNotificationsWithError:)`.

The current implementation of  `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` looks cryptic, but it’s simply taking  `deviceToken` and converting it to a string. The device token is the fruit of this process. It’s provided by APNs and uniquely identifies this app on this particular device. When sending a push notification, the server uses tokens as “addresses” to deliver to the correct devices. In your app, you would now send this token to your server, so that it could be saved and later used for sending notifications.

That’s it! Build and run on a device. You should receive a token in the console output. 

Copy this token, you’ll need it for testing.

## Testing your Push Notification code

Launch  _PushNotifications_  and complete the following steps:

1.  Under  _Authentication_, select  _Token_.
2.  Click the  _Select P12_  button and select the .p12 file from the previous section.
3.  Under  _Body_, enter your app’s Bundle ID and your device token.
4.  Change the request body to look like this:
```json
{
  "aps": {
    "alert" : {
    "title" : "Push Remote Rich Notifications",
    "subtitle" : "Web Geo Services",
    "body" : "Location"
	},
	"mutable-content" : 1,
	"timestamp" : 1578321331,
	"category" : "location"
	  }
}
```



