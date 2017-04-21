//
//  AddToListAPITask.swift
//  ClassicListExporter
//
//  Created by Casey Cady on 2/3/17.
//  Copyright © 2017 Casey Cady. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class AddToListAPITask {
    let listCode: String
    var cacheCodeArray = [[String : AnyObject]]()
    
    init(listCode: String, cacheCodes: [String]) {
        self.listCode = listCode
        for cacheCode in cacheCodes {
            cacheCodeArray.append(["referenceCode" : cacheCode as AnyObject])
        }
    }
    
    func execute(completionHandler: @escaping (Bool) -> Void)  {
        let request = buildURLRequest()
        let dlTask = SessionManager.default.request(request)
        dlTask.responseJSON { (response) in
            if let json = response.result.value {
                print(json)
                completionHandler(true)
            }
        }
        
    }
    
    func buildURLRequest() -> URLRequest {
        let path = "mobile/v1/lists/\(listCode)/bulkaddgeocaches"
        var request = URLRequest(url: URL(string:path, relativeTo: URL(string: "https://api.groundspeak.com")!)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var additionalItemForRequestCollection: (key: String, value: Any)?
//        if authorizationExpectation.credential == .oAuthClientSecret && authorizationExpectation.expectedIn == .httpHeaderField {
//            var client = ""
//            let clientPlain = "\(APIService.OAuthClientId):\(APIService.OAuthClientSecret)"
//            let clientUTF8 = clientPlain.data(using: String.Encoding.utf8)
//            if let clientBase64 = clientUTF8?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) {
//                client = clientBase64
//            }
//            request.addValue("Basic \(client)", forHTTPHeaderField: "Authorization")
//        } else if authorizationExpectation.credential == .accessToken {
        
            //if let accessToken = UserDefaults.gsAccessToken() {
               // if authorizationExpectation.expectedIn == .httpHeaderField {
                    let authorizationToken = "bearer " + DatabaseManager.defaultMgr!.token
                    request.addValue(authorizationToken, forHTTPHeaderField: "Authorization")
               // } else if authorizationExpectation.expectedIn == .httpBody {
               //     additionalItemForRequestCollection = (key: "AccessToken", value: accessToken)
               // }
//            } else {
//                Logging.logError("Expected an access token when building the URLRequest for \(apiPath).")
//            }
//        } else if authorizationExpectation.credential == .consumerKey && authorizationExpectation.expectedIn == .httpBody {
//            additionalItemForRequestCollection = (key: "ConsumerKey", value: APIService.consumerKey)
//        } else {
//            fatalError("AuthorizationExpectation \(authorizationExpectation) is not supported.")
//        }
        
        request.httpMethod = "PUT"
        //if HTTPMethod == "POST" || HTTPMethod == "PUT" {
            // Adjust the requestCollection if needed and then set the HTTPBody of the request.
            if var requestArray = cacheCodeArray as? [[String: AnyObject]] {
                //if let additionalItem = additionalItemForRequestCollection {
                    //requestArray.append([additionalItem.key : additionalItem.value as AnyObject])
                    request.httpBody = try? JSONSerialization.data(withJSONObject: requestArray, options: JSONSerialization.WritingOptions(rawValue: 0))
                //}
            }
    
        return request
    }
}
