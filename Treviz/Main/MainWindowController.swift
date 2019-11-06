//
//  MainWindowController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSToolbarDelegate {

    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var showHidePanesControl: NSSegmentedControl!
    @IBOutlet weak var runButton: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        //showHidePanesControl.setImage(NSImage(named: "smallSegmentedCell"), forSegment: 0)
        //showHidePanesControl.setImage(NSImage(named: "largeSegmentedCell"), forSegment: 1)
        //showHidePanesControl.setImage(NSImage(named: "smallSegmentedCell"), forSegment: 2)
        showHidePanesControl.setWidth(18, forSegment: 0)
        showHidePanesControl.setWidth(26, forSegment: 1)
        showHidePanesControl.setWidth(18, forSegment: 2)

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    @IBAction func runAnalysisClicked(_ sender: Any) {
        if let asys = self.contentViewController?.representedObject as? Analysis {
            if asys.isRunning{
                asys.isRunning = false
                DistributedNotificationCenter.default().post(name: .didFinishRunningAnalysis, object: nil)
                
            }
            else {
                _ = asys.runAnalysis()
            }
        }
    }
    
    
    @IBAction func conditionsClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "conditionsPopupSegue", sender: self)
        }
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "conditionsPopupSegue" {
            let conditionsVC = segue.destinationController as! ConditionsViewController
            conditionsVC.representedObject = self.contentViewController!.representedObject as? Analysis
        }
    }
    
    
    @IBAction func showHidePanesClicked(_ sender: Any) {
        let asys = self.contentViewController?.representedObject as! Analysis

        guard let button = sender as? NSSegmentedControl else {return}
        let curIndex = button.indexOfSelectedItem
        let shouldCollapse = !button.isSelected(forSegment: curIndex)
        let splitViewController = asys.viewController.mainSplitViewController!

        splitViewController.setSectionCollapse(shouldCollapse, forSection: curIndex)
        for i in 0...2 { // If there is one button left, disable it so user cannot collapse everything
            let enableButton = (splitViewController.numActiveViews == 1 && button.isSelected(forSegment: i)) ? false : true
            button.setEnabled(enableButton, forSegment: i)
        }
    }
}
