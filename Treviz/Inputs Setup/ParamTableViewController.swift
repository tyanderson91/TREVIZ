//
//  ParamTableViewController.swift
//  Treviz
//
//  Created by Tyler Anderson on 4/5/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class ParamTableViewController: ViewController , NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    var initStateViewController : InitStateViewController!
    var params : [InputSetting] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let inputViewController = self.parent as! InputsViewController
        self.initStateViewController = inputViewController.initStateViewController
        NotificationCenter.default.addObserver(self, selector: #selector(self.paramWasSet(_:)), name: .didSetParam, object: nil)
        
        self.loadAllParams()
        tableView.reloadData()
        }
    
    @objc func loadAllParams(){
        let initStateParams = getParamSettings(from: initStateViewController.inputs)
        self.params.append(contentsOf: initStateParams)
    }
    
    @objc func paramWasSet(_ notification: Notification){
        let initStateParams = getParamSettings(from: initStateViewController.inputs)
        self.params = initStateParams
        tableView.reloadData()
    }
    
    
    func getParamSettings(from settings: [InputSetting], params: [InputSetting] = [])->[InputSetting]{
        var curParam = params
        for thisSetting in settings{
            if thisSetting.itemType != "var"{
                curParam = getParamSettings(from: thisSetting.children, params: curParam)
            }
            else if thisSetting.isParam {
                curParam.append(thisSetting)
            }
        }
        return curParam
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return params.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //initVariables = initState.getVariables()
        let thisVar = params[row]
        
        if tableColumn?.identifier.rawValue == "NameColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCellView"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = "\(thisVar.name) (\(thisVar.symbol)₀)"
                return thisCell
            }
        }
        else if tableColumn?.identifier.rawValue == "ValueColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ValueCellView"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = String(format: "%g", thisVar.value!)
                return thisCell
            }
        }
        else if tableColumn?.identifier.rawValue == "UnitsColumn"{
            if let thisCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "UnitsCellView"), owner: self) as? NSTableCellView{
                thisCell.textField!.stringValue = thisVar.units
                return thisCell
            }
        }
        return nil
    }
    
    private func tableView(_ tableView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let thisSetting = item as? InputSetting{
            if tableColumn?.identifier.rawValue == "Name Column"{return thisSetting.name}
            else if tableColumn?.identifier.rawValue == "ValueColumn"{return thisSetting.value}
            else if tableColumn?.identifier.rawValue == "UnitsColumn"{return thisSetting.units}
        }
        return nil
    }
    
    @IBAction func removeParamPressed(_ sender: Any) {//TODO: move to params table view controller
        let button = sender as! NSView
        let row = tableView.row(for: button)
        let thisInputSetting = params[row]
        thisInputSetting.isParam = false
        tableView.reloadData()
        initStateViewController.outlineView.refreshSetting(thisInputSetting)
        NotificationCenter.default.post(name: .didSetParam, object: thisInputSetting)
    }
}
