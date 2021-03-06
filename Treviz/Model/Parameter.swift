//
//  Parameter.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/12/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 This protocol is adopted by every class used as a input parameter or plotting variable. The standard Variable class adopts this protocol for all numerical variable, but it can also be adopted by categorical parameters, such as integrator type, or physics model
 
 Steps required to add parameters
 Model:
 1. Create a new class for the parameter if needed
 2. Make sure the class conforms to Codable and StringValue
 3. Set a default value in phase
 4. Add param to param list within the phase constructor
 5. Add encoding and decoding within Phase
 Test:
 6. Make unit tests for read/write.
 View Controller:
 7. Add param selector and value buttons to view controller
 8. Add the param value view to the view controller’s list of param value views
 9. Connect the param itself to the selector and param value buttons
 */
protocol Parameter {
    var id: ParamID {get set}
    var name: String {get}
    var isParam : Bool {get set} // Defines whether the parameter is used as a 'parameter' in the current analysis; that is, whether it is varied as an input across multiple analysis runs
    static var paramConstructor: (_ param: Parameter)->RunVariant? {get}
    func setValue(to: String)
    func valueSetter(string: String)->StringValue?
    var nomValue: StringValue? { get }
    var stringValue: String { get }
}
extension Parameter {
    var nomValue: StringValue? {
        let valuestr = stringValue
        return valueSetter(string: valuestr)
    }
}

class NumberParam : Parameter, Comparable {
    static func < (lhs: NumberParam, rhs: NumberParam) -> Bool { return lhs.value < rhs.value }
    static func == (lhs: NumberParam, rhs: NumberParam) -> Bool { return lhs.value == rhs.value }
    
    var id: ParamID
    var name: String
    var isParam: Bool = false
    var value: VarValue = 0
    var stringValue: String { return value.valuestr }
    
    static var paramConstructor: (Parameter) -> RunVariant? = { (param: Parameter) in
        return SingleNumberRunVariant(param: param) ?? nil
    }
    func setValue(to string: String) {
        if let newVal = VarValue(string) { value = newVal }
    }
    func valueSetter(string: String) -> StringValue? {
        if let val = VarValue(string) { return val }
        else { return nil }
    }

    init(id numID: ParamID, name nameIn: String){
        id = numID
        name = nameIn
    }
    
    convenience init(id numID: ParamID, name nameIn: String, value valIn: VarValue){
        self.init(id: numID, name: nameIn)
        value = valIn
    }
    
    func copy()->Parameter {
        let newParam = NumberParam(id: id, name: name, value: value)
        newParam.isParam = isParam
        return newParam
    }
}

class EnumGroupParam: Parameter {
    var id: ParamID
    var name: String
    var isParam: Bool = false
    var value: StringValue
    var stringValue: String { return value.valuestr }
    var enumType: StringValue.Type
    var options: [StringValue] = []
    static var paramConstructor: (Parameter) -> RunVariant? = { (param: Parameter) in
        return EnumGroupRunVariant(param: param) ?? nil
    }
    func setValue(to string: String) {
        if let newVal = enumType.init(stringLiteral: string)  {value = newVal}
    }
    func valueSetter(string: String) -> StringValue? {
        if let newVal = enumType.init(stringLiteral: string) { return newVal }
        else { return nil }
    }
    
    init(id numID: ParamID, name nameIn: String, enumType enumTypeIn: StringValue.Type){
        id = numID
        name = nameIn
        enumType = enumTypeIn
        value = ""
    }
    
    convenience init(id numID: ParamID, name nameIn: String, enumType enumTypeIn: StringValue.Type, value valIn: StringValue){
        self.init(id: numID, name: nameIn, enumType: enumTypeIn)
        value = valIn
    }
    
    convenience init(id numID: ParamID, name nameIn: String, enumType enumTypeIn: StringValue.Type, value valIn: StringValue, options optionsIn: [StringValue]){
        self.init(id: numID, name: nameIn, enumType: enumTypeIn, value: valIn)
        options = optionsIn
    }
}

class BoolParam: Parameter {
    
    var id: ParamID
    var name: String
    var isParam: Bool = false
    var value: Bool = false
    var stringValue: String { return value.valuestr }
    static var paramConstructor: (Parameter) -> RunVariant? = { (param: Parameter) in
        return BoolRunVariant(param: param) ?? nil
    }
    
    func setValue(to string: String) {
        if let newVal = Bool(stringLiteral: string) { value = newVal }
    }
    func valueSetter(string: String) -> StringValue? {
        if let newVal = Bool(stringLiteral: string) { return newVal }
        else { return nil }
    }
    
    init(id numID: ParamID, name nameIn: String){
        id = numID
        name = nameIn
    }
    
    convenience init(id numID: ParamID, name nameIn: String, value valIn: Bool){
        self.init(id: numID, name: nameIn)
        value = valIn
    }
}
/** Param that stores the current trade group name for group runs */
struct TradeGroupParam: Parameter {
    var id = "tradeGroup"
    var name = "Trade Group"
    var tradeGroupName: String = ""
    var isParam = false
    static var paramConstructor: (Parameter) -> RunVariant? = {(Parameter)->RunVariant? in return nil}
    func setValue(to stringIn: String) {}
    func valueSetter(string: String) -> StringValue? {return nil}
    var stringValue: String = ""
}
