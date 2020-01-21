//
//  State.swift
//  Treviz
//
//  State is an object containing a collection of Variable objects that combined should fully define the state of a vehicle at any point in time
//  Used to read input state, write output state, parse outputs, and create derived states.
//  Converts into an array of Double values before being processed by the propagator
//
//  Created by Tyler Anderson on 3/3/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

class State: NSObject {
    
    var variables : [Variable] = []
    var length : Int {
        var curlen = -1
        for thisVar in variables {
            curlen = max(curlen, thisVar.value.count)
        }
        return curlen
    }
    
    override init() {
        super.init()
    }
    
    init(variables varsIn: [Variable]) {
        variables = varsIn
        super.init()
    }
    
    func copyAtIndex(_ index: Int)->State{
        let newState = State.init()
        for thisVar in self.variables{
            if let newVar = thisVar.copyAtIndex(index) { newState.variables.append(newVar) }
        }
        return newState
    }

    
    // Subscripts by variable
    subscript(_ varID: VariableID) -> Variable {
        get {
            let thisVar = variables.first(where: {$0.id == varID})!
            return thisVar
        }
    }
    
    subscript(_ varID: VariableID, index: Int) -> VarValue? {
        get {
            let thisVar = self[varID]
            if let thisVal = thisVar[index] {return thisVal}
            else{return nil}
        }
        set (newVal) {
            let thisVar = self[varID]
            if newVal != nil {thisVar[index] = newVal}
        }
    }
    
    //Subscripts by condition
    subscript(varIDs: [VariableID], condition: Condition) -> [VariableID: [VarValue]]? {
        // Note that this subscript take some time to collect, since by default it will evaluate the condition
        var output = [VariableID: [VarValue]]()
        condition.evaluateState(self)
        let conditionIndex = condition.meetsConditionIndex
        
        for thisVarID in varIDs {
            guard self[thisVarID].value.count == condition.meetsCondition?.count else {return nil}
            output[thisVarID] = [VarValue]()
        }
        for thisIndex in conditionIndex {
            for thisVarID in varIDs {
                let thisVarValue = self[thisVarID].value[thisIndex]
                output[thisVarID]!.append(thisVarValue)
            }
        }
        return output
    }
    subscript(vars: [Variable], condition: Condition)->[VariableID: [VarValue]]?{
        let varIDs = vars.map{ $0.id }
        let output = self[varIDs, condition]
        return output
    }
    subscript(varID: VariableID, condition: Condition)->[VarValue]?{
        if let output = self[[varID], condition]{
            return output[varID]}
        else {return nil}
    }
    subscript(variable: Variable, condition: Condition)->[VarValue]?{
        let varID = variable.id
        return self[varID, condition]
    }
    
}
