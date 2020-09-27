//
//  Analysis.swift
//  Treviz
//
//  Created by Tyler Anderson on 2/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.

import Cocoa

enum AnalysisError: Error {
    case NoTerminalCondition
    case TimeStepError
}

enum AnalysisRunMode {
    case serial
    case parallel
}
extension AnalysisError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .NoTerminalCondition:
            return NSLocalizedString("Missing terminal condition", comment: "")
        case .TimeStepError:
            return NSLocalizedString("Unset timestep settings", comment: "")
        }
    }
}
/**
The Analysis class is the subclass of NSDocument that controls all the analysis document information and methods
Data reading and writing occurs in AnalysisData and is passed to this class
Data configurations common to all analyses (e.g. plot types) lives in the App Delegate
In the Model-View-Controller paradigm, Analysis is the model that brings together all other models for a single document.
In addition, this class contains class-level functions such as initiating the analysis run
* Output sets: set of all output objects (text, plot, animation) and output configurations
* Initial State: fully defined initial state
* Environment: data defining the planet, atmosphere, and physics to run
* Vehicle: Vehicle config information, including mass and aerodynamic configuration and Guidance, Navigation, and Control data
* Conditions: All conditions for use in outputs and terminal condition
* Terminal condition: The final condition or set of conditions that ends the simulation
* Run settings: things like default timestep, propagator, etc.
*/
class Analysis: NSObject, Codable {
    
    var varList : [Variable]! {
        if phases.count == 1 {
            let onlyPhase = phases[0]
            var summaryVars = onlyPhase.varList.compactMap({$0.stripPhase()})
            summaryVars.append(contentsOf: onlyPhase.varList)
            return summaryVars
        } else { return [] }
    }
    var calculatedVarTemplates: [StateCalcVariable] = []
    
    // Analysis-specific data and configs (read/writing functions in AnalysisData.swift)
    var name : String = ""
    var conditions : [Condition] = []
    var parameters : [Parameter] { //TODO: this should contain more than just input settings
        return inputSettings.filter {$0.isParam}
    }
    @objc var plots : [TZOutput] = []
    
    // Phase variables
    var phases : [TZPhase] = []
    var vehicles = [Vehicle()]
    var propagatorType : PropagatorType = .explicit
    var defaultTimestep : VarValue = 0.01
    var inputSettings : [Parameter] {
        var tempSettings = [Parameter]()
        for thisPhase in phases {
            tempSettings.append(contentsOf: thisPhase.inputSettings)
        }
        return tempSettings
    }
    var initState: StateDictSingle {
        get { return StateDictSingle(from: self.traj, at: 0) }
    }
    weak var terminalCondition : Condition! {
        get { return phases[0].terminalCondition }
        //set { phases[0].}
    }
    
    var traj: State!
    
    // Run settings
    var pctComplete: Double = 0
    var isRunning = false
    var returnCode : Int = 0
    let analysisDispatchQueue = DispatchQueue(label: "analysisRunQueue", qos: .utility)
    var progressReporter: AnalysisProgressReporter?
    var runMode = AnalysisRunMode.parallel {
        didSet {
            for thisPhase in self.phases {
                thisPhase.runMode = self.runMode
            }
        }
    }

    // Run variant parameters
    var runVariants: [RunVariant] = []
    var useGroupedVariants: Bool = false
    var numMonteCarloRuns: Int = 1
    
    // Logging
    var _bufferLog = NSMutableAttributedString() // This string is used to store any logs prior to the initialization of the log message text view
    var logMessageView: TZLogger? {
        didSet {
            if _bufferLog.string != "" {
                logMessageView?.logMessage(_bufferLog)
                _bufferLog = NSMutableAttributedString()
            }
        }
    }
    // Outputs
    var textOutputViewer: TZTextOutputViewer?
    var plotOutputViewer: TZPlotOutputViewer?
    
    override init(){
        super.init()
        phases = []
    }
    init(initPhase phase: TZPhase){
        super.init()
        phases = [phase]
    }
    
    // Validity check prior to running
    /**
     Check whether the analysis has enough inputs defined in order to run
     If this function throws an error, the analysis cannot be run
     */
    func isValid() throws {
        if self.terminalCondition == nil { throw AnalysisError.NoTerminalCondition }
        if self.defaultTimestep <= 0 { throw AnalysisError.TimeStepError }
    }
    // MARK: Codable implementation
    enum CodingKeys: String, CodingKey {
        case name
        case conditions
        case inputSettings
        case plots
        case phases
    }

    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)

        var allConds = try container.nestedUnkeyedContainer(forKey: .conditions)
        while(!allConds.isAtEnd){
            let decoder = try allConds.superDecoder()
            if let thisCond = Condition(decoder: decoder, referencing: self) {
                conditions.append(thisCond)
            }
        }
        
        do {
            var allPhases = try container.nestedUnkeyedContainer(forKey: .phases)
            while(!allPhases.isAtEnd){
                let decoder = try allPhases.superDecoder()
                if let thisPhase = TZPhase(decoder: decoder, referencing: self) {
                    phases.append(thisPhase)
                }
            }
        } catch { // If there is only one phase assumed and its data is stored in the top level file
            if let defaultPhase = TZPhase(decoder: decoder, referencing: self) {
                phases = [defaultPhase]
            }
        }
        
        var allTZOutputs = try container.nestedUnkeyedContainer(forKey: .plots)
        var plotsTemp = allTZOutputs
        while(!allTZOutputs.isAtEnd)
        {
            let output = try allTZOutputs.nestedContainer(keyedBy: TZOutput.CustomCoderType.self)
            let type = try output.decode(TZOutput.OutputType.self, forKey: TZOutput.CustomCoderType.type)
            var newOutput : TZOutput?
            let decoder = try plotsTemp.superDecoder()

            switch type {
            case .text:
                newOutput = TZTextOutput(decoder: decoder, referencing: self)
            case .plot:
                newOutput = TZPlot(decoder: decoder, referencing: self)
            }

            if newOutput != nil { plots.append(newOutput!) }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(conditions, forKey: .conditions)
        try container.encode(plots, forKey: .plots)
        try container.encode(phases, forKey: .phases)
    }
}
