//
//  ViewController.swift
//  Treviz
//
//  View controller controls all information regarding analysis input states and settings
///
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class InputsViewController: ViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    //var parentSplitViewController : MainSplitViewController? = nil
    //@IBOutlet weak var tableView: NSTableView!    
    @IBOutlet weak var stack: CustomStackView!
    
    var tableViewController : ParamTableViewController!
    weak var initStateViewController: InitStateViewController!
    var params : [InputSetting] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        //TODO: Fix stack loading issues
        // Load and install all the view controllers from our storyboard in the following order.
        _ = stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "SettingsViewController")
        _ = stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "EnvironmentViewController")
        _ = stack.addViewController(fromStoryboardId: "Inputs", withIdentifier: "InitStateViewController")
        let initStateView = stack.views.last
        self.initStateViewController = initStateView?.nextResponder as? InitStateViewController
        
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .paramTableViewSegue as NSStoryboardSegue.Identifier{
            self.tableViewController = segue.destinationController as? ParamTableViewController
        }
    }
    
    func collectInitialState(){
        let curAnalysis = self.representedObject as! Analysis
        let newInputData = initStateViewController.getInputSettingData() as [Variable]
        
        let newState = State(fromInputVars: newInputData)
        newState.variables[7] = Variable("mtot", named: "mass", symbol: "m", units: "mass", value: 10)
        curAnalysis.initialState = newState
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

