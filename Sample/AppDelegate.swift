//
//  AppDelegate.swift
//  WoosmapGeofencing
//
//

import UIKit
import CoreLocation
import WoosmapGeofencing
import RealmSwift
#if canImport(AirshipCore)
  import AirshipCore
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let dataLocation = DataLocation()
    let dataPOI = DataPOI()
    let dataDistance = DataDistance()
    let dataRegion = DataRegion()
    let dataVisit = DataVisit()
    let airshipEvents = AirshipEvents()
    let marketingCloudEvents = MarketingCloudEvents()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UserDefaults.standard.register(defaults: ["TrackingEnable": true,
                                                  "ModeHighfrequencyLocation":false,
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
        
        
        // Set delegate of protocol Location, POI and Distance
        WoosmapGeofencing.shared.getLocationService().locationServiceDelegate = dataLocation
        WoosmapGeofencing.shared.getLocationService().searchAPIDataDelegate = dataPOI
        WoosmapGeofencing.shared.getLocationService().distanceAPIDataDelegate = dataDistance
        WoosmapGeofencing.shared.getLocationService().regionDelegate = dataRegion
        
        //Set delagate for Marketing Cloud
        //WoosmapGeofencing.shared.getLocationService().marketingCloudEventsDelegate = marketingCloudEvents
      
        // Enable Visit and set delegate of protocol Visit
        WoosmapGeofencing.shared.getLocationService().visitDelegate = dataVisit
        
        WoosmapGeofencing.shared.startTracking(configurationProfile: ConfigurationProfile.passiveTracking)
        
        //openRealm()

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
    
    func openRealm() {
        let bundlePath = Bundle.main.path(forResource: "default", ofType: "realm")!
        
        let defaultPath = Realm.Configuration.defaultConfiguration.fileURL!.path
        let fileManager = FileManager.default

        // Only need to copy the prepopulated `.realm` file if it doesn't exist yet
        if !fileManager.fileExists(atPath: defaultPath){
            print("use pre-populated database")
            do {
                try fileManager.copyItem(atPath: bundlePath, toPath: defaultPath)
                print("Copied")
            } catch {
                print(error)
            }
        }

    } //f

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
}
