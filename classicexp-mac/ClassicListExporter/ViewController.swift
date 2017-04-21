//
//  ViewController.swift
//  ClassicListExporter
//
//  Created by Casey Cady on 2/3/17.
//  Copyright © 2017 Casey Cady. All rights reserved.
//

import Cocoa
import SQLite

extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select File"
        allowsMultipleSelection = false
        canChooseDirectories = true
        canChooseFiles = false
        canCreateDirectories = false
//        allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]  // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == NSFileHandlingPanelOKButton ? urls.first : nil
    }
}

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    
    @IBOutlet weak var exportWaypointsButton: NSButtonCell!
    @IBOutlet weak var selectBackupButton: NSButtonCell!
    @IBOutlet weak var backupTableView: NSTableView!
    var selectedFile: URL? = nil
    
    var availableBackups = [(date: String, name: String, location: URL)]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appSupportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first else { return }
        var backupDir = NSURL(fileURLWithPath: appSupportDir, isDirectory: true)
        backupDir = (backupDir.appendingPathComponent("MobileSync/Backup", isDirectory: true) as NSURL?)!
        let fileMgr = FileManager.default
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        guard let files = try? fileMgr.contentsOfDirectory(at: backupDir as URL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else
        {
            let alert = NSAlert()
            alert.informativeText = "Unable to find any iTunes backups. You must create an unencrypted backup of your device using iTunes before running this."
            alert.alertStyle = .critical
         
            alert.runModal()
            return
        }
        for file in files {
            if let infoPlist = NSDictionary(contentsOf: file.appendingPathComponent("Info.plist")) {
                if let apps = infoPlist["Installed Applications"] as? [String] {
                    if apps.contains("MZCZ5SMF8U.iCacher") {
                        let dateStr = df.string(from: infoPlist["Last Backup Date"] as! Date)
                        availableBackups.append((date: dateStr, name: infoPlist["Display Name"] as! String, location: file))
                    }
                }
            }
        }
        backupTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowListPicker" {
            if let vc = segue.destinationController as? ListPickerViewController {
                if let dbMgr = DatabaseManager.defaultMgr {
                    if let lists = dbMgr.getLists() {
                        vc.lists = lists
                    }
                }
            }
        } else if segue.identifier == "ShowWaypointPicker" {
            if let vc = segue.destinationController as? WaypointSelectionViewController {
                if let dbMgr = DatabaseManager.defaultMgr {
                    let waypoints = dbMgr.getWaypoints()
                    vc.waypoints = waypoints
                }
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func OnClick(_ sender: Any) {
        if let _ = DatabaseManager(backupDirectory: availableBackups[backupTableView.selectedRow].location) {
            performSegue(withIdentifier: "ShowListPicker", sender: self)
        }
    }
    
    @IBAction func onExportWaypointsClick(_ sender: Any) {
        if let _ = DatabaseManager(backupDirectory: availableBackups[backupTableView.selectedRow].location) {
            performSegue(withIdentifier: "ShowWaypointPicker", sender: self)
        }
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectBackupButton.isEnabled = backupTableView.selectedRow != -1
        exportWaypointsButton.isEnabled = backupTableView.selectedRow != -1
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return availableBackups.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        let backup = availableBackups[row]
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = backup.date
            cellIdentifier = "DateCell"
        } else if tableColumn == tableView.tableColumns[1] {
            text = backup.name
            cellIdentifier = "NameCell"
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }

}

