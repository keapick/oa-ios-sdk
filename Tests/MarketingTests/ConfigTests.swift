//
//  ConfigTests.swift
//  MarketingTests
//
//  Created by echo on 11/24/24.
//

import Testing
import Foundation

@testable import Marketing

struct ConfigTests {
    
    // In unit tests, the bundle is the one associated with the module
    func urlForConfig(named: String = "config") -> URL? {
        if let url = Bundle.module.url(forResource: named, withExtension: "json") {
            return url
        }
        return nil
    }
    
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
    
    @Test func testURLForConfig() async throws {
        let url = urlForConfig()
        #expect(url != nil)
    }
    
    @Test func testLoadConfig() async throws {
        if let url = urlForConfig() {
            let config = Config()
            let loaded = Config.loadConfig(from: url)
            
            #expect(config == loaded)
        } else {
            Issue.record("Could not find config URL")
        }
    }
    
    @Test func testConfigLoggingVerbose() async throws {
        if let url = urlForConfig(named: "config_log_level"), let config = Config.loadConfig(from: url) {
            #expect(config.logLevel == .verbose)
        } else {
            Issue.record("Could not find config URL")
        }
    }
    
    @Test func testLoadPrivacyRules() async throws {
        if let url = urlForConfig() {
            let rules = Config()
            let loaded = Config.loadConfig(from: url)
            
            #expect(loaded == rules)
        } else {
            Issue.record("Could not find config URL")
        }
    }
    
    @Test func testConfigDataDisabled() async throws {
        if let url = urlForConfig(named: "config_data_disabled") {
            let rules = ConfigTests.configAllDataCollectionDisabled()
            let loaded = Config.loadConfig(from: url)
            
            #expect(loaded == rules)
        } else {
            Issue.record("Could not find config URL")
        }
    }
    
    @Test func testConfigDataEnabled() async throws {
        if let url = urlForConfig(named: "config_data_enabled") {
            let rules = ConfigTests.configAllDataCollectionEnabled()
            let loaded = Config.loadConfig(from: url)
            
            #expect(loaded == rules)
        } else {
            Issue.record("Could not find config URL")
        }
    }
    
    @Test func testConfigExtraFields() async throws {
        if let url = urlForConfig(named: "config_unsupported_fields") {
            let rules = Config()
            let loaded = Config.loadConfig(from: url)
            
            #expect(loaded == rules)
        } else {
            Issue.record("Could not find config URL")
        }
    }
}
