//
//  SettingStackViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class SingleAxisOutputSetupViewController: BaseViewController, NSComboBoxDataSource {

    @IBOutlet weak var variableDropDown: NSPopUpButton!
    @IBOutlet weak var plotTypeDropDown: NSPopUpButton!
    @IBOutlet weak var includeTextCheckbox: NSButton!
    @IBOutlet weak var gridView: CollapsibleGridView!
    @IBOutlet weak var conditionsComboBox: NSComboBox!
    var conditions : [Condition] = []
    
    @IBAction func addOutputClicked(_ sender: Any) {
        
    }
    @IBAction func plotTypeSelected(_ sender: Any) {
    }
    @IBAction func includeTextCheckboxClicked(_ sender: Any) {
        switch includeTextCheckbox.state{
        case .on:
            print("on")
            gridView.showHideCols(.show, index: [2])
        case .off:
            print("off")
            gridView.showHideCols(.hide, index: [2])
        default:
            print("nada")
        }
    }
    
    
    override func headerTitle() -> String { return NSLocalizedString("Single Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didAddCondition, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.conditionsChanged(_:)), name: .didRemoveCondition, object: nil)

        if let asys = analysis {
            conditions = asys.conditions!
        }

        // Do view setup here.
        //didDisclose()
    }
    
    @objc func conditionsChanged(_ notification: Notification){
        if let asys = analysis {
            conditions = asys.conditions!
        }
        self.conditionsComboBox.reloadData()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return conditions.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return conditions[index].name
    }
    
    //override func didDisclose() {
    //    if disclosureState == .open {
    //
     //   } else {
     //
     //   }
    //}
    
}
