//
//  AirshipEvents.swift
//  Sample
//
//

import Foundation
import CoreLocation
import WoosmapGeofencing
import MarketingCloudSDK
#if canImport(AirshipCore)
  import AirshipCore
#endif

public class AirshipEvents: AirshipEventsDelegate {
    
    public init() {}
    
    static var access_token: String = ""
    
    public func regionEnterEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        NSLog("regionEnterEvent : " + regionEvent.description)
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
        //SFMCEvent.customEvent(withName:"leo", withAttributes: ["leo":"leo"])
    }
    
    public func regionExitEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func visitEvent(visitEvent: Dictionary<String, Any>, eventName: String) {
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = visitEvent
            event.track()
        #endif
    }
    
    public func getBearer() {
        let url = URL(string: "https://mcdmfc5rbyc0pxgr4nlpqqy0j-x1.auth.marketingcloudapis.com/v2/Token")!
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

       
        // your post request data
        let body : [String: Any] = [
            "grant_type": "client_credentials",
            "client_id": "7oalkbl4iwd8t3ultnxu9mg6",
            "client_secret": "SdwwhNxywVs2IEc3akCdAs2r",
            "scope": "list_and_subscribers_read journeys_read",
            "account_id": "510004998"
                                        ]

        let bodyData = try? JSONSerialization.data(
                    withJSONObject: body,
                    options: [])
                
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = bodyData
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("getBearer - error: \(error!)")
                return
            }
                        
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("getBearer - No data")
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String:Any] else {
                print("getBearer - Not containing JSON")
                return
                }
            
            var response = (json.compactMapValues { $0 as? String })
            AirshipEvents.access_token = response["access_token"] ?? ""
            
            
            
            
            //print("getBearer - access_token: \(AirshipEvents.access_token)")
            return
        }
        
        task.resume()
        
    }
    
    public func pushDataToMC (poiData: [String: Any])
    {
        if(AirshipEvents.access_token == "")
        {
            self.getBearer()
        }
        
        
        let url = URL(string: "https://mcdmfc5rbyc0pxgr4nlpqqy0j-x1.rest.marketingcloudapis.com/interaction/v1/events")!
        var urlRequest = URLRequest(url: url)

        urlRequest.setValue("Bearer " + AirshipEvents.access_token, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")


        let bodyData = try? JSONSerialization.data(
                    withJSONObject: poiData,
                    options: [])
        
        print("lpernelle - body: \((bodyData! as AnyObject).description)")
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = bodyData
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { data, response, error in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }
                    
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("Not containing JSON")
                return
                }
            
            var errorMessage = (json.compactMapValues { $0 as? String })
            
            if errorMessage["message"] == "Not Authorized" {self.getBearer(); self.pushDataToMC(poiData: poiData)}
            
            print("lpernelle - json: \(json)")
            
        }
        
        task.resume()
    }
    
    public func poiEvent(POIEvent: Dictionary<String, Any>, eventName: String) {
        NSLog("Airship.poiEvent : " + POIEvent.description)
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = POIEvent
            event.track()
        #endif
        
        // your post request data
        let body : [String: Any] = ["ContactKey": "ID001",
                                    "EventDefinitionKey":"APIEvent-1b15b73a-cd8f-e508-efbe-6040061e9c51",
                                        "Data": POIEvent
                                        ]
        self.pushDataToMC(poiData: body)
        
        }
    
    public func ZOIclassifiedEnter(regionEvent: Dictionary<String, Any>, eventName: String) {
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
    
    public func ZOIclassifiedExit(regionEvent: Dictionary<String, Any>, eventName: String) {
        #if canImport(AirshipCore)
        // here you can modify your event name and add your data in the dictonnary
            let event = UACustomEvent(name: eventName, value: 1)
            event.properties = regionEvent
            event.track()
        #endif
    }
}
    
    
