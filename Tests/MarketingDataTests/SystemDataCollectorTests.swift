//
//  SystemDataCollectorTests.swift
//  MarketingDataTests
//
//  Created by echo on 11/24/24.
//

import XCTest
@testable import MarketingData

final class SystemDataCollectorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReadCurrentLocale() throws {
        let locale = SystemDataCollector.readCurrentLocale()
     
        // Host app has the locale set to `en_US`
        XCTAssertNotNil(locale)
        XCTAssertTrue("en_US" == locale)
    }

    func testReadIdentifierForVendor() throws {
        let idfv = await SystemDataCollector.readIdentifierForVendor()

        // idfv's are 36 chars long
        XCTAssertNotNil(idfv)
        XCTAssertTrue(idfv.count == 36)
    }
    
    func testReadSysctlSystemInfo() throws {
        let systemInfo = SystemDataCollector.readSysctlSystemInfo()
        
        // macbook pro, intel
        /*
         ▿ SystemInfoSysctl
           - osversion : "22G630"
           - model : "MacBookPro14,3"
           - machine : "x86_64"
           - cputype : 7
           - cpusubtype : 8
         */
        
        // iPhone SE
        /*
         ▿ SystemInfoSysctl
           - osversion : "21E236"
           - model : "D79AP"
           - machine : "iPhone12,8"
           - cputype : 16777228
           - cpusubtype : 2
         */
        
        // Varies by device and simulator host
        // Just confirm the values are not empty
        XCTAssertNotNil(systemInfo)
        XCTAssertTrue(systemInfo.osversion.count > 0)
        XCTAssertTrue(systemInfo.model.count > 0)
        XCTAssertTrue(systemInfo.machine.count > 0)
    }
    
    func testReadUnameSystemInfo() throws {
        
        // macbook pro, intel
        /*
         ▿ SystemInfoUtsname
           - sysname : "Darwin"
           - nodename : "muscaria.local"
           - release : "22.6.0"
           - version : "Darwin Kernel Version 22.6.0: Mon Feb 19 19:48:53 PST 2024; root:xnu-8796.141.3.704.6~1/RELEASE_X86_64"
           - machine : "x86_64"
         */
        
        // iPhone SE
        /*
         ▿ SystemInfoUtsname
           - sysname : "Darwin"
           - nodename : "localhost"
           - release : "23.4.0"
           - version : "Darwin Kernel Version 23.4.0: Fri Mar  8 23:26:31 PST 2024; root:xnu-10063.102.14~67/RELEASE_ARM64_T8030"
           - machine : "iPhone12,8"
         */
        
        // Varies by device and simulator host
        // Confirm the values are not empty
        let systemInfo = SystemDataCollector.readUtsnameSystemInfo()
            
        XCTAssertNotNil(systemInfo)
        XCTAssertTrue(systemInfo.sysname == "Darwin")
        XCTAssertTrue(systemInfo.nodename.count > 0)
        XCTAssertTrue(systemInfo.release.count > 0)
        XCTAssertTrue(systemInfo.version.count > 0)
        XCTAssertTrue(systemInfo.machine.count > 0)
        
        // Confirm version string contains the release and sysname
        XCTAssertTrue(systemInfo.version.contains(systemInfo.release))
        XCTAssertTrue(systemInfo.version.contains(systemInfo.sysname))
    }
    
    func testUnameMachineAndSysctlMachineAreEquivalent() throws {
        let uname = SystemDataCollector.readUtsnameSystemInfo()
        let sysctl = SystemDataCollector.readSysctlSystemInfo()
        
        XCTAssertNotNil(uname)
        XCTAssertNotNil(sysctl)
        
        XCTAssertTrue(uname.machine == sysctl.machine)
    }
    
}
