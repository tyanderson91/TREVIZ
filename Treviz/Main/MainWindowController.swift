//
//  MainWindowController.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    //@IBOutlet weak var toolbar: NSToolbar!
    weak var toolbar: TZToolbar!
    @IBOutlet weak var showHidePanesControl: NSSegmentedControl!
    @IBOutlet weak var runButton: NSButton!
    /*var analysis: Analysis! {
        get { return (contentViewController as? TZViewController)?.analysis ?? nil }
        set { (contentViewController as? TZViewController)?.analysis = newValue }
    }*/
    var analysis : Analysis!
        
    var viewController: MainViewController! { return contentViewController as? MainViewController ?? nil}
        
    func processOutputs(){
        guard let textOutputView = viewController.textOutputView else {return}
        guard let outputSplitVC = viewController.mainSplitViewController.outputsViewController.outputSplitViewController else { return }
        guard let plotViewController = outputSplitVC.plotViewController else { return }
        
        textOutputView.string = ""
        plotViewController.plotViews = []
        for curOutput in analysis.plots {
            curOutput.curTrajectory = analysis.traj
            if curOutput is TZTextOutput {
                let newText = (curOutput as! TZTextOutput).getText()
                textOutputView.textStorage?.append(newText)
                textOutputView.textStorage?.append(NSAttributedString(string: "\n\n"))
            }
            else if curOutput is TZPlot {
                plotViewController.createPlot(plot: curOutput as! TZPlot)
            }
        }
        let plotTabViewIndex = outputSplitVC.viewerTabViewController.tabView.indexOfTabViewItem(withIdentifier: "plotterTabViewItem")
        outputSplitVC.viewerTabViewController.tabView.selectTabViewItem(at: plotTabViewIndex)
    }
    
    @objc func completeAnalysis(notification: Notification){ // Runs when the analysis has terminated
        analysis.isRunning = false
        toolbar.toggleAnalysisRun.title = "►"
        let progressBar = viewController.analysisProgressBar!
        progressBar.doubleValue = 0
        if analysis.returnCode > 0 { //Nominal successfull completion
            processOutputs()}
        else { //TODO: make different error codes for analysis run
            processOutputs()
            //viewController.textOutputView?.string.append("Not enough inputs to make analysis fully defined!")
        }
    }
}
