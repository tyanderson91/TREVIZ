//
//  OutputsViewController.swift
//  Treviz
//
//  Controls display of all analysis output information
//
//  Created by Tyler Anderson on 3/8/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

extension NSStoryboardSegue.Identifier{
    static let outputSplitViewSegue = "outputSplitViewSegue"
}

class OutputsViewController: TZViewController {
        
    @IBOutlet weak var outputsSplitView: NSView!
    var outputSplitViewController: OutputsSplitViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .outputSplitViewSegue {
            self.outputSplitViewController =  segue.destinationController as? OutputsSplitViewController
        }
    }
    /*
    func processOutputs(){
        guard let curAnalysis = self.representedObject as? Analysis else { return }
        let outputSet = curAnalysis.plots
        
        let textOutputSplitViewItem = outputSplitViewController!.textOutputSplitViewItem
        let textOutputViewController = textOutputSplitViewItem!.viewController as! TextOutputsViewController
        
        let plotViewController = outputSplitViewController!.plotViewController
        
        let textOutputView = textOutputViewController.textView!
                
        textOutputView.string = ""
        for curOutput in outputSet {
            curOutput.curTrajectory = curAnalysis.traj
            if curOutput is TZTextOutput {
                let newText = (curOutput as! TZTextOutput).getText()
                textOutputView.textStorage?.append(newText)
            } else if curOutput is TZPlot {
                plotViewController!.createPlot(plot: curOutput as! TZPlot)
            }
        }
    }*/
    
}


class OutputsSplitViewController: TZSplitViewController {
    
    
    @IBOutlet weak var viewerOutputSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var textOutputSplitViewItem: NSSplitViewItem!
    
    private var viewerTabViewController: ViewerTabViewController {
        return viewerOutputSplitViewItem.viewController as! ViewerTabViewController
    }
    
    var textOutputViewController: TextOutputsViewController! {
        if let _textOutputViewVC = textOutputSplitViewItem.viewController as? TextOutputsViewController { return _textOutputViewVC }
        else {return nil}
    }
    var textOutputView: NSTextView! {
        if let _textOutputView = (textOutputSplitViewItem.viewController as? TextOutputsViewController)?.textView { return _textOutputView }
        else {return nil}
    }
    var visualizerViewController: VisualizerViewController! { return viewerTabViewController.visualizerTabViewItem.viewController as? VisualizerViewController ?? nil }
    var plotViewController: PlotOutputViewController! { return viewerTabViewController.plotTabViewItem.viewController as? PlotOutputViewController ?? nil }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}