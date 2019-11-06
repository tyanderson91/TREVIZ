//
//  TwoAxisOutputSetupViewController.swift
//  InfoBarStackView
//
//  Created by Tyler Anderson on 3/17/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Cocoa

class TwoAxisOutputSetupViewController: AddOutputViewController {
    
    @IBOutlet weak var gridView: CollapsibleGridView!
    @IBOutlet weak var variableGridView: NSGridView!

    @IBOutlet weak var plottingStackView: NSStackView!

    override func createOutput()->TZOutput? {// TODO : expand for all plot types
        /*
        if let plotType = plotTypeDropDown.selectedItem?.title{
            let newPlot = TZPlot1line2d()
            newPlot.plotType = PlotType(rawValue: plotType)!
            //newPlot.var1 = variableSelectorViewController?.getSelectedItem()
            newPlot.setName()
            return newPlot
        }*/
        return nil
    }
    
    override func headerTitle() -> String { return NSLocalizedString("Two Axis", comment: "") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = NSStoryboard(name: "VariableSelector", bundle: nil)
        let var1ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        self.addChild(var1ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 0).contentView = var1ViewController.view
        
        let var2ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        self.addChild(var2ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 1).contentView = var2ViewController.view
        
        let var3ViewController = storyboard.instantiateController(withIdentifier: "variableSelectorViewController") as! VariableSelectorViewController
        self.addChild(var3ViewController)
        variableGridView.cell(atColumnIndex: 1, rowIndex: 2).contentView = var3ViewController.view
        
        plotTypeSelector = { return $0.nAxis == 2 }
        /*
        setWidth(component: var1ViewController, width: varSelectorWidth)
        setWidth(component: var2ViewController, width: varSelectorWidth)
        setWidth(component: var3ViewController, width: varSelectorWidth)*/
    }
    
    override func didDisclose() {
        // let showHideMethod : CollapsibleGridView.showHide = (disclosureState == .closed) ? .hide : .show
        // gridView.showHide(showHideMethod, .column, index: [0,1,2])
    }
}

