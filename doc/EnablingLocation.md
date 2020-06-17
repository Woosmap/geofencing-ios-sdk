## Setting Up Core Location

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
