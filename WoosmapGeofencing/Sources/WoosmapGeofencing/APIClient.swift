//
//  APIClient.swift
//  WoosmapGeofencing
//
//  Copyright © 2021 Web Geo Services. All rights reserved.
//

import Foundation


class APIClient {
    class func getBearer( completion: @escaping (Error?) -> ()) {
        if(SFMCAccesToken.isEmpty) {
            let url = URL(string:(SFMCCredentials["authenticationBaseURI"] ?? "") + "/v2/Token")!
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let authenBody = ["client_id": SFMCCredentials["client_id"],
                              "client_secret":SFMCCredentials["client_secret"],
                              "grant_type":"client_credentials",
                              "scope":"list_and_subscribers_read journeys_read",
                              "account_id":SFMCCredentials["account_id"]]
            
            
            let bodyData = try? JSONSerialization.data(
                withJSONObject: authenBody,
                options: [])
            
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = bodyData
            
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) { data, response, error in
                // ensure there is no error for this HTTP response
                guard error == nil else {
                    print ("getBearer - error: \(error!)")
                    completion(error)
                    return
                }
                
                // ensure there is data returned from this HTTP response
                guard let content = data else {
                    print("getBearer - No data")
                    completion(NSError())
                    return
                }
                
                // serialise the data / NSData object into Dictionary [String : Any]
                guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String:Any] else {
                    print("getBearer - Not containing JSON")
                    completion(NSError())
                    return
                }
                
                let response = (json.compactMapValues { $0 as? String })
                let error_description = response["error_description"] ?? ""
                if (error_description.isEmpty) {
                    SFMCAccesToken = response["access_token"] ?? ""
                    completion(nil)
                } else {
                    print(error_description)
                    completion(NSError(domain: error_description, code: 0, userInfo:nil))
                }
            }
            task.resume()
        }
    }
    
}

class SFMCAPIclient: APIClient {
    static func pushDataToMC(poiData: [String: Any], eventDefinitionKey: String) {
        if(SFMCAccesToken.isEmpty) {
            getBearer() {  error in
                if let error = error {
                    print("Error occurred during get Token: \(error)")
                } else {
                    sendRequest(poiData: poiData, eventDefinitionKey: eventDefinitionKey)
                }
            }
        } else {
            sendRequest(poiData: poiData, eventDefinitionKey: eventDefinitionKey)
        }
    }
    
    static func sendRequest(poiData: [String: Any], eventDefinitionKey: String) {
        let url = URL(string: (SFMCCredentials["restBaseURI"] ?? "") + "/interaction/v1/events")!
        var request = URLRequest(url: url)
        let session = URLSession.shared
        
        
        let body : [String: Any] = ["ContactKey": SFMCCredentials["contactKey"] ?? "",
                                    "EventDefinitionKey": eventDefinitionKey,
                                    "Data": poiData]
        
        let bodyData = try? JSONSerialization.data(
                            withJSONObject: body,
                            options: [])
        
        request.httpMethod = "POST"
        request.setValue("Bearer " + SFMCAccesToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        session.dataTask(with: request) {data, response, error in
            if error != nil {
                print(error!.localizedDescription)
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
            
            let errorMessage = (json.compactMapValues { $0 as? String })
            
            if errorMessage["message"] == "Not Authorized" {
                SFMCAccesToken = ""
                self.pushDataToMC(poiData: poiData, eventDefinitionKey: eventDefinitionKey)
            }
            
            print("Response SFMC - json: \(json)")
        }.resume()
    }
    
}
