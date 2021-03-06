//
//  SettingStackViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class SingleAxisOutputSetupViewController: AddOutputViewController {

    @IBOutlet weak var gridView: CollapsibleGridView!
    var variableSelectorViewController : VariableSelectorViewController!
    override func plotTypeSelector(_ plotType: TZPlotType)->(Bool){ return plotType.nAxis == 1 }
    
    override func createOutput() -> TZOutput? {// TODO : expand for all plot types
        guard let plotType = plotTypePopupButton.selectedItem?.title else {return nil}
        let var1 = variableSelectorViewController?.selectedVariable
        do { let newOutput = try TZOutput(id: maxPlotID+1, vars: [var1!], plotType: TZPlotType.getPlotTypeByName(plotType)!)
        return newOutput } catch { return nil }
    }
        
    override func viewDidLoad() {
        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        variableSelectorViewController = storyboard.instantiateController(identifier: "variableSelectorViewController") { aDecoder in VariableSelectorViewController(coder: aDecoder, analysis: self.analysis) }
        variableSelectorViewController.representedObject = self.analysis
        variableSelectorViewController.selectedVariable = self.representedOutput.var1
        self.addChild(variableSelectorViewController)
        gridView.cell(atColumnIndex: 0, rowIndex: 1).contentView = variableSelectorViewController.view
        self.variableSelectorViewController.view.becomeFirstResponder()
        
        super.viewDidLoad()
    }

    override func variableDidChange(_ sender: VariableSelectorViewController) {
        if sender === variableSelectorViewController {
            representedOutput.var1 = sender.selectedVariable
        }
    }
    
    override func populateWithOutput(text: TZTextOutput?, plot: TZPlot?){ //Should be overwritten by each subclass
        // let output = text == nil ? plot : text as! TZOutput
        // variableSelectorViewController.selectedVariable = output
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
    
}
