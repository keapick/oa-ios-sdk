//
//  UserAgentCollectorTests.swift
//  MarketingDataTests
//
//  Created by echo on 11/24/24.
//

import XCTest
@testable import MarketingData

final class UserAgentCollectorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReadUserAgentFromWebViewViaKVO() async throws {
        if let agent = await UserAgentCollector(dataStore: NullDataStore()).readUserAgentFromWebViewViaKVO() {
            XCTAssertTrue(agent.contains("Mozilla/5.0"))
        } else {
            XCTFail()
        }
    }
    
    func testReadUserAgentFromWebViewViaJS() async throws {
        if let agent = await UserAgentCollector(dataStore: NullDataStore()).readUserAgentFromWebViewViaJS() {
            XCTAssertTrue(agent.contains("Mozilla/5.0"))
        } else {
            XCTFail()
        }
    }
    
    func testUserAgentReadMethodsAreEquivalent() async throws {
        // Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        if let agent1 = await UserAgentCollector(dataStore: NullDataStore()).readUserAgentFromWebViewViaJS(),
            let agent2 = await UserAgentCollector(dataStore: NullDataStore()).readUserAgentFromWebViewViaKVO() {
            
            XCTAssertTrue(agent1 == agent2)
        } else {
            XCTFail()
        }
    }
}
