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
    
    // Have to duplicate these utility functions...
    // ConfigTests are in a different target.
    static func configAllDataCollectionDisabled() -> Config {
        var rules = Config()
        rules.useUserDefaults = false
        rules.includeAppDetails = false
        rules.includeDeviceDetails = false
        rules.includeLocale = false
        rules.includeAttributionToken = false
        rules.includeAppleReceipt = false
        rules.includeNetworkInformation = false
        rules.includeFileCreationDates = false
        rules.includeIDFV = false
        return rules
    }
    
    static func configAllDataCollectionEnabled() -> Config {
        var rules = Config()
        rules.useUserDefaults = true
        rules.includeAppDetails = true
        rules.includeDeviceDetails = true
        rules.includeLocale = true
        // lets exclude this as it's slow on unit tests
        rules.includeAttributionToken = false
        rules.includeAppleReceipt = true
        rules.includeNetworkInformation = true
        rules.includeFileCreationDates = true
        rules.includeIDFV = true
        return rules
    }
    
    /*
     
     {
       "accessGroup": "",
       "bundleIdentifier": "com.apple.dt.xctest.tool",
       "bundleShortVersion": "16.0",
       "bundleVersion": "23504",
       "requestTimestamp": 754001059.466992,
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
        if let string = await MarketingData().jsonSummary(Config()) {
            print("\(string)")
            
            // metadata
            #expect(string.contains("sdkVersion"))
            #expect(string.contains("requestTimestamp"))
            
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
       "requestTimestamp": 754001279.117536,
       "sdkVersion": "1.0.0"
     }
     
     */
    @Test func jsonPrivacyAllDisabled() async throws {
        if let string = await MarketingData().jsonSummary(MarketingDataTests.configAllDataCollectionDisabled()) {
            print("\(string)")
            
            // metadata
            #expect(string.contains("sdkVersion"))
            #expect(string.contains("requestTimestamp"))
            
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
       "requestTimestamp": 754001328.073057,
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
        if let string = await MarketingData().jsonSummary(MarketingDataTests.configAllDataCollectionEnabled()) {
            print("\(string)")
            
            // metadata
            #expect(string.contains("sdkVersion"))
            #expect(string.contains("requestTimestamp"))
            
            // default included
            #expect(string.contains("bundleIdentifier"))
            #expect(string.contains("utsname"))
            
            // optional values that should be included
            #expect(string.contains("identifierForVendor"))
            #expect(string.contains("networkPathSummary"))
        }
    }
}
