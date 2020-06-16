
##  Get user location
According to official [documentation](https://developer.apple.com/documentation/corelocation/getting_the_user_s_location), we do not decide how many locations the system will send us, or how often. On the other hand, the system sends us back all the information compiled from the various instruments at its disposal. It does not make sense to try to double the information with the observation of the gyroscope, the accelerometer or the compass.
The OS analyzes all of its sensors, and defines what the user is doing to send us the most reliable information possible. Models with a motion coprocessor (from 5S) see their CPU usage (and therefore battery) greatly reduced for processing this information, which allows our application to also consume little energy.

Three services are available to obtain the position of a user:
* **The standard location service**, when we subscribe to it, we can define the precision criteria we want, as well as the minimum distance between two points. The system allows us to know if the user is moving and how (bike, car, on foot ...). We can therefore adapt the distance filter (minimum between two points) according to the mode of movement. We use this mode when the app is in the foreground, asking for the most precise location, and adapting the filter. This mode is not viable in the background in the long term. Indeed, a background app that requires this kind of position will only have a very short lifespan before being killed by the system (approx 1h max) which will also depend on the use of the phone.
* **Significant-change location service**, there are no general rules that define such a move. Overall, the cross-checked information indicates that it is necessary to get out of a radius of 500m and about 5 minutes apart (depending on the speed of movement) between two positions. It would appear that trips are notified when the phone changes the relay antenna. As seen above, even if the application is not running, it can be woken up when a new significant movement is detected. In our case the application is woken up to save the new position. On the other hand, the position provided by default is only imprecise, the SDK therefore turns on the GPS time to recover a better position, send it and then return the hand.

## Geofencing iOS


The service of significant displacements of the phone using too much the battery without giving us enough points, we developed method using geofencing iOS.

As a user moves, we create geofencing zones around them. When the user leaves or enters one of these zones, the application will wake up (background-active), request a position, send it, then calculate new geofencing zones according to the obtained position.
<p align="center">
  <img alt="GeoSearch with Regions detections" src="https://github.com/woosmap/woosmap-geofencing-ios-sdk/raw/master/assets/WoosmapGeofencing3.png" width="30%">
</p>
