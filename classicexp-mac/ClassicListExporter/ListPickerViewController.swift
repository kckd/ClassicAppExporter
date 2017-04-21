//
//  ListPickerViewController.swift
//  ClassicListExporter
//
//  Created by Casey Cady on 2/3/17.
//  Copyright © 2017 Casey Cady. All rights reserved.
//

import Cocoa
import SQLite

class ListPickerViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    public var lists: [List]?

    @IBOutlet weak var listTableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        listTableView.reloadData()
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if lists?.count == 0 {
            let alert = NSAlert();
            alert.messageText = "This backup contains no lists!"
            alert.beginSheetModal(for: view.window!) { (resp) in
                self.dismiss(self)
            }
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? ListNameViewController {
            vc.list = lists?[listTableView.selectedRow]
            listTableView.deselectAll(nil)
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return lists?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        
        // 1
        guard let item = lists?[row] else {
            return nil
        }
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = item.name!
            cellIdentifier = "NameCell"
        } else if tableColumn == tableView.tableColumns[1] {
            text = "\(item.count!)"
            cellIdentifier = "CountCell"
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        if listTableView.selectedRowIndexes.count == 1, let selectedItem = lists?[listTableView.selectedRow] {
//            listTableView.deselectAll(nil)
//            if let caches = DatabaseManager.defaultMgr?.getCaches(forList: selectedItem.id!) {
//                print(caches)
//            }
//        }
//    }
    
}
    

