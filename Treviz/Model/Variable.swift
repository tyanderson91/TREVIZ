//
//  Variable.swift
//  Treviz
//
//  Created by Tyler Anderson on 3/6/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa
import simd

typealias VariableID = String
typealias VarValue = Float

/**
Variable is a class that defines a single changeable numerical property of a vehicle, including name, unit information, and value. Used to display input state and output information
 
 TODO for turning into struct:
 - get rid of NSCopying and NSCoding
 - create static typess
 */
class Variable : NSObject, Parameter, Codable { //TODO: reconsider whether this could be a struct
    
    let id: VariableID
    let name: String
    let symbol: String!
    var units: String //TODO: Turn units into a separate type
    var value: [VarValue] = []
    var isValid: Bool = true
    var hasParams: Bool {return isParam}
    var isParam: Bool = false
    /*
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "varid")
        coder.encode(name, forKey: "name")
        coder.encode(symbol, forKey: "symbol")
        coder.encode(units, forKey: "units")
        coder.encode(value, forKey: "value")
        coder.encode(isParam, forKey: "isParam")
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeObject(forKey: "varid") as? VariableID ?? ""
        name = coder.decodeObject(forKey: "name") as? String ?? ""
        symbol = coder.decodeObject(forKey: "symbol") as? String ?? ""
        units = coder.decodeObject(forKey: "units") as? String ?? ""
        isParam = coder.decodeBool(forKey: "isParam")
        value = coder.decodeObject(forKey: "value") as? [VarValue] ?? [VarValue]()

    }*/
    
    init(_ idIn: VariableID, named nameIn:String = "", symbol symbolIn: String = "", units unitsIn: String = ""){
        id = idIn
        name = nameIn
        symbol = symbolIn
        units = unitsIn
        super.init()
    }
    
    // Subscripts to get value data
    subscript(index: Int)->VarValue?{
        get {
            if index >= 0 && index < value.count{
                return value[index]
            } else {return nil}
        }
        set (newVal) {
            if newVal != nil {value.insert(newVal!, at: index)}
        }
    }
    
    subscript(condition: Condition)->[VarValue]?{
        var output : [VarValue] = []
        let conditionIndices = condition.meetsConditionIndex
        guard self.value.count == conditionIndices.count else {return nil}
        for thisIndex in conditionIndices {
            output.append(self.value[thisIndex])
        }
        return output
    }
}
