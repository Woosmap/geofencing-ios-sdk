//
//  NotificationService.swift
//  NotificationService
//
//

import UserNotifications
import CoreLocation
import WoosmapGeofencing

open class NotificationService: UNNotificationServiceExtension,CLLocationManagerDelegate {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var currentLocation:CLLocation?
    
    
    lazy var locationManager: CLLocationManager = {
        var manager: CLLocationManager!
        let op = BlockOperation {
            manager = CLLocationManager()
        }
        OperationQueue.main.addOperation(op)
        op.waitUntilFinished()
        return manager
    }()
    
    
    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // if category is Location, setup the location manager and send request on Search API
        if let aps = bestAttemptContent!.userInfo["aps"] as? NSDictionary {
            if let timeStampServer = aps["timestamp"] as? Int {
                let currentTime = Date().timeIntervalSince1970
                // convert to Integer
                let timeStampLocal = Int(currentTime)
                if (timeStampServer + outOfTimeDelay < timeStampLocal) {
                    // the notification is too late, change the payload
                    bestAttemptContent?.body = "OUT OF TIME"
                    // deliver the payload
                    contentHandler(bestAttemptContent!.copy() as! UNNotificationContent)
                    return
                }
            } else {
                // No timestamp is defined in the payload
                bestAttemptContent?.body = "No timestamp"
                // deliver the payload
                contentHandler(bestAttemptContent!.copy() as! UNNotificationContent)
                return
            }
            if let category = aps["category"] as? NSString {
                if (category == "location") {
                    setupLocationManager()
                    return
                }
            }
        }
        // deliver the payload if is not category
        contentHandler(bestAttemptContent!.copy() as! UNNotificationContent)
        
    }
    
    // Setup The location manager
    func setupLocationManager(){
        let queue = OperationQueue()
        queue.addOperation {
            let _ = self.locationManager
        }
        queue.waitUntilAllOperationsAreFinished()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
    }
    
    // Below method will provide you current location.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            currentLocation = locations.last
            locationManager.stopMonitoringSignificantLocationChanges()
            
            // Get the current coordiante
            let userLatitude: String = String(format: "%f", currentLocation!.coordinate.latitude)
            let userLongitude: String = String(format:"%f", currentLocation!.coordinate.longitude)
            
            if(!searchWoosmapKey.isEmpty && !GoogleStaticMapKey.isEmpty) {
                // Show Notifcation with the nearest POI and static map
                showNotificationWithPOIAndGMP(myLatitude: userLatitude, myLongitude: userLongitude)
            } else if (!searchWoosmapKey.isEmpty && GoogleStaticMapKey.isEmpty) {
                // Show Notifcation with the user location with the nearest POI
                showNotificationWithPOI(myLatitude: userLatitude, myLongitude: userLongitude)
            } else if (searchWoosmapKey.isEmpty && !GoogleStaticMapKey.isEmpty) {
                // Show Notifcation with the user location on a static map
                showNotificationWithGMP(myLatitude: userLatitude, myLongitude: userLongitude)
            } else if (searchWoosmapKey.isEmpty && GoogleStaticMapKey.isEmpty) {
                // Show Notifcation with the user location
                showNotificationWithUserLocation(myLatitude: userLatitude, myLongitude: userLongitude)
            }
            
            // Stop location service
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
        }
    }
    
    func showNotificationWithPOIAndGMP(myLatitude: String, myLongitude: String) {
       
        // Get POI nearest
        let storeAPIUrl: String = String(format: searchWoosmapAPI, myLatitude,myLongitude)
        let url = URL(string: storeAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
        var latitudePOI:Double?
        var longitudePOI:Double?
        
        // Call API search
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.showNoficationError(response: response as! HTTPURLResponse, isWoosmap: true)
            if let error = error {
                NSLog("error: \(error)")
            } else {
                let responseJSON = try? JSONDecoder().decode(SearchAPIData.self, from: data!)
                for feature in (responseJSON?.features)! {
                    //Get info POI from search API
                    let body = "City = \(feature.properties!.address!.city!) \nZipCode = \(feature.properties!.address!.zipcode!) \nDistance = \(feature.properties!.distance!)"
                    
                    //Set the body of the notification
                    self.bestAttemptContent?.body = body
                    
                    //Get coordinates of the POI
                    latitudePOI = (feature.geometry?.coordinates![1])!
                    longitudePOI = (feature.geometry?.coordinates![0])!
                }
                
                let staticMapUrl:String
                if (latitudePOI != nil) {
                    staticMapUrl = String(format: GoogleMapStaticAPITwoMark, String(describing:myLatitude),String(describing:myLongitude),String(describing:latitudePOI!),String(describing:longitudePOI!))
                } else {
                    staticMapUrl = String(format: GoogleMapStaticAPIOneMark, String(describing:myLatitude),String(describing:myLongitude))
                }
                let mapUrl = URL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

                // Call API Google Static Map
                URLSession.shared.downloadTask(with: mapUrl!) { (location, response, error) in
                    self.showNoficationError(response: response as! HTTPURLResponse, isWoosmap: false)
                    if let error = error {
                        NSLog("error: \(error)")
                    } else {
                        if let location = location {
                            // Move temporary fi@le to remove .tmp extension
                            let tmpDirectory = NSTemporaryDirectory()
                            let tmpFile = "file://".appending(tmpDirectory).appending(mapUrl!.lastPathComponent).appending(UUID().uuidString).appending(".jpg")
                            let tmpUrl = URL(string: tmpFile.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                            try! FileManager.default.moveItem(at: location, to: tmpUrl!)
                            
                            // Add the attachment to the notification content
                            if let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl!) {
                                self.bestAttemptContent?.attachments = [attachment]
                            }
                        }
                    }
                    // Serve the notification content
                    self.contentHandler!(self.bestAttemptContent!)
                }.resume()
            }
        }
        task.resume()
    }
    
    
    func showNotificationWithPOI(myLatitude: String, myLongitude: String) {
       
        // Get POI nearest
        let storeAPIUrl: String = String(format: searchWoosmapAPI, myLatitude,myLongitude)
        let url = URL(string: storeAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
        // Call API search
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.showNoficationError(response: response as! HTTPURLResponse, isWoosmap: true)
            if let error = error {
                NSLog("error: \(error)")
            } else {
                let responseJSON = try? JSONDecoder().decode(SearchAPIData.self, from: data!)
                for feature in (responseJSON?.features)! {
                    //Get info POI from search API
                    let body = "myLatitude = \(myLatitude) \nmyLongitude = \(myLongitude) \nCity = \(feature.properties!.address!.city!) \nZipCode = \(feature.properties!.address!.zipcode!) \nDistance = \(feature.properties!.distance!)"
                    //Set the body of the notification
                    self.bestAttemptContent?.body = body
                }
                // Serve the notification content
                self.contentHandler!(self.bestAttemptContent!)
            }
        }
        task.resume()
    }
    
    func showNotificationWithGMP(myLatitude: String, myLongitude: String) {
        let staticMapUrl:String = String(format: GoogleMapStaticAPIOneMark, String(describing:myLatitude),String(describing:myLongitude))
        let mapUrl = URL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        // Call API Google Static Map
        URLSession.shared.downloadTask(with: mapUrl!) { (location, response, error) in
            self.showNoficationError(response: response as! HTTPURLResponse, isWoosmap: false)
            if let error = error {
                NSLog("error: \(error)")
            } else {
                if let location = location {
                    // Move temporary fi@le to remove .tmp extension
                    let tmpDirectory = NSTemporaryDirectory()
                    let tmpFile = "file://".appending(tmpDirectory).appending(mapUrl!.lastPathComponent).appending(UUID().uuidString).appending(".jpg")
                    let tmpUrl = URL(string: tmpFile)!
                    try! FileManager.default.moveItem(at: location, to: tmpUrl)
                    
                    //Set the body of the notification
                    let body = "myLatitude = \(myLatitude) \nmyLongitude = \(myLongitude)"
                    self.bestAttemptContent?.body = body
                    
                    // Add the attachment to the notification content
                    if let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl) {
                        self.bestAttemptContent?.attachments = [attachment]
                    }
                }
                    
            }
            // Serve the notification content
            self.contentHandler!(self.bestAttemptContent!)
        }.resume()
    }
    
    func showNoficationError(response: HTTPURLResponse, isWoosmap: Bool){
        if (response.statusCode != 200) {
            NSLog("statusCode: \(response.statusCode)")
            var body = ""
            if isWoosmap {
                body = "Error Search API " + String(response.statusCode)
            }else {
                body = "Error Google Map API " + String(response.statusCode)
            }
            self.bestAttemptContent?.body = body
            // Serve the notification content
            self.contentHandler!(self.bestAttemptContent!)
        }
    }
    
    func showNotificationWithUserLocation(myLatitude: String, myLongitude: String) {
        //Set the body of the notification
        let body = "myLatitude = \(myLatitude) \nmyLongitude = \(myLongitude)"
        self.bestAttemptContent?.body = body
        
        // Serve the notification content
        self.contentHandler!(self.bestAttemptContent!)
    }
    // Below Mehtod will print error if not able to update location.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("#################didFailWithError###############")
    }
    
    override open func serviceExtensionTimeWillExpire() {
        NSLog("UNNotificationServiceExtension serviceExtensionTimeWillExpire")
    }
    
}


