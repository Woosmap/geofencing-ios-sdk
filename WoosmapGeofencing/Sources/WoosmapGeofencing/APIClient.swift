//
//  OAuth.swift
//  WoosmapGeofencing
//
//  Created by Mac de Laurent on 24/09/2021.
//  Copyright © 2021 Web Geo Services. All rights reserved.
//

import Foundation

let BearerKeychainNameKey = "BearerTokenKey"
let ExpiresAtKeychainNameKey = "BearerExpiresKey"
let DomainKeychainNameKey = "AccessDomain"


struct LoginResponse: Codable {
    let code: Int
    let msg: String?
    let data: LoginResponseData
}

struct LoginResponseData: Codable {
    let authToken: String?
    let tokenExpiresAt: Int?
    let domain: String?
    
    enum CodingKeys: String, CodingKey {
        case authToken = "auth_token"
        case tokenExpiresAt = "token_expires_at"
        case domain = "domain"
    }
}



class APIClient {
    static var access_token: String = ""
    class func setBearer(response: LoginResponse, email: String? = nil, password: String? = nil) {
        guard response.data.authToken != nil else { return }
        
        //_ = KeychainWrapper.standard.set(access_token, forKey: BearerKeychainNameKey)
        //_ = KeychainWrapper.standard.set(String(response.data.tokenExpiresAt ?? 0), forKey: ExpiresAtKeychainNameKey)
    }
    
    class func setAccessDomain(response: LoginResponse) {
        //_ = KeychainWrapper.standard.set(response.data.domain ?? "", forKey: DomainKeychainNameKey)
    }
    
    class func getBearer() -> String? {
        if(access_token.isEmpty) {
            let url = URL(string: "https://mcdmfc5rbyc0pxgr4nlpqqy0j-x1.auth.marketingcloudapis.com/v2/Token")!
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            let bodyData = try? JSONSerialization.data(
                withJSONObject: SFMCCredentials,
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
                
                let response = (json.compactMapValues { $0 as? String })
                self.access_token = response["access_token"] ?? ""
                
                //print("getBearer - access_token: \(AirshipEvents.access_token)")
                return
            }
            task.resume()
        }
        return access_token
        //return KeychainWrapper.standard.string(forKey: BearerKeychainNameKey)
    }
    
    class func getAccessDomain() -> String? {
        return ""
        //return KeychainWrapper.standard.string(forKey: DomainKeychainNameKey)
    }
}

class UserAPIClient: APIClient {
    static func pushDataToMC(poiData: [String: Any]) {
        let url = URL(string: "https://mcdmfc5rbyc0pxgr4nlpqqy0j-x1.rest.marketingcloudapis.com/interaction/v1/events")!
        var request = URLRequest(url: url)
        let session = URLSession.shared
        
        guard let token = getBearer() else {
            return
        }
        
        let body : [String: Any] = ["ContactKey": "ID001",
                                            "EventDefinitionKey":"APIEvent-1b15b73a-cd8f-e508-efbe-6040061e9c51",
                                                "Data": poiData
                                                ]
        
        let bodyData = try? JSONSerialization.data(
                            withJSONObject: body,
                            options: [])
        
        request.httpMethod = "POST"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
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
                guard getBearer() != nil else {
                    return
                }
                self.pushDataToMC(poiData: poiData)
            }
            
            print("Response SFMC - json: \(json)")
        }.resume()
    }
    
}
