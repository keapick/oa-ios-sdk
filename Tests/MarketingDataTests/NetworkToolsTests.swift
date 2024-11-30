//
//  NetworkInterfaceTests.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import XCTest
@testable import MarketingData

final class NetworkToolsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReadNetworkInterfaceInfo() throws {
        let networkInfo = try NetworkTools.readNetworkInterfaces()
        
        // Example from an iPhone with cell and wifi
        // TODO: more checks on ipv6, don't have a test environments setup for this
        /*
         ...
         ▿ 3 : NetworkInfoIfaddrs
         - name : "pdp_ip0"
         - type : "ipv4"
         - address : "10.32.212.103"
         ...
         ▿ 5 : NetworkInfoIfaddrs
         - name : "pdp_ip0"
         - type : "ipv6"
         - address : "::2600:381:b920:3285:303c:f807"
         ...
         ▿ 21 : NetworkInfoIfaddrs
         - name : "en0"
         - type : "ipv4"
         - address : "192.168.5.161"
         */
        
        // iPhone 15 simulator has at least one interface
        XCTAssertNotNil(networkInfo)
        XCTAssertTrue(networkInfo.count > 0)
    }
    
    func testReadNetworkInterfaceInfoIPv4() throws {
        let networkInfo = try NetworkTools.readNetworkInterfaces(includeIPv4: true, includeIPv6: false, privateOnly: false)
        
        // iPhone 15 simulator has 2
        XCTAssertNotNil(networkInfo)
        XCTAssertTrue(networkInfo.count > 0)
    }
    
    func testReadNetworkInterfaceInfoIPv4Private() throws {
        let networkInfo = try NetworkTools.readNetworkInterfaces(includeIPv4: true, includeIPv6: false, privateOnly: true)
        
        // iPhone 15 simulator has 1å
        XCTAssertNotNil(networkInfo)
        XCTAssertTrue(networkInfo.count > 0)
    }
    
    func testReadNetworkInterfaceInfoIPv6() throws {
        let networkInfo = try NetworkTools.readNetworkInterfaces(includeIPv4: false, includeIPv6: true, privateOnly: false)
        
        // iPhone 15 simulator has 23
        XCTAssertNotNil(networkInfo)
        XCTAssertTrue(networkInfo.count > 0)
    }
    
    // 127.0.0.1 - localhost
    func testIsPrivateNetworkLocalhost() throws {
        let ipv4: [CChar] = [ 49, 55, 50, 46, 48, 46, 48, 46, 49, 0, 0, 0, 0, 0, 0, 0 ]
        XCTAssertFalse(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 255.255.255.255 - broadcast
    func testIsPrivateNetworkBroadcast() throws {
        let ipv4: [CChar] = [ 50, 53, 53, 46, 50, 53, 53, 46, 50, 53, 53, 46, 50, 53, 53, 0 ]
        XCTAssertFalse(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 198.168.0.0 - min for 192.168.0.0/16
    func testIsPrivateNetwork192_168_0_0() throws {
        let ipv4: [CChar] = [ 49, 57, 50, 46, 49, 54, 56, 46, 48, 46, 48, 0, 0, 0, 0, 0 ]
        XCTAssertTrue(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 198.168.255.255 - max for 192.168.0.0/16
    func testIsPrivateNetwork192_168_255_255() throws {
        let ipv4: [CChar] = [ 49, 57, 50, 46, 49, 54, 56, 46, 50, 53, 53, 46, 50, 53, 53, 0 ]
        XCTAssertTrue(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 198.169.0.0 - second octet is too high
    func testIsPrivateNetwork192_169_0_0() throws {
        let ipv4: [CChar] = [ 49, 57, 50, 46, 49, 54, 57, 46, 48, 46, 48, 0, 0, 0, 0, 0 ]
        XCTAssertFalse(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 198.169.255.255 - second octet is too high
    func testIsPrivateNetwork192_169_255_255() throws {
        let ipv4: [CChar] = [ 49, 57, 50, 46, 49, 54, 57, 46, 50, 53, 53, 46, 50, 53, 53, 0 ]
        XCTAssertFalse(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 198.167.0.0 - second octet is too low
    func testIsPrivateNetwork192_167_0_0() throws {
        let ipv4: [CChar] = [ 49, 57, 50, 46, 49, 54, 55, 46, 48, 46, 48, 0, 0, 0, 0, 0 ]
        XCTAssertFalse(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 198.167.255.255 - second octet is too low
    func testIsPrivateNetwork192_167_255_255() throws {
        let ipv4: [CChar] = [ 49, 57, 50, 46, 49, 54, 55, 46, 50, 53, 53, 46, 50, 53, 53, 0 ]
        XCTAssertFalse(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 172.16.0.0 - min for 172.16.0.0/12
    func testIsPrivateNetwork172_16_0_0() throws {
        let ipv4: [CChar] = [ 49, 55, 50, 46, 49, 54, 46, 48, 46, 48, 0, 0, 0, 0, 0, 0 ]
        XCTAssertTrue(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 172.31.255.255 - max for 172.16.0.0/12
    func testIsPrivateNetwork172_31_255_255() throws {
        let ipv4: [CChar] = [ 49, 55, 50, 46, 49, 54, 46, 50, 53, 53, 46, 50, 53, 53, 0, 0 ]
        XCTAssertTrue(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 172.15.255.255 - second octet is too low
    func testIsPrivateNetwork172_15_255_255() throws {
        let ipv4: [CChar] = [ 49, 55, 50, 46, 49, 53, 46, 50, 53, 53, 46, 50, 53, 53, 0, 0 ]
        XCTAssertFalse(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 172.30.0.0 - was missed in initial testing
    func testIsPrivateNetwork172_30_0_0() throws {
        let ipv4: [CChar] = [ 49, 55, 50, 46, 51, 48, 46, 48, 46, 48, 0, 0, 0, 0, 0, 0 ]
        XCTAssertTrue(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 172.31.0.0 - was missed in intial testing
    func testIsPrivateNetwork172_31_0_0() throws {
        let ipv4: [CChar] = [ 49, 55, 50, 46, 51, 49, 46, 48, 46, 48, 0, 0, 0, 0, 0, 0 ]
        XCTAssertTrue(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 172.32.0.0 - second octet is too high
    func testIsPrivateNetwork172_32_0_0() throws {
        let ipv4: [CChar] = [ 49, 55, 50, 46, 51, 50, 46, 48, 46, 48, 0, 0, 0, 0, 0, 0 ]
        XCTAssertFalse(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 10.0.0.0 - min for 10.0.0.0/8
    func testIsPrivateNetwork10_0_0_0() throws {
        let ipv4: [CChar] = [ 49, 48, 46, 48, 46, 48, 46, 48, 0, 0, 0, 0, 0, 0, 0, 0 ]
        XCTAssertTrue(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
    
    // 10.255.255.255 - max for 10.0.0.0/8
    func testIsPrivateNetwork10_255_255_255() throws {
        let ipv4: [CChar] = [ 49, 48, 46, 50, 53, 53, 46, 50, 53, 53, 46, 50, 53, 53, 0, 0 ]
        XCTAssertTrue(NetworkTools.isPrivateNetwork(ipv4: ipv4))
    }
}
