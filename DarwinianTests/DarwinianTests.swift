//
//  DarwinianTests.swift
//  DarwinianTests
//
//  Created by Keith Staines on 26/05/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import XCTest
@testable import Darwinian

class DarwinianTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateWorld() {
        let requiredSize = 100
        let world = World(size:requiredSize, waterFraction:50, rockFraction:30, sandFraction:10, soilFraction:10)
        XCTAssertEqual(requiredSize, world.size)
    }
    
    func testNormalisedTerrainRatios() {
        let water = 200.0
        let rock = 50.0
        let sand = 25.0
        let soil = 25.0

        let total = water+rock+sand+soil
        let tr = World.normalizedTerrainRatios(water, rock: rock, sand: sand, soil: soil)
        let tolerance = 0.0001
        XCTAssertEqualWithAccuracy(tr[TerrainType.water]!,water/total, accuracy: tolerance)
        XCTAssertEqualWithAccuracy(tr[TerrainType.rock]!,rock/total, accuracy: tolerance)
        XCTAssertEqualWithAccuracy(tr[TerrainType.sand]!,sand/total, accuracy: tolerance)
        XCTAssertEqualWithAccuracy(tr[TerrainType.soil]!,soil/total, accuracy: tolerance)
    }
    
    func testTerrainForRValue() {
        let terrainRatios = World.normalizedTerrainRatios(60, rock: 20, sand: 10, soil: 10)
        var t:TerrainType
        t = World.terrainForRValue(0.0, terrainRatios: terrainRatios)
        XCTAssertEqual(t, TerrainType.water)
        t = World.terrainForRValue(0.59, terrainRatios: terrainRatios)
        XCTAssertEqual(t, TerrainType.water)
        t = World.terrainForRValue(0.60, terrainRatios: terrainRatios)
        XCTAssertEqual(t, TerrainType.rock)
        t = World.terrainForRValue(0.61, terrainRatios: terrainRatios)
        XCTAssertEqual(t, TerrainType.rock)
        t = World.terrainForRValue(0.79, terrainRatios: terrainRatios)
        XCTAssertEqual(t, TerrainType.rock)
        t = World.terrainForRValue(0.80, terrainRatios: terrainRatios)
        XCTAssertEqual(t, TerrainType.sand)
        t = World.terrainForRValue(0.95, terrainRatios: terrainRatios)
        XCTAssertEqual(t, TerrainType.soil)
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            let requiredSize = 1000
//            let _ = World(size:requiredSize, waterFraction:50, rockFraction:30, sandFraction:10, soilFraction:10)
//        }
//    }
    
}
