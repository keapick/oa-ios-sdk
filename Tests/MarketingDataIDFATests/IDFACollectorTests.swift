//
//  IDFACollectorTests.swift
//  MarketingDataIDFATests
//
//  Created by echo on 11/24/24.
//

import XCTest
@testable import MarketingDataIDFA

final class IDFACollectorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReadIdentifierForAdvertiser() throws {
        if let idfa = IDFACollector().readIdentifierForAdvertiser() {
            XCTAssertTrue(idfa == "00000000-0000-0000-0000-000000000000")
        } else {
            XCTFail()
        }
    }
    
    func testReadAppTrackingTransparencyOptInStatus() throws {
        if let status = IDFACollector().readAppTrackingTransparencyOptInStatus() {
            
            // ATT status reflects the Host apps ATT status, so only check that it's not empty
            XCTAssertNotNil(status)
            XCTAssertTrue(status.count > 0)
        } else {
            XCTFail()
        }
    }
}
