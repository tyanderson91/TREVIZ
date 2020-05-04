//
//  TZOutput.swift
//  Treviz
//
//  This is the superclass for all plots, text output, and any other output sets for an analysis
//
//  Created by Tyler Anderson on 10/2/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
import Foundation


enum TZOutputError: Error {
    case MissingVariableError
    case MissingTrajectoryError
    case MissingPointsError
    case UnmatchedConditionError
}
extension TZOutputError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .MissingVariableError:
            return NSLocalizedString("Missing variable assignment", comment: "")
        case .MissingTrajectoryError:
            return NSLocalizedString("Trajectory not assigned", comment: "")
        case .MissingPointsError:
            return NSLocalizedString("No points could be found", comment: "")
        case .UnmatchedConditionError:
            return NSLocalizedString("No matching points found for condition", comment: "")
        }
    }
}

/** This is the superclass for all plots, text output, and any other output sets for an analysis.
 An output contains all the configuration data required to present the requested data. Details about the implementation of the data display are handled by subclasses (TZTextOutput, TZPlot)
 */
class TZOutput : NSObject, Codable {
    
    @objc var displayName: String {
        var name = ""
        let varnames = [var1, var2, var3].compactMap { $0?.name }
        name += varnames.joined(separator: ", ")
        if categoryVar != nil { name += " by " + categoryVar!.name }
        if condition != nil { name += " at " + condition!.name}
        return name
    }
    @objc var id : Int
    @objc var title : String = ""
    @objc var plotType : TZPlotType
    @objc var var1 : Variable?
    @objc var var2 : Variable?
    @objc var var3 : Variable?
    var categoryVar : Parameter?
    @objc weak var condition : Condition?
    var curTrajectory : State?
    
    init(id : Int, plotType : TZPlotType){// TODO: come up with a way to automatically enforce unique IDs
        self.id = id
        self.plotType = plotType
        super.init()
    }
    
    init?(with dict: Dictionary<String,Any>){
        if let id = dict["id"] as? Int {self.id = id} else {return nil}
        if let plotType = dict["plot type"] as? TZPlotType {self.plotType = plotType} else {return nil}
        super.init()
        if let title = dict["title"] as? String {self.title = title}
        if let var1 = dict["variable1"] as? Variable {self.var1 = var1}
        if let var2 = dict["variable2"] as? Variable {self.var2 = var2}
        if let var3 = dict["variable3"] as? Variable {self.var3 = var3}
        if let categoryvar = dict["category"] as? Parameter {self.categoryVar = categoryvar}

        
        if let condition = dict["condition"] as? Condition {self.condition = condition}
    }
    
    convenience init(id : Int, vars : [Variable], plotType : TZPlotType) {
        var title = ""
        for thisVar in vars{
            title += thisVar.name
            if thisVar != vars.last {title += " vs "} // TODO: vary this for the different plot types
        }
        self.init(id: id, plotType: plotType)
        if vars.count >= 1 { var1 = vars[0] }
        if vars.count >= 2 { var2 = vars[1] }
        if vars.count >= 3 { var3 = vars[2] }
        if vars.count >= 4 { categoryVar = vars[4] }
    }
    
    convenience init(id: Int, with output : TZOutput) {
        self.init(id : id, plotType: output.plotType)
        title = output.title
        var1 = output.var1
        var2 = output.var2
        var3 = output.var3
        categoryVar = output.categoryVar
        condition = output.condition
        curTrajectory = output.curTrajectory
    }
    
    // MARK: NSCoding implementation
    /*
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(title, forKey: "title")
        coder.encode(var1, forKey: "var1")
        coder.encode(var2, forKey: "var2")
        coder.encode(var3, forKey: "var3")
        coder.encode(categoryVar, forKey: "categoryVar")
        coder.encode(condition, forKey: "condition")
        coder.encode(plotType.name, forKey: "plotType")
    }
    required init?(coder: NSCoder) {
        id = coder.decodeInteger(forKey: "id")
        title = coder.decodeObject(forKey: "title") as? String ?? ""
        var1 = coder.decodeObject(forKey: "var1") as? Variable ?? nil
        var2 = coder.decodeObject(forKey: "var2") as? Variable ?? nil
        var3 = coder.decodeObject(forKey: "var3") as? Variable ?? nil
        categoryVar = coder.decodeObject(forKey: "categoryVar") as? Parameter ?? nil
        condition = coder.decodeObject(forKey: "condition") as? Condition
        let plotTypeName = coder.decodeObject(forKey: "plotType") as? String
        if let curPlotType = TZPlotType.getPlotTypeByName(plotTypeName!) { plotType = curPlotType }
        else { return nil } // TODO: throw error message that the plot type name can't be found
        
        super.init()
    }*/
    
    // MARK: Codable implementation
    enum CodingsKeys: CodingKey {
        case id
        case title
        case var1
        case var2
        case var3
        case catVar
        case condition
        case plotTypeID
        case outputType
    }
    
    enum OutputType: String, Codable {
        case text = "text"
        case plot = "plot"
    }
    enum CustomCoderType: String, CodingKey {
        case type = "outputType"
        case condition = "condition"
    }
    
    convenience init(from decoder: Decoder, referencing Conditions: [Condition]) throws {
        try self.init(from: decoder)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingsKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        var plotTypeID = ""
        do {
            plotTypeID = try container.decode(String.self, forKey: .plotTypeID)
            plotType = TZPlotType.allPlotTypes.first { $0.id == plotTypeID }!
        } catch { throw TZPlotTypeError.InvalidPlotType }
        
        if true {
            var1 = try container.decode(Variable.self, forKey: .var1)
        }
        if plotType.nAxis >= 2 {
            var2 = try container.decode(Variable.self, forKey: .var2)
        }
        if plotType.nAxis >= 3 {
            var3 = try container.decode(Variable.self, forKey: .var3)
        }
        if (plotType.nVars > plotType.nAxis) && (plotTypeID != "contour2d ") {
            categoryVar = try container.decode(Variable.self, forKey: .catVar)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingsKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(var1, forKey: .var1)
        try container.encode(var2, forKey: .var2)
        try container.encode(var3, forKey: .var3)
        //try container.encode(var1?.id, forKey: .var1)
        //try container.encode(var2?.id, forKey: .var2)
        //try container.encode(var3?.id, forKey: .var3)
        try container.encode(condition?.name, forKey: .condition)
        try container.encode(plotType.id, forKey: .plotTypeID)
    }
    
    // MARK: Check validity
    func assertValid() throws {
        let condValid = (condition != nil) == (plotType.requiresCondition)
        let var1Valid = (var1 != nil) // == plotType.nAxis >= 1
        let var2Valid = (var2 != nil) == (plotType.nAxis >= 2)
        let var3Valid = (var3 != nil) == (plotType.nAxis >= 3)
        var catVarValid : Bool!
        if plotType.id == "contour2d" {
            catVarValid = categoryVar == nil
        } else {
            catVarValid = (categoryVar != nil) == (plotType.nVars > plotType.nAxis) // If there are more categories than axes, then one var must be a category (except for with contours)
        }
        assert(condValid, "Output \(title) condition setting is invalid")
        assert(var1Valid, "Output \(title) var1 setting is invalid")
        assert(var2Valid, "Output \(title) var2 setting is invalid")
        assert(var3Valid, "Output \(title) var3 setting is invalid")
        assert(catVarValid, "Output \(title) category var setting is invalid")
        //return condValid && var1Valid && var2Valid && var3Valid && catVarValid
    }
    
    /*
    // MARK: collect data
    private static func outputDataType(for plotType: TZPlotType)->OutputDataSet{
        let plotTypeOutputDict : Dictionary<TZPlotType, OutputDataSet> = [
            .singleValue: OutputDataSetLines(),
            //.multiValue:
            //.boxplot: OutputDataSetLines(),
            //.multiBoxplot,
            //.histogram: OutputDataSetLines
            .oneLine2d: OutputDataSetLines(),
            //.multiLine2d:
            .multiPoint2d: OutputDataSetPoints(),
            //.multiPointCat2d:
            //.contour2d:
            .oneLine3d: OutputDataSetLines(),
            //.multiLine3d,
            .multiPoint3d: OutputDataSetPoints()
            //multiPointCat3d:
            //.surface3d
        ]
        let outputData = plotTypeOutputDict[plotType] ?? OutputDataSetSingle()
        return outputData
    }*/
    
    func getData() throws -> Any? {
        guard let curTraj = curTrajectory else { throw TZOutputError.MissingTrajectoryError }
        if plotType.requiresCondition {
            var lineSet = OutputDataSetLines()
            guard let condStates = curTraj[condition!] else {
                throw TZOutputError.UnmatchedConditionError }
            if var1 != nil { lineSet.var1 = condStates[var1!.id]! }
            if var2 != nil { lineSet.var2 = condStates[var2!.id]! }
            if var3 != nil { lineSet.var3 = condStates[var3!.id]! }
            return lineSet
        } else if categoryVar == nil {
            var lineSet = OutputDataSetLines()
            if var1 != nil { lineSet.var1 = curTraj[var1!.id].value }
            if var2 != nil { lineSet.var2 = curTraj[var2!.id].value }
            if var3 != nil { lineSet.var3 = curTraj[var3!.id].value }
            return lineSet
        } else { return nil } // TODO: Implement category variables
        /*
        guard let thisVar = self.var1 else { throw TZOutputError.MissingVariableError }
        guard let varDoubleValues = curTraj[thisVar, condition!] else { throw TZOutputError.UnmatchedConditionError }
        guard varDoubleValues.count >= 1 else { throw TZOutputError.MissingPointsError }
        
        outputSet.var1 = varDoubleValues
        */
    }

}

