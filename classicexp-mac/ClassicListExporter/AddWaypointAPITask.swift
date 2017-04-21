//
//  AddWaypointAPITask.swift
//  ClassicListExporter
//
//  Created by Casey Cady on 3/1/17.
//  Copyright © 2017 Casey Cady. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class AddWaypointAPITask {
    var waypoint: Waypoint
    
    
    init(waypoint: Waypoint) {
        self.waypoint = waypoint
    }
    
    func execute() {
        let request = buildURLRequest()
        let dlTask = SessionManager.default.request(request)
        dlTask.responseJSON { (response) in
            if let json = response.result.value {
                print(json)
            }
        }
        
    }
    
    func buildURLRequest() -> URLRequest {
        let path = URL(string: "https://api.groundspeak.com/LiveV6/Geocaching.svc/internal/SaveUserWaypoint?format=json")!
        var request = try! URLRequest(url: path, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let requestDict = [
            "AccessToken": DatabaseManager.defaultMgr!.token,
            "CacheCode" : waypoint.cacheCode,
            "Latitude" : waypoint.lat,
            "Longitude" : waypoint.lon,
            "Description" : waypoint.wptName,
            "IsCorrectedCoordinate":false,
            "IsUserCompleted":false] as [String : Any]
    
        
            //if let additionalItem = additionalItemForRequestCollection {
            //requestArray.append([additionalItem.key : additionalItem.value as AnyObject])
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestDict, options: JSONSerialization.WritingOptions(rawValue: 0))
        print(String(data: request.httpBody!, encoding: .utf8))
            //}
        
        
        return request
    }
}
