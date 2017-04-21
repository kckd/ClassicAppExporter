//
//  WaypointSelectionViewController.swift
//  ClassicListExporter
//
//  Created by Casey Cady on 2/28/17.
//  Copyright © 2017 Casey Cady. All rights reserved.
//

import Cocoa

class WaypointSelectionViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var waypointTableView: NSTableView!

    public var waypoints: [Waypoint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        waypointTableView.reloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if waypoints?.count == 0 {
            let alert = NSAlert();
            alert.messageText = "This backup contains no waypoints!"
            alert.beginSheetModal(for: view.window!) { (resp) in
                self.dismiss(self)
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return waypoints.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let waypoint = waypoints[row]
        if tableColumn?.identifier == "WaypointSelectionColumn" {
            return waypoint.selected ? 1 : 0
        } else if tableColumn?.identifier == "WaypointDescriptionColumn" {
            return "GC Code: \(waypoint.cacheCode) Name: \(waypoint.wptName)"
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if tableColumn?.identifier == "WaypointSelectionColumn" {
            waypoints[row].selected = Bool(object as! NSNumber)
        }
    }
    
    @IBAction func onExportClicked(_ sender: Any) {
        let time = waypoints.filter {  $0.selected  }.count*2
        let min = time/60
        let sec = time%60
        let waitStr = "Please wait. This will take approximately \(min) minutes and \(sec) seconds."
        let alert = NSAlert()
        alert.informativeText = waitStr
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Cancel")
        var cancelled = false
        alert.beginSheetModal(for: view.window!, completionHandler: { (_) in
            cancelled = true
            return
        })
        DispatchQueue.global().async(execute: {
            for waypoint in self.waypoints {
                if cancelled {
                    break
                }
                if waypoint.selected {
                    let addTask = AddWaypointAPITask(waypoint: waypoint)
                    addTask.execute()
                    sleep(2)
                }
            }
            DispatchQueue.main.async {
                alert.buttons[0].performClick(alert)
            }
            
        })
        
        
        
    }
    
    
}
