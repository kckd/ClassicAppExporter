//
//  DatabaseManager.swift
//  ClassicListExporter
//
//  Created by Casey Cady on 2/3/17.
//  Copyright © 2017 Casey Cady. All rights reserved.
//

import Foundation
import SQLite

struct List {
    var id: Int64?
    var name: String?
    var count: Int64?
}

struct Waypoint {
    var cacheCode: String
    var wptName: String
    var lat: Float
    var lon: Float
    var selected = false
}

class DatabaseManager {
    //let dbFileURL: URL
    let db: Connection
    let token: String
    
    public static var defaultMgr: DatabaseManager?
    
    init?(backupDirectory: URL) {
        let fileMgr = FileManager.default
        
        if let manifestDb = try? Connection(backupDirectory.appendingPathComponent("Manifest.db").absoluteString) {
            do {
                let plistQ = try manifestDb.prepare("select fileId from Files where relativePath = \"Library/Preferences/MZCZ5SMF8U.iCacher.plist\"")
                if let row = plistQ.first(where: { (_) -> Bool in
                    true
                }) {
                    let plistFileId = row[0] as! String
                    var prefix = plistFileId.substring(to: plistFileId.index(plistFileId.startIndex, offsetBy: 2))
                    if let appPlist = NSDictionary(contentsOf: backupDirectory.appendingPathComponent("\(prefix)/\(plistFileId)")) {
                        self.token = appPlist["GEOGlobals_mApiAccessToken"] as! String
                        if let guid = appPlist["GEOGlobals_mLoggedInUserGuid"] as? String {
                            let dbQ = try manifestDb.prepare("select fileId from Files where domain = \"AppDomain-MZCZ5SMF8U.iCacher\" and relativePath = \"Documents/\(guid).db\"")
                            if let dbRow = dbQ.first(where: { (_) -> Bool in
                                true
                            }) {
                                let dbFileId = dbRow[0] as! String
                                prefix = dbFileId.substring(to: dbFileId.index(dbFileId.startIndex, offsetBy: 2))
                                let dbUrl = backupDirectory.appendingPathComponent("\(prefix)/\(dbFileId)")
                                if let db = try? Connection(dbUrl.absoluteString, readonly: true) {
                                    self.db = db
                                    DatabaseManager.defaultMgr = self
                                    return
                                } else {
                                    return nil
                                }
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    
    
    func getCaches(forList list: Int64) -> [String]? {
        let table = Table("geocacheToGroupV3")
        let codeCol = Expression<String>("cacheCode")
        let idCol = Expression<Int64>("groupId")
        let caches = table.select(codeCol).filter(idCol == list)
        return try? db.prepare(caches).flatMap { $0[codeCol] }
    }
    
    func getWaypoints() -> Array<Waypoint> {
        do {
            let r = try db.prepare("SELECT cacheCode, body from userWaypointsV3")
            //return
            let waypoints: [Waypoint] = r.flatMap({
                for (index, name) in r.columnNames.enumerated() {
                    print ("\(name)=\($0[index]!)")
                    // id: Optional(1), email: Optional("alice@mac.com")
                }
                let compressed = Data(base64Encoded: $0[1] as! String)
                let decompressed = compressed?.unzip()
                let dict = try? PropertyListSerialization.propertyList(from: decompressed!, options: [], format: nil) as? [String:Any]
                let records = (dict??["mRecordByAddress"] as! [String:[String:Any]]).values
                
                for record in records {
                    if record["mLatitude"] != nil {
                        return Waypoint(cacheCode: $0[0] as! String, wptName: record["mName"] as! String, lat: record["mLatitude"] as! Float, lon: record["mLongitude"] as! Float, selected: false)
                    }
                }
                return nil
                //return List(id: $0[1] as? Int64, name: $0[0] as? String, count: $0[2] as? Int64)
            })
            return waypoints
            
        } catch {
            print(error)
            return [Waypoint]()
        }
    }
    
    func getLists() -> Array<List>? {
        do {
        let r = try db.prepare("SELECT l.name, l.id, COUNT(c.id) AS cacheCount from geocacheToGroupV3 c left join groupsV3 l on c.groupId = l.id group by l.name")
        return r.flatMap({
            for (index, name) in r.columnNames.enumerated() {
                print ("\(name)=\($0[index]!)")
                // id: Optional(1), email: Optional("alice@mac.com")
            }
            return List(id: $0[1] as? Int64, name: $0[0] as? String, count: $0[2] as? Int64)
        })
        } catch {
            print(error)
            return nil
        }
    }
    
    
}
