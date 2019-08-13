//
//  MainSplitViewController.swift
//  Treviz
//
//  View controller housing the input, output, and output setup split view items
//
//  Created by Tyler Anderson on 3/9/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainSplitViewController: SplitViewController {

    @IBOutlet weak var inputsSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var outputsSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var outputSetupSplitViewItem: NSSplitViewItem!
    var inputsViewController : InputsViewController!
    var outputsViewController : OutputsViewController!
    var outputSetupViewController : OutputSetupViewController!
    var splitViewItemList : [NSSplitViewItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputsViewController = (inputsSplitViewItem?.viewController as! InputsViewController) //TODO: try to move this to the variable declaration
        outputsViewController = (outputsSplitViewItem?.viewController as! OutputsViewController)
        outputSetupViewController = (outputSetupSplitViewItem?.viewController as! OutputSetupViewController)
        splitViewItemList = [inputsSplitViewItem, outputsSplitViewItem, outputSetupSplitViewItem]

        //outputsSplitViewItem.setValue(600, forKey: "width")
        // Do view setup here.
    }
    
    func setSectionCollapse(_ collapsed : Bool, forSection secID: Int){
        guard let _ = self.representedObject as? Analysis else {return}
        if !(collapsed && numActiveViews() == 1){
            splitViewItemList![secID].animator().isCollapsed = collapsed
        }
    }
    
    func numActiveViews()->Int {
        var numViews = 0
        for thisView in splitViewItemList! {
            numViews += (thisView.isCollapsed ? 0 : 1)
        }
        return numViews
    }
    
}
