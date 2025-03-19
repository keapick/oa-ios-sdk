//
//  ScreenCollectorTests.swift
//  MarketingDataTests
//
//  Created by echo on 11/24/24.
//

import XCTest
@testable import MarketingData

final class ScreenCollectorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReadScreenData() async throws {
        let screenData = await ScreenDimensionCollector().readScreenDimensions()
        
        #if os(macOS)
        // Is screen size even useful on macOS?
        XCTAssertNotNil(screenData)
        XCTAssertTrue(screenData.scale == 0)
        XCTAssertTrue(screenData.height == 0)
        XCTAssertTrue(screenData.width == 0)
        #else
        XCTAssertNotNil(screenData)
        XCTAssertTrue(screenData.scale > 0)
        XCTAssertTrue(screenData.height > 0)
        XCTAssertTrue(screenData.width > 0)
        #endif
    }

}
