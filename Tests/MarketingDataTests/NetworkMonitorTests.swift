//
//  NetworkMonitorTests.swift
//  EchoDeviceDataTests
//
//  Created by echo on 11/24/24.
//

import XCTest
@testable import MarketingData

final class NetworkMonitorTests: XCTestCase {
    
    // The monitor maintains a queue for network status updates, make sure it's up and running
    // TODO: this is probably a race with `readCurrentPathData`
    let monitor = NetworkMonitor.shared

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReadCurrentPathData() throws {
        let summary = monitor.readCurrentPathData()
        
        // iPhone sample with cell and wifi
        /*
         ▿ NetworkPathSummary
           - status : "satisfied"
           ▿ interfaces : 2 elements
             ▿ 0 : NetworkInterfaceSummary
               - name : "en0"
               - type : "wifi"
             ▿ 1 : NetworkInterfaceSummary
               - name : "pdp_ip0"
               - type : "cellular"
         */
        
        // Simulator sample
        /*
         ▿ NetworkPathSummary
           - status : "satisfied"
           ▿ interfaces : 1 element
             ▿ 0 : NetworkInterfaceSummary
               - name : "en11"
               - type : "wiredEthernet"
         */
        
        // Assume the test device has internet
        XCTAssertNotNil(summary)
        XCTAssertTrue(summary.status == "satisfied")
    }
    
    func testCrossReferenceNetworkInformation() throws {
        let summary = monitor.readCurrentPathData()
        let interfaces = try NetworkTools.readNetworkInterfaces()
        
        XCTAssertNotNil(summary)
        XCTAssertTrue(summary.status == "satisfied")
        XCTAssertNotNil(interfaces)
        
        // Sample from an iPhone with cell and wifi
        /*
         Printing description of summary:
         ▿ NetworkPathSummary
           - status : "satisfied"
           ▿ interfaces : 2 elements
             ▿ 0 : NetworkInterfaceSummary
               - name : "en0"
               - type : "wifi"
             ▿ 1 : NetworkInterfaceSummary
               - name : "pdp_ip0"
               - type : "cellular"
         
         en0
         Printing description of ipAddresses:
         ▿ 3 elements
           - 0 : "0:0:fe80::303c:f807" // link local. https://en.wikipedia.org/wiki/Link-local_address
           - 1 : "192.168.5.161"
           - 2 : "::fd44:966d:b34e:1:303c:f807" // ULA. https://en.wikipedia.org/wiki/Unique_local_address
         
         pdp_ip0
         Printing description of ipAddresses:
         ▿ 10 elements
           - 0 : "10.32.212.103"
           - 1 : "0:0:fe80::303c:f807" // link local
           - 2 : "::2600:381:b920:3285:303c:f807" // TODO: what are all these for?
           - 3 : "::2600:381:b920:3285:303c:f807"
           - 4 : "::2600:381:b920:3285:303c:f807"
           - 5 : "::2600:381:b920:3285:303c:f807"
           - 6 : "::2600:381:b920:3285:303c:f807"
           - 7 : "::2600:381:b920:3285:303c:f807"
           - 8 : "::2600:381:b920:3285:303c:f807"
           - 9 : "::2600:381:b920:3285:303c:f807"
         */
        
        // all interfaces that provide connectivity must have IP addresses
        for activeNetworkInterface in summary.interfaces {
            var ipAddresses = [String]()
            for networkInterface in interfaces {
                if (networkInterface.name == activeNetworkInterface.name) {
                    ipAddresses.append(networkInterface.address)
                }
            }
            XCTAssert(ipAddresses.count > 0)
        }
    }

}
