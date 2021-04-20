
## Setting Up Core Location

### Location Permissions
The sdk needs some permissions to work.
To be able to take background position readings you will need the **whenInUse** permission.
If you want to take readings permanently the **always** permissions will be required.

In these two cases you will also need to activate background mode in Xcode.

<p align="center">
  <img alt="Background Mode" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/BackgroundMode.png" width="50%">
</p>
 
 Since iOS 10 it's mandatory to provide a usage description in the `info.plist` if trying to access privacy-sensitive data. When the system prompts the user to allow access, this usage description string will be displayed as part of the permission dialog box, but if you didn't provide the usage description, the app will crash before showing the dialog. Also, Apple will reject apps that access private data but don't provide a usage description.

 This SDK require the following usage description:

 * `NSLocationWhenInUseUsageDescription` describes the reason that the app accesses the user's location, this is used while the app is running in the foreground.
 * `NSLocationAlwaysAndWhenInUseUsageDescription` describes the reason that the app is requesting access to the user’s location information at all times. Use this key if your iOS app accesses location information while running in the background and foreground. 
 * `NSLocationAlwaysUsageDescription` describes the reason that the app is requesting access to the user's location at all times. Use this key if your app accesses location information in the background and you deploy to a target earlier than iOS 11. For iOS 11 and later, add both `NSLocationAlwaysUsageDescription` and `NSLocationAlwaysAndWhenInUseUsageDescription` to your app’s `Info.plist` file with the same message.

 These descriptions can be configured in the **info.plist** file, by adding the following keys:

* The three keys for the location permission

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This text is shown when permission to use the location of the device is requested. Note that for the app to be accepted in the App Store, the description why the app needs location services must be clear to the end user.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This text is shown when permission to use the location of the device is requested. Note that for the app to be accepted in the App Store, the description why the app needs location services must be clear to the end user.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This text is shown when permission to use the location of the device is requested. Note that for the app to be accepted in the App Store, the description why the app needs location services must be clear to the end user.</string>
```

Here’s the code to get you started with Core Location in your iOS application:
```swift
var locationManager = CLLocationManager()  
locationManager.requestAlwaysAuthorization()
```
For  `allowsBackgroundLocationUpdates`, ensure that you’ve enabled the Background mode location from the Capabilities in your Xcode project.

iOS 13 has the following three location permissions (ignore Denied since it ignores the permission):

-   **Allow While Using App**  — has superpowers allowed when the app is in foreground
-   **Allow Once**  — temporary allow While Using App
-   **Allowed**  — deferred until really needed


## Allow Once Permission

Allow Once is similar to Allow While Using, but only for one foreground session. That means that once you leave the application for a considerable time, the permission state changes to  `notDetermined`.

The next time the user starts the application, the developer can ask for the permissions again, depending on their use case. This gives users some finer control over the location data and also allows the developers to handle on/off location cases easily.

## “Always Allow” Hidden in Allow While Using App Permission

Allow While Using App permission defers the Always Allow permission.

Always Allow permission isn’t there by default in the new permission dialog. It’s there in a provisional form so that it can be used when it’s actually required.

Let’s see how that works with the different kinds of location authorizations.

![Prompt flow](https://raw.githubusercontent.com/woosmap/woosmap-geofencing-ios-sdk/master/assets/location-prompt-flow-ios-13.png)

If user will press the best positive answer in that case which is Allow While Using App the operating system will remember that.System will present user alert at some point of time when some special event occurs. System will present alert with Keep Only While Using and Change to Always Allow options. For more information you can check on video from WWDC 2019 : https://developer.apple.com/videos/play/wwdc2019/705/

## Request Authorization

You can request of two authorization cases.

### `requestAlwaysAuthorization`

-   Allow While Using App permission handles Always Allows Allow permission only if you've requested location authorization using  `requestAlwaysAuthorisation`.
-   With the above type of authorization, the user sees it as foreground permission, but  `CoreLocation`  informs the Delegate that it’s  `always`  permission. This way, it can monitor location events in the background, but the  `CLLocationManagerDelegate`  cannot receive those events.
-   `CoreLocation`  holds onto the events and asks the user at an appropriate time whether they would like to  `**Always Allow?**`. After that, the location events can be received in the background as well.
-   This way, Always Allow is deferred until a stage where it really requires the user’s consent for location updates in the background.
-   The above case makes Always Allow a provisional authorization.

### `requestWhenInUseAuthorization`

-   When user chooses Keep Only While Using. In this case, Always Allowed never happens since the developers themselves hadn’t set it on the  `CLLocationManager`  instance. This situation is identical to choosing Allow While Using App the first time.
-   Location is only accessed when the application is in the foreground (though it continues to access it for a very short interval once the user switches to the background).
