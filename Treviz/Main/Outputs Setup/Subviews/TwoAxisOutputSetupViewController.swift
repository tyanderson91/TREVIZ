//
//  TwoAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class TwoAxisOutputSetupViewController: AddOutputViewController {
    
    
    override func plotTypeSelector(_ plotType: TZPlotType)->(Bool){ return plotType.nAxis == 2 }

    @IBOutlet weak var gridView: CollapsibleGridView!
    @IBOutlet weak var variableGridView: CollapsibleGridView!

    @IBOutlet weak var plottingStackView: NSStackView!

    var var1ViewController: VariableSelectorViewController!
    var var2ViewController: VariableSelectorViewController!
    var var3ViewController: ParameterSelectorViewController!
    
    override func createOutput()->TZOutput? {// TODO : expand for all plot types
        guard let plotType = plotTypePopupButton.selectedItem?.title else {return nil}
        var var1 : Variable?
        var var2 : Variable?
        guard let var1Name = var1ViewController.variableSelectorPopup.selectedItem?.title else {return nil}
        guard let var2Name = var2ViewController.variableSelectorPopup.selectedItem?.title else {return nil}
        var1 = analysis.varList.first(where: {$0.name == var1Name} )
        var2 = analysis.varList.first(where: {$0.name == var2Name} )
        
        do { let newPlot = try TZPlot(id: maxPlotID+1, vars: [var1!, var2!], plotType: TZPlotType.getPlotTypeByName(plotType)!)
        return newPlot } catch { return nil }
    }
    
    override func getHeaderTitle() -> String { return NSLocalizedString("Two Axis", comment: "") }
    
    override func viewDidLoad() {
        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        let storyboard2 = NSStoryboard(name: "ParamSelector", bundle: nil) // TODO: merge variable selector into param selector

        var1ViewController = storyboard.instantiateController(identifier: "variableSelectorViewController") { aDecoder in VariableSelectorViewController(coder: aDecoder, analysis: self.analysis) }
        self.addChild(var1ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 0).contentView = var1ViewController.view
        
        var2ViewController = storyboard.instantiateController(identifier: "variableSelectorViewController") { aDecoder in VariableSelectorViewController(coder: aDecoder, analysis: self.analysis) }
        self.addChild(var2ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 1).contentView = var2ViewController.view
        
        var3ViewController = storyboard2.instantiateController(identifier: "paramSelectorViewController") { aDecoder in ParameterSelectorViewController(coder: aDecoder, analysis: self.analysis) }
        self.addChild(var3ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 2).contentView = var3ViewController.view
        
        super.viewDidLoad()

        var1ViewController.selectedVariable = self.representedOutput.var1
        var2ViewController.selectedVariable = self.representedOutput.var2
        var3ViewController.selectedParameter = self.representedOutput.categoryVar
    }
    
    override func variableDidChange(_ sender: VariableSelectorViewController) {
        representedOutput.var1 = var1ViewController.selectedVariable
        representedOutput.var2 = var2ViewController.selectedVariable
        representedOutput.categoryVar = var3ViewController.selectedParameter
    }
    
    override func populateWithOutput(text: TZTextOutput?, plot: TZPlot?){ //Should be overwritten by each subclass
        var1ViewController.selectedVariable = self.representedOutput.var1
        var2ViewController.selectedVariable = self.representedOutput.var2
        var3ViewController.selectedParameter = self.representedOutput.categoryVar

        if representedOutput.plotType.nVars == 2 {
            let vg = variableGridView
            vg!.showHide(.hide, .row, index: [2])
        }
        return
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
}

