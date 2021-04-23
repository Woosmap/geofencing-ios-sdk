//
//  AppDelegate.swift
//  WoosmapGeofencing
//
//

import UIKit
import CoreLocation
import WoosmapGeofencing
#if canImport(AirshipCore)
  import AirshipCore
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataLocation = DataLocation()
    let dataPOI = DataPOI()
    let dataDistance = DataDistance()
    let dataRegion = DataRegion()
    let dataVisit = DataVisit()
    let airshipEvents = AirshipEvents()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UserDefaults.standard.register(defaults: ["TrackingEnable": true,
                                                  "RefreshPositionEnable":false,
                                                 "SearchAPIEnable": true,
                                                 "DistanceAPIEnable": true,
                                                 "searchAPICreationRegionEnable": true])

        #if canImport(AirshipCore)
            // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
            // or set runtime properties here.
            let config = UAConfig.default()

            if (config.validate() != true) {
                showInvalidConfigAlert()
                return true
            }

            // Set log level for debugging config loading (optional)
            // It will be set to the value in the loaded config upon takeOff
            UAirship.setLogLevel(UALogLevel.trace)

            config.messageCenterStyleConfig = "UAMessageCenterDefaultStyle"

            // You can then programmatically override the plist values:
            // config.developmentAppKey = "YourKey"
            // etc.
            // Call takeOff (which creates the UAirship singleton)
            UAirship.takeOff(config)
            UAirship.push()?.userPushNotificationsEnabled = true
            UAirship.push()?.defaultPresentationOptions = [.alert,.badge,.sound]
            UAirship.push()?.isAutobadgeEnabled = true


            // Print out the application configuration for debugging (optional)
            print("Config:\n \(config)")
            WoosmapGeofencing.shared.getLocationService().airshipEventsDelegate = airshipEvents
        #endif
    
        
        // Set private Woosmap key API
        WoosmapGeofencing.shared.setWoosmapAPIKey(key: WoosmapKey)
        WoosmapGeofencing.shared.setGMPAPIKey(key: GoogleStaticMapKey)

        // Set the search url Woosmap API
        WoosmapGeofencing.shared.setSearchWoosmapAPI(api: searchWoosmapAPI)

        // Set the distance url Woosmap API
        WoosmapGeofencing.shared.setDistanceWoosmapAPI(api: distanceWoosmapAPI)
        WoosmapGeofencing.shared.setDistanceAPIMode(mode: DistanceMode.driving)

        // Set your filter on position location and search
        //WoosmapGeofencing.shared.setCurrentPositionFilter(distance: 10.0, time: 10)
        //WoosmapGeofencing.shared.setSearchAPIFilter(distance: 10.0, time: 10)

        // Set classification of zoi enable
        WoosmapGeofencing.shared.setClassification(enable: true)

        WoosmapGeofencing.shared.setFirstSearchAPIRegionRadius(radius: 100.0)
        WoosmapGeofencing.shared.setSecondSearchAPIRegionRadius(radius: 200.0)
        WoosmapGeofencing.shared.setThirdSearchAPIRegionRadius(radius: 300.0)

        // Set delegate of protocol Location, POI and Distance
        WoosmapGeofencing.shared.getLocationService().locationServiceDelegate = dataLocation
        WoosmapGeofencing.shared.getLocationService().searchAPIDataDelegate = dataPOI
        WoosmapGeofencing.shared.getLocationService().distanceAPIDataDelegate = dataDistance
        WoosmapGeofencing.shared.getLocationService().regionDelegate = dataRegion

        // Enable Visit and set delegate of protocol Visit
        WoosmapGeofencing.shared.setVisitEnable(enable: true)
        WoosmapGeofencing.shared.getLocationService().visitDelegate = dataVisit

        // Set Tracking state
        WoosmapGeofencing.shared.setTrackingEnable(enable: UserDefaults.standard.bool(forKey: "TrackingEnable"))

        // Set SearchAPI automatic on each location
        WoosmapGeofencing.shared.setSearchAPIRequestEnable(enable: UserDefaults.standard.bool(forKey: "SearchAPIEnable"))

        // Set 3 Creations Regions POI from Search API result
        WoosmapGeofencing.shared.setSearchAPICreationRegionEnable(enable: UserDefaults.standard.bool(forKey: "searchAPICreationRegionEnable"))

        // Set DistanceAPI automatic on each POI
        WoosmapGeofencing.shared.setDistanceAPIRequestEnable(enable: UserDefaults.standard.bool(forKey: "DistanceAPIEnable"))

        // Check if the authorization Status of location Manager
        if CLLocationManager.authorizationStatus() != .notDetermined {
            WoosmapGeofencing.shared.startMonitoringInBackground()
        }

        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in }
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        }
        application.registerForRemoteNotifications()

        return true
    }

    // Handle remote notification registration. (succes)
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("this will return '32 bytes' in iOS 13+ rather than the token \(tokenString)")
        NSLog("%%%%% THE the token: %@", tokenString)
        UserDefaults.standard.set(tokenString, forKey: "TokenID")
    }

    // Handle remote notification registration. (failed)
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Error on getting remote notification token : \(error.localizedDescription)")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if CLLocationManager.authorizationStatus() != .notDetermined {
            WoosmapGeofencing.shared.startMonitoringInBackground()
        }

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        WoosmapGeofencing.shared.didBecomeActive()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func showInvalidConfigAlert() {
            let alertController = UIAlertController.init(title: "Invalid AirshipConfig.plist", message: "The AirshipConfig.plist must be a part of the app bundle and include a valid appkey and secret for the selected production level.", preferredStyle:.actionSheet)
            alertController.addAction(UIAlertAction.init(title: "Exit Application", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                exit(1)
            }))

            DispatchQueue.main.async {
                alertController.popoverPresentationController?.sourceView = self.window?.rootViewController?.view

                self.window?.rootViewController?.present(alertController, animated:true, completion: nil)
            }
        }
}
