//
//  AttributionTokenCollectorTests.swift
//  MarketingDataTests
//
//  Created by echo on 11/24/24.
//

import XCTest
@testable import MarketingData

final class AttributionTokenCollectorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReadAppleAttributionToken() async throws {
        if #available(iOS 14.3, macCatalyst 14.3, visionOS 1.0, *) {
            let token = await AttributionTokenCollector(dataStore: NullDataStore()).requestToken()
            
            // Apple attribution tokens are not availble on simulators
            XCTAssertNil(token)
        }
    }
    
    // This test is very slow since Unit tests have no attribution token
//    func testReadAppleAttributionTokenWithRetries() async throws {
//        if #available(iOS 14.3, macCatalyst 14.3, visionOS 1.0, *) {
//            let token = await AttributionTokenCollector().requestAppleAttributionToken(forceFresh: false, dataStore: NullDataStore())
//            
//            // Apple attribution tokens are not availble on simulators
//            XCTAssertNil(token)
//        }
//    }
}
