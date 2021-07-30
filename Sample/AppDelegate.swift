//
//  AppDelegate.swift
//  WoosmapGeofencing
//
//

import UIKit
import CoreLocation
import WoosmapGeofencing
//import MarketingCloudSDK
#if canImport(AirshipCore)
  import AirshipCore
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate  {

    var window: UIWindow?
    let dataLocation = DataLocation()
    let dataPOI = DataPOI()
    let dataDistance = DataDistance()
    let dataRegion = DataRegion()
    let dataVisit = DataVisit()
    let airshipEvents = AirshipEvents()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


        
        UserDefaults.standard.register(defaults: ["TrackingEnable": true,
                                                  "ModeHighfrequencyLocation":false,
                                                 "SearchAPIEnable": true,
                                                 "DistanceAPIEnable": false,
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
            UAirship.push()?.userPushNotificationsEnabled = false
            UAirship.push()?.defaultPresentationOptions = [.alert,.badge,.sound]
            UAirship.push()?.isAutobadgeEnabled = false


            // Print out the application configuration for debugging (optional)
            print("Config:\n \(config)")
            WoosmapGeofencing.shared.getLocationService().airshipEventsDelegate = airshipEvents
        #endif

        
        WoosmapGeofencing.shared.getLocationService().airshipEventsDelegate = airshipEvents

        // Set private Woosmap key API
        WoosmapGeofencing.shared.setWoosmapAPIKey(key: WoosmapKey)
        WoosmapGeofencing.shared.setGMPAPIKey(key: GoogleStaticMapKey)

        // Set the search url Woosmap API
        WoosmapGeofencing.shared.setSearchWoosmapAPI(api: searchWoosmapAPI)

        // Set the distance url Woosmap API
        WoosmapGeofencing.shared.setDistanceWoosmapAPI(api: distanceWoosmapAPI)
        WoosmapGeofencing.shared.setDistanceAPIMode(mode: DistanceMode.driving)
        
        // Set delegate of protocol Location, POI and Distance
        WoosmapGeofencing.shared.getLocationService().locationServiceDelegate = dataLocation
        WoosmapGeofencing.shared.getLocationService().searchAPIDataDelegate = dataPOI
        WoosmapGeofencing.shared.getLocationService().distanceAPIDataDelegate = dataDistance
        WoosmapGeofencing.shared.getLocationService().regionDelegate = dataRegion

        // Enable Visit and set delegate of protocol Visit

        WoosmapGeofencing.shared.getLocationService().visitDelegate = dataVisit
        
        WoosmapGeofencing.shared.startTracking(configurationProfile: ConfigurationProfile.liveTracking)


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

        
        // -- SFMC --
        //self.configureMarketingCloudSDK()
        
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
        print("applicationDidEnterBackground")
        if CLLocationManager.authorizationStatus() != .notDetermined {
            WoosmapGeofencing.shared.startMonitoringInBackground()
        }

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        // Set Refreshing Position Hight frequency state
        WoosmapGeofencing.shared.setModeHighfrequencyLocation(enable: false)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        WoosmapGeofencing.shared.didBecomeActive()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler([.alert,.badge])
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
    
    
    // -------------------- SFMC ------------------------------------------------------
    // --------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------

    
    

        
        
        // MobilePush SDK: REQUIRED IMPLEMENTATION
        
        // The appID, accessToken and appEndpoint are required values for MobilePush SDK configuration and are obtained from your MobilePush app.
        // See https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/get-started/get-started-setupapps.html for more information.
        
        // Use the builder method to configure the SDK for usage. This gives you the maximum flexibility in SDK configuration.
        // The builder lets you configure the SDK parameters at runtime.
        /*

        let appID = "218fbb61-d43f-4e3c-9541-770f0f5a94c3"
        let accessToken = "qGZNbR6lLYcqHslHfRXtqxLh"
        let appEndpoint = "https://mcdmfc5rbyc0pxgr4nlpqqy0j-x1.device.marketingcloudapis.com/"
        let mid = "510004998"


        
        // Define features of MobilePush your app will use.
        let inbox = false
        let location = false
        let analytics = false
        
        
        // MobilePush SDK: REQUIRED IMPLEMENTATION
        @discardableResult
        func configureMarketingCloudSDK() -> Bool {
            // Use the builder method to configure the SDK for usage. This gives you the maximum flexibility in SDK configuration.
            // The builder lets you configure the SDK parameters at runtime.
            let builder = MarketingCloudSDKConfigBuilder()
                .sfmc_setApplicationId(appID)
                .sfmc_setAccessToken(accessToken)
                .sfmc_setMarketingCloudServerUrl(appEndpoint)
                .sfmc_setMid(mid)
                .sfmc_setInboxEnabled(inbox as NSNumber)
                .sfmc_setLocationEnabled(location as NSNumber)
                .sfmc_setAnalyticsEnabled(analytics as NSNumber)
                .sfmc_build()!
            
            var success = false
            
            // Once you've created the builder, pass it to the sfmc_configure method.
            do {
                try MarketingCloudSDK.sharedInstance().sfmc_configure(with:builder)
                success = true
            } catch let error as NSError {
                // Errors returned from configuration will be in the NSError parameter and can be used to determine
                // if you've implemented the SDK correctly.
                
                let configErrorString = String(format: "MarketingCloudSDK sfmc_configure failed with error = %@", error)
                print(configErrorString)
            }
            
            if success == true {
                // The SDK has been fully configured and is ready for use!
                
                // Enable logging for debugging. Not recommended for production apps, as significant data
                // about MobilePush will be logged to the console.
                MarketingCloudSDK.sharedInstance().sfmc_setDebugLoggingEnabled(true)
            }
            
            MarketingCloudSDK.sharedInstance().sfmc_setURLHandlingDelegate(self)

                    // Make sure to dispatch this to the main thread, as UNUserNotificationCenter will present UI.
                    DispatchQueue.main.async {
                        if #available(iOS 10.0, *) {
                            // Set the UNUserNotificationCenterDelegate to a class adhering to thie protocol.
                            // In this exmple, the AppDelegate class adheres to the protocol (see below)
                            // and handles Notification Center delegate methods from iOS.
                            UNUserNotificationCenter.current().delegate = self
                            
                            // Request authorization from the user for push notification alerts.
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(_ granted: Bool, _ error: Error?) -> Void in
                                if error == nil {
                                    if granted == true {
                                        // Your application may want to do something specific if the user has granted authorization
                                        // for the notification types specified; it would be done here.
                                        print(MarketingCloudSDK.sharedInstance().sfmc_deviceToken() ?? "error: no token - was UIApplication.shared.registerForRemoteNotifications() called?")
                                    }
                                }
                            })
                        }
                        
                        // In any case, your application should register for remote notifications *each time* your application
                        // launches to ensure that the push token used by MobilePush (for silent push) is updated if necessary.
                        
                        // Registering in this manner does *not* mean that a user will see a notification - it only means
                        // that the application will receive a unique push token from iOS.
                        UIApplication.shared.registerForRemoteNotifications()
                    }
            return success
        }
    /*
        
        // MobilePush SDK: OPTIONAL IMPLEMENTATION (if using Data Protection)
        /*func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
            if(MarketingCloudSDK.sharedInstance().sfmc_isReady() == false)
            {
                self.configureMarketingCloudSDK()
            }
        }*/
    
      */
    // Implement the protocol method and have iOS handle the URL itself
    func sfmc_handle(_ url: URL, type: String) {
        if UIApplication.shared.canOpenURL(url) == true {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    if success {
                        print("url \(url) opened successfully")
                    } else {
                        print("url \(url) could not be opened")
                    }
                })
            } else {
                if UIApplication.shared.openURL(url) == true {
                    print("url \(url) opened successfully")
                } else {
                    print("url \(url) could not be opened")
                }
            }
        }
    }
        
    */
}
