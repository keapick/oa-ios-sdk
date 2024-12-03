//
//  MarketingDataTests.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Testing
@testable import Marketing
@testable import MarketingData

struct MarketingDataTests {
    
    /*
     
     {
       "accessGroup": "",
       "bundleIdentifier": "com.apple.dt.xctest.tool",
       "bundleShortVersion": "16.0",
       "bundleVersion": "23504",
       "creationTimestamp": 754001059.466992,
       "executableName": "xctest",
       "locale": "en_US",
       "screen": {
         "height": 2868,
         "scale": 3,
         "width": 1320
       },
       "sdkVersion": "1.0.0",
       "sysctl": {
         "cpusubtype": 2,
         "cputype": 16777228,
         "machine": "arm64",
         "model": "Mac15,6",
         "osversion": "24B91"
       },
       "systemVersion": "18.0",
       "urlSchemes": [],
       "userAgent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
       "utsname": {
         "machine": "arm64",
         "nodename": "nephrite.local",
         "release": "24.1.0",
         "sysname": "Darwin",
         "version": "Darwin Kernel Version 24.1.0: Thu Oct 10 21:00:32 PDT 2024; root:xnu-11215.41.3~2/RELEASE_ARM64_T6030"
       }
     }
     
     */
    @Test func jsonPrivacy() async throws {
        if let string = await MarketingData().jsonSummary(Config(version: "1.0.0")) {
            print("\(string)")
            
            // metadata
            #expect(string.contains("sdkVersion"))
            #expect(string.contains("creationTimestamp"))
            
            // default included
            #expect(string.contains("bundleIdentifier"))
            #expect(string.contains("utsname"))
            
            // optional values that should be excluded
            #expect(!string.contains("identifierForVendor"))
            #expect(!string.contains("networkPathSummary"))
        }
    }

    /*
     
     {
       "creationTimestamp": 754001279.117536,
       "sdkVersion": "1.0.0"
     }
     
     */
    @Test func jsonPrivacyAllDisabled() async throws {
        if let string = await MarketingData().jsonSummary(Config.configAllDataCollectionDisabled()) {
            print("\(string)")
            
            // metadata
            #expect(string.contains("sdkVersion"))
            #expect(string.contains("creationTimestamp"))
            
            // default values that should be excluded
            #expect(!string.contains("bundleIdentifier"))
            #expect(!string.contains("utsname"))
            
            // optional values that should be excluded
            #expect(!string.contains("identifierForVendor"))
            #expect(!string.contains("networkPathSummary"))
        }
    }
    
    /*
     
     {
       "accessGroup": "",
       "bundleIdentifier": "com.apple.dt.xctest.tool",
       "bundleShortVersion": "16.0",
       "bundleVersion": "23504",
       "creationTimestamp": 754001328.073057,
       "executableCreationDate": "1728054820.0",
       "executableName": "xctest",
       "identifierForVendor": "79905CB6-1E31-49DE-A3F2-CF992F69F66C",
       "libraryDirectoryCreationDate": "1724414300.0",
       "locale": "en_US",
       "networkInterfaces": [
         {
           "address": "::fd44:966d:b34e:1:100:0",
           "name": "en0",
           "type": "ipv6"
         },
         {
           "address": "192.168.5.231",
           "name": "en0",
           "type": "ipv4"
         }
       ],
       "networkPathSummary": {
         "interfaces": [
           {
             "name": "en0",
             "type": "wifi"
           }
         ],
         "status": "satisfied"
       },
       "screen": {
         "height": 2868,
         "scale": 3,
         "width": 1320
       },
       "sdkVersion": "1.0.0",
       "sysctl": {
         "cpusubtype": 2,
         "cputype": 16777228,
         "machine": "arm64",
         "model": "Mac15,6",
         "osversion": "24B91"
       },
       "systemVersion": "18.0",
       "urlSchemes": [],
       "userAgent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
       "utsname": {
         "machine": "arm64",
         "nodename": "nephrite.local",
         "release": "24.1.0",
         "sysname": "Darwin",
         "version": "Darwin Kernel Version 24.1.0: Thu Oct 10 21:00:32 PDT 2024; root:xnu-11215.41.3~2/RELEASE_ARM64_T6030"
       }
     }
     
     */
    @Test func jsonPrivacyAllEnabled() async throws {
        // Slow in unit tests as the attribution token goes through all retries, takes 15s
        if let string = await MarketingData().jsonSummary(Config.configAllDataCollectionEnabled()) {
            print("\(string)")
            
            // metadata
            #expect(string.contains("sdkVersion"))
            #expect(string.contains("creationTimestamp"))
            
            // default included
            #expect(string.contains("bundleIdentifier"))
            #expect(string.contains("utsname"))
            
            // optional values that should be included
            #expect(string.contains("identifierForVendor"))
            #expect(string.contains("networkPathSummary"))
        }
    }
}
