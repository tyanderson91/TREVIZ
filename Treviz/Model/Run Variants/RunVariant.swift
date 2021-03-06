//
//  RunVariant.swift
//  Treviz
//
//  Created by Tyler Anderson on 9/13/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import Foundation

enum DistributionType: String, CaseIterable {
    case normal = "Normal"
    case uniform = "Uniform"
 
    func summary(runVariant: MCRunVariant)->String{
        switch self {
        case .normal:
            return "𝐍(\(runVariant.mean?.valuestr ?? "?"),\(runVariant.sigma?.valuestr ?? "?"))"
        case .uniform:
            return "𝐔(\(runVariant.min?.valuestr ?? "?"),\(runVariant.max?.valuestr ?? "?"))"
        }
    }
}

enum RunVariantType: String, CaseIterable {
    case single = "Single"
    case montecarlo = "MC"
    case trade = "Trade"
}

enum RunVariantError: Error {
    case MissingParamID
    case ReadError
    case TradeGroupValueError
}

/**Required to set initial param value during initialization from Codable*/
struct DummyParam : Parameter {
    var id: ParamID = ""
    var name: String = ""
    var isParam: Bool = false
    var stringValue: String = ""
    static var paramConstructor = {(_ param: Parameter)->RunVariant? in return nil}
    func setValue(to: String){}
    func valueSetter(string: String) -> StringValue? {return nil}
}
/** Placeholder class used in creating Runs when other run variants are not used*/
class DummyRunVariant: RunVariant, MCRunVariant {
    var distributionType: DistributionType = .normal
    var mean: VarValue?
    var sigma: VarValue?
    var min: VarValue?
    var max: VarValue?
    init(){
        super.init(param: DummyParam())!
    }
    required init(from decoder: Decoder) throws {
        fatalError("Dummy Run Variant should never need to be created from Coder")
    }
    func randomValue(seed: Double?)->VarValue { return 0.0 }
}

/** Type of run variant that can return a random value to be used in monte-carlo analysis*/
protocol MCRunVariant {
    var parameter: Parameter {get set}
    var paramID: ParamID {get}
    func randomValue(seed: Double?)->VarValue
    var distributionType: DistributionType {get set}
    var distributionSummary: String {get}
    var mean: VarValue? {get set}
    var sigma: VarValue? {get set}
    var min: VarValue? {get set}
    var max: VarValue? {get set}
}
extension MCRunVariant {
    var distributionSummary: String { return distributionType.summary(runVariant: self) }
}

extension Analysis {
    var tradeRunVariants: [RunVariant] {
        return runVariants.filter { $0.variantType == .trade && $0.isActive }
    }
    var numTradeGroups: Int {
        var numTradeRuns: Int = 1
        if tradeRunVariants.isEmpty { numTradeRuns = 0 }
        else if useGroupedVariants { numTradeRuns = tradeRunVariants.map({$0.tradeValues.count}).max() ?? 0 }
        else {
            for thisVariant in tradeRunVariants {
                let tradeCounts = thisVariant.tradeValues.filter({$0 != nil}).count
                let curNumRuns = tradeCounts > 0 ? tradeCounts : 1
                numTradeRuns = numTradeRuns * curNumRuns
            }
        }
        return numTradeRuns
    }
    var mcRunVariants: [MCRunVariant] {
        return runVariants.filter { $0 is MCRunVariant && $0.variantType == .montecarlo && $0.isActive } as! [MCRunVariant]
    }
}
/**
 A set of configuration parameters that describes how to vary a single parameter within an analysis, whether through monte-carlo dispersions or distinct variations within a trade study
 */
class RunVariant: Codable {
    var paramID: ParamID { return parameter.id }
    var isActive: Bool {
        get { return parameter.isParam }
        set { parameter.isParam = newValue }
    }
    var curValue: StringValue { return "" }
    var options: [StringValue] = [] // The list of valid alternatives
    var variantType: RunVariantType = .single
    var tradeValues: [StringValue?] = [] // List of variants to be used in trade study
    var parameter: Parameter
    func setValue(from string: String) {return}
    var paramVariantSummary: String {
        switch variantType {
        case .single:
            return "\(paramID) = \(parameter.stringValue)"
        case .montecarlo:
            guard let mcvar = self as? MCRunVariant else { return "" }
            return "\(paramID) ∼ \(mcvar.distributionType.summary(runVariant: mcvar)))"
        case .trade:
            let valuestr = self.tradeValues.filter({$0 != nil}).map({$0!.valuestr}).joined(separator: ", ")
            return "\(paramID) ∈ {\(valuestr)}"
        }
    }
    
    init?(param: Parameter) {
        parameter = param
    }
    func setTradeValues(from strings: [String]) {
        var tempTradeValues: [StringValue] = []
        strings.forEach {
            if let val = parameter.valueSetter(string: $0) {
                tempTradeValues.append(val)
            } else { return }
        }
        tradeValues = tempTradeValues
    }
    
    //MARK: Codable
    enum VariantTypeKeys: String, CodingKey, Encodable {
        case mc = "MC Variants"
        case single = "Single Variants"
        case trade = "Trade Variants"
        case type = "Trade Type"
    }
    enum CodingKeys: String, CodingKey {
        case paramID
        case nominal
        case tradeValues
        case variantType
        case category
        // MC run variants
        case min
        case max
        case mean
        case sigma
        case distribution
    }
    enum CategoryKey: String, Codable {
        case variable
        case enumeration
        case number
        case boolean
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let variantTypeString = try? container.decode(String.self, forKey: .variantType) 
        if ["trade", "trade study"].contains(variantTypeString?.lowercased()) {
            variantType = .trade
        } else if ["mc", "monte carlo", "monte-carlo"].contains(variantTypeString?.lowercased()) {
            variantType = .montecarlo
        } else {
            variantType = .single
        }
        parameter = DummyParam()
    }
    
    func encode(to encoder: Encoder) throws {
        let simpleIO = encoder.userInfo[.simpleIOKey] as? Bool ?? false
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paramID, forKey: .paramID)
        try container.encode(curValue.valuestr, forKey: .nominal)
        if !simpleIO {
            try container.encode(variantType.rawValue.lowercased(), forKey: .variantType)
        }
    }
}


/**A type of run variant used to define the variations on a Variable*/
class VariableRunVariant: RunVariant, MCRunVariant {
    var distributionType: DistributionType = .uniform
    // Monte-carlo dispersion parameters
    var min: VarValue?
    var max: VarValue?
    var mean: VarValue?
    var sigma: VarValue?
    var variable: Variable { return parameter as! Variable }
    override var curValue: StringValue { return variable.value[0]}
    override init?(param: Parameter) {
        super.init(param: param)
    }
    override func setValue(from string: String) {
        if let tempVal = VarValue(string) { variable.value[0] = tempVal }
    }
    //MARK: Codable
    enum VariableCodingKeys: String, CodingKey {
        case min
        case max
        case mean
        case sigma
    }
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.distribution) {
            let distName = try container.decode(String.self, forKey: .distribution)
            distributionType = DistributionType(rawValue: distName) ?? .uniform
        }
        if container.contains(.min) { min = try container.decode(VarValue.self, forKey: .min)}
        if container.contains(.max) { max = try container.decode(VarValue.self, forKey: .max)}
        if container.contains(.mean) { mean = try container.decode(VarValue.self, forKey: .mean)}
        if container.contains(.sigma) { sigma = try container.decode(VarValue.self, forKey: .sigma)}
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VariableCodingKeys.self)
        if min != nil {try container.encode(min, forKey: .min)}
        if max != nil {try container.encode(max, forKey: .max)}
        if mean != nil {try container.encode(mean, forKey: .mean)}
        if sigma != nil {try container.encode(sigma, forKey: .sigma)}
        
        var categoryContainer = encoder.container(keyedBy: CodingKeys.self)
        try categoryContainer.encode(CategoryKey.variable, forKey: .category)
    }
    
    func randomValue(seed: Double?)->VarValue{
        switch distributionType {
        case .normal:
            return variable.value[0] // TODO: Make actually return random value and respond to seed
        case .uniform:
            return VarValue.random(in: min!...max!)
        }
    }
}

/**A type of Run Variant used to vary a single number parameter that is not a variable, such as a timestep*/
class SingleNumberRunVariant: RunVariant, MCRunVariant {
    var distributionType: DistributionType = .normal
    // Monte-carlo dispersion parameters
    var min: VarValue?
    var max: VarValue?
    var mean: VarValue?
    var sigma: VarValue?
    var number: NumberParam { return parameter as! NumberParam }
    override var curValue: StringValue { return number.value }
    override func setValue(from string: String) {
        if let tempVal = VarValue(string) { number.value = tempVal }
    }
    override init?(param: Parameter) {
        super.init(param: param)
    }
    //MARK: Codable
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: VariableRunVariant.VariableCodingKeys.self)
        if container.contains(.min) { min = try container.decode(VarValue.self, forKey: .min)}
        if container.contains(.max) { max = try container.decode(VarValue.self, forKey: .max)}
        if container.contains(.mean) { mean = try container.decode(VarValue.self, forKey: .mean)}
        if container.contains(.sigma) { sigma = try container.decode(VarValue.self, forKey: .sigma)}
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VariableRunVariant.VariableCodingKeys.self)
        if min != nil { try container.encode(min, forKey: .min) }
        if max != nil { try container.encode(max, forKey: .max) }
        if mean != nil { try container.encode(mean, forKey: .mean) }
        if sigma != nil { try container.encode(sigma, forKey: .sigma) }
        
        var categoryContainer = encoder.container(keyedBy: CodingKeys.self)
        try categoryContainer.encode(CategoryKey.number, forKey: .category)
    }
    
    func randomValue(seed: Double?)->VarValue{
        switch distributionType {
        case .normal:
            return number.value // TODO: Make actually return random value and respond to seed
        case .uniform:
            return VarValue.random(in: min!...max!)
        }
    }
}

/**A type of run variant used to vary a parameter with a fixed number of options like an Enum*/
class EnumGroupRunVariant: RunVariant {
    var enumParam: EnumGroupParam { return parameter as! EnumGroupParam }
    var enumType: StringValue.Type { return enumParam.enumType }
    override var curValue: StringValue { return enumParam.value }
    
    override func setValue(from string: String) {
        guard let newVal = enumType.init(stringLiteral: string) else { return }
        enumParam.value = newVal
    }
    override init?(param: Parameter) {
        guard let curEnumParam = param as? EnumGroupParam else { return nil }
        super.init(param: curEnumParam)
        options = curEnumParam.options
    }
    //MARK: Codable
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var categoryContainer = encoder.container(keyedBy: CodingKeys.self)
        try categoryContainer.encode(CategoryKey.enumeration, forKey: .category)
    }
}

/**A type of run variant used to define variations for a boolean parameter*/
class BoolRunVariant: RunVariant {
    var paramEnabled: Bool {
        get { return (parameter as? BoolParam)?.value ?? false }
        set { (parameter as? BoolParam)?.value = newValue }
    }
    override var curValue: StringValue {
        get { return paramEnabled }
        set { paramEnabled = newValue as? Bool ?? paramEnabled }
    }
    override init?(param: Parameter) {
        guard let curBoolParam = param as? BoolParam else { return nil }
        super.init(param: curBoolParam)
    }
    override func setValue(from string: String) {
        guard let newVal = Bool.init(stringLiteral: string) else { return }
        (parameter as? BoolParam)?.value = newVal
    }
    
    //MARK: Codable
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var categoryContainer = encoder.container(keyedBy: CodingKeys.self)
        try categoryContainer.encode(CategoryKey.boolean, forKey: .category)
    }
}
