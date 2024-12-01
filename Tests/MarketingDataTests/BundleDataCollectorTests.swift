//
//  BundleUtilityTests.swift
//  MarketingDataTests
//
//  Created by echo on 11/24/24.
//

import XCTest
@testable import MarketingData

final class BundleDataCollectorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReadBundleIdentifier() throws {
        let identifier = BundleDataCollector.readBundleID()
        
        XCTAssertNotNil(identifier)
        XCTAssertTrue("com.apple.dt.xctest.tool" == identifier)
    }
    
    func testReadTeamId() throws {
        if let _ = BundleDataCollector.readTeamID() {
            XCTFail()
        }
    }
    
    func testReadBundleShortVersion() throws {
        if let version = BundleDataCollector.readBundleShortVersion() {
            // Host app version, in this case xctest.
            XCTAssertNotNil(version)
            XCTAssertTrue(version >= "15.0")
        } else {
            XCTFail()
        }
    }
    
    func testReadBundleVersion() throws {
        if let version = BundleDataCollector.readBundleVersion() {
            // Host app build number, in this case xctest. So it's pretty meaningless.
            XCTAssertNotNil(version)
            XCTAssertTrue(version >= "0")
        } else {
            XCTFail()
        }
    }
    
    func testReadExecutableName() throws {
        let name = BundleDataCollector.readExecutableName()
        
        // Host app executable name is "xctest"
        XCTAssertNotNil(name)
        XCTAssertTrue(name == "xctest")
    }
    
    func testReadExecutableCreationDate() throws {
        if let dateString = BundleDataCollector.readExecutableCreationDate(), let double = Double(dateString) {
            let date = Date(timeIntervalSince1970: double)
            XCTAssertTrue(date < Date())
        } else {
            XCTFail()
        }
    }
    
    func testReadLibraryDirectoryCreationDate() throws {
        if let dateString = BundleDataCollector.readLibraryDirectoryCreationDate(), let double = Double(dateString) {
            let date = Date(timeIntervalSince1970: double)
            XCTAssertTrue(date < Date())
        } else {
            XCTFail()
        }
    }
    
    func testReadAppStoreReceipt() throws {
        // receipt is not available in unit tests
        if let _ = BundleDataCollector.readAppStoreReceipt() {
            XCTFail()
        }
    }
    
    func testReadURISchemes() throws {
        let schemes = BundleDataCollector.readURISchemes()
        
        XCTAssertNotNil(schemes)
        
        // TODO: unit tests have no schemes, this test is more valuable within a host app
        for schemeData in schemes {
            if schemeData.type == "Editor" {
                XCTAssertTrue(schemeData.schemes.count == 2)
                XCTAssertTrue(schemeData.schemes.contains("marketing"))
                XCTAssertTrue(schemeData.schemes.contains("marketingTest"))
                
            } else if schemeData.type == "Viewer" {
                XCTAssertTrue(schemeData.schemes.count == 1)
                XCTAssertTrue(schemeData.schemes.contains("fbExample12345"))
            }
        }
    }
}
