//
//  RunSettingsTest.swift
//  TrevizTests
//
//  Created by Tyler Anderson on 9/7/20.
//  Copyright © 2020 Tyler Anderson. All rights reserved.
//

import XCTest
@testable import TrajectoryAnalysis

class RunSettingsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSettingsIO() throws {
        //YAML
        let newRunSettings = TZRunSettings()
        newRunSettings.defaultTimestep.value = 0.123
        newRunSettings.propagatorType = .rungeKutta4
        newRunSettings.minTimestep.value = 0.1
        newRunSettings.maxTimestep.value = 0.5
        newRunSettings.useAdaptiveTimestep.value = true
        
        //Writing Codable
        var dataOut = Data()
        let encoder = JSONEncoder()
        do {
            let encoder = JSONEncoder()
            dataOut = try encoder.encode(newRunSettings)
        } catch { XCTFail() }
        
        // Reading Codable
        var dataIn = Data()
        do {
            let bundle = Bundle(for: type(of: self))
            let filePath = bundle.url(forResource: "TestAnalysis1", withExtension: "json")!
            let analysisData = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            let analysis = try decoder.decode(Analysis.self, from: analysisData)
            let codableSetting = analysis.phases[0].runSettings
            dataIn = try encoder.encode(codableSetting)
        } catch { XCTFail() }
        
        XCTAssertEqual(dataIn, dataOut)
    }
}
