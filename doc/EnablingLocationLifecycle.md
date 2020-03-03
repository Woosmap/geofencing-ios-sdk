
##  LifeCycle

According to official [documentation]( [https://developer.apple.com/documentation/uikit/app_and_environment/managing_your_app_s_life_cycle]), the app can be in four different states :
* Foreground active, the app is turned on and in use. Only the user can decide to exit this state.
* Foreground inactive, this mode is only available if the mode has been checked in the project settings. We can continue to make calculations or receive localizations. The application is notified that it is going from the foreground to the bottom. The app never stays in this state for long. If it receives geolocation, its lifespan is at most one hour. On the other hand, in the case where it broadcasts or records sound, the delays are almost infinite (spotify, microphone, etc.).
* Inactive background, the application is frozen until further notice. That is, it does nothing at all until the user passes it to the foreground, or it has not been woken up by the system to process a notification from the latter ( new location available, push notification, timer, etc.). When the app is woken up, it has a very short lapse of time to process this notification (a few seconds). This is enough to store a position, but not to send it for sure. We can ask for more time to process the position (which woozies does). You can go up to several minutes (between 2 and 3). The most important thing is to notify the system that you have finished, otherwise it will not wake up the application the next time, it will be definitively finished. The application is notified when it is about to be frozen.
* Killed (finished), the application has been definitively closed by the system to free the memory, or it was killed by the user (multitasking swippe up). The application no longer exists in RAM, but can be restarted by the system to process a notification from the latter (same as frozen). In other words, unless the user has blocked background usage, he cannot prevent the application from being restarted by the system without deleting it. Killing in multitasking is not enough. The application is not notified when it is killed unless it is still active (in the background or in the foreground) and it is killed explicitly by the user.

## Enable Location in background

As soon as the app enters the suspended state (in other words the app is still resident in memory but is no longer executing code) the updates will stop. If location updates are required even when the app is suspended (a key requirement for navigation based apps), continuous background location updates must be enabled for the app. When enabled, the app will be woken from suspension each time a location update is triggered and provided the latest location data.

To enable continuous location updates is a two-step process beginning with addition of an entry to the project Info.plist file. This is most easily achieved by enabling the location updates background mode in the Xcode Capabilities panel as shown in :
<p align="center">
  <img alt="Background Mode" src="/assets/BackgroundMode.png" width="50%">
</p>

Within the app code, continuous updates are enabled by setting the allowsBackgroundLocationUpdates property of the location manager to true:
```swift
myLocationManager.allowsBackgroundLocationUpdates = true
```
To allow the location manager to temporarily suspend updates, set the pausesLocationUpdatesAutomatically property of the location manage to true.
```swift
myLocationManager.pausesLocationUpdatesAutomatically = true
```

See the reference Apple [documentation](https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/handling_location_events_in_the_background)
