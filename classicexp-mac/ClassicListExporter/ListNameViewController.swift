//
//  ListNameViewController.swift
//  ClassicListExporter
//
//  Created by Casey Cady on 2/3/17.
//  Copyright © 2017 Casey Cady. All rights reserved.
//

import Cocoa

class ListNameViewController: NSViewController {
    @IBOutlet weak var listNameTextField: NSTextField!

    public var list: List?
    public var caches: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        caches = DatabaseManager.defaultMgr?.getCaches(forList: list!.id!)
        listNameTextField.stringValue = list!.name!
    }
    
    @IBAction func onOkay(_ sender: Any) {
        let waitStr = "Please wait. Exporting list."
        let alert = NSAlert()
        alert.informativeText = waitStr
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Cancel")
        alert.buttons[0].isHidden = true;
        alert.beginSheetModal(for: view.window!, completionHandler: { (_) in
            return
        })
        let task = CreateListAPITask(name: listNameTextField.stringValue)
        task.execute { (json) in
            if let code = json["referenceCode"].string {
                let addTask = AddToListAPITask(listCode: code, cacheCodes: self.caches!)
                addTask.execute  { (result) in
                    DispatchQueue.main.async {
                        alert.buttons[0].performClick(alert)
                        let waitStr = "List Exported"
                        let alert = NSAlert()
                        alert.informativeText = waitStr
                        alert.alertStyle = .informational
                        alert.addButton(withTitle: "Okay")
                        
                        alert.beginSheetModal(for: self.view.window!, completionHandler: { (_) in
                            DispatchQueue.main.async {
                                self.dismiss(nil)
                            }
                            return
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(nil)
    }
}
