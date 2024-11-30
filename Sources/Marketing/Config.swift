//
//  Config.swift
//  Marketing
//
//  Created by echo on 11/24/24.
//

import Foundation

/*
 * JSONEncoder and JSONDecoder do not honor the default values in a Codable.
 * If fields are required, then they must be present in the JSON. This leads to unnecessarily strict and verbose JSON.
 * If fields are optional, then there will be extraneous boilerplate code to deal with nullable fields.
 *
 * Workaround using a DTO with all optional fields. Another option is to implement your own Decodable methods.
 */
struct ConfigDTO: Codable, Equatable {
    let version: String
    var logLevel: LogLevel?
    
    var useUserDefaults: Bool?
    var includeAppDetails: Bool?
    var includeDeviceDetails: Bool?
    var includeLocale: Bool?
    var includeAttributionToken: Bool?
    var includeAppleReceipt: Bool?
    var includeNetworkInformation: Bool?
    var includeFileCreationDates: Bool?
    var includeIDFV: Bool?
}

// JSON config file to control behavior of this library
// Helpful when supporting platforms such as React Native, Unity or handling early lifecycle events
public struct Config: Equatable {
        
    public let version: String
    public var logLevel: LogLevel = .debug
    
    // UserDefaults requires a privacy disclosure but is helpful in caching expensive or one time data.
    // 1. Getting the user agent from WebKit is expensive and only changes on OS updates
    // 2. Attribution Token should only be collected and consumed on install
    public var useUserDefaults: Bool = true
    
    // App information shared across all users of an app version
    public var includeAppDetails: Bool = true
    
    // Device information shared across all users of a device model
    public var includeDeviceDetails: Bool = true
    
    // User locale setting
    // Low specificity, since most users in a region have the same value
    public var includeLocale: Bool = true
    
    // Apple Attribution token, this should consumed once on install and never checked again
    public var includeAttributionToken: Bool = false
    
    // Apps installed from the Apple App Store contain an encrypted receipt that can be used for fraud analysis
    // Purchase information requires disclosure
    public var includeAppleReceipt: Bool = false
    
    // Network connection information
    // Potentially high specificity, may require disclosure
    public var includeNetworkInformation: Bool = false
    
    // File creation dates can proxy for build date and install date
    // Can be used to avoid costly ads attribution callouts on known old installs
    // High specificity, requires disclosure
    public var includeFileCreationDates: Bool = false
    
    // ID for Vendor, consistent across apps from the same vendor
    // Requires disclosure
    public var includeIDFV: Bool = false
    
    // Note that IDFA is a build time option.
    // This is because Apple has strict rules around it and many apps can't even link it.
    
    init(version: String) {
        self.version = version
    }
    
    init(from dto: ConfigDTO) {
        self.version = dto.version
        
        if let logLevel = dto.logLevel {
            self.logLevel = logLevel
        }
        
        
        // Privacy rules
        if let useUserDefaults = dto.useUserDefaults {
            self.useUserDefaults = useUserDefaults
        }
        if let includeAppDetails = dto.includeAppDetails {
            self.includeAppDetails = includeAppDetails
        }
        if let includeDeviceDetails = dto.includeDeviceDetails {
            self.includeDeviceDetails = includeDeviceDetails
        }
        if let includeLocale = dto.includeLocale {
            self.includeLocale = includeLocale
        }
        if let includeAttributionToken = dto.includeAttributionToken {
            self.includeAttributionToken = includeAttributionToken
        }
        if let includeAppleReceipt = dto.includeAppleReceipt {
            self.includeAppleReceipt = includeAppleReceipt
        }
        if let includeNetworkInformation = dto.includeNetworkInformation {
            self.includeNetworkInformation = includeNetworkInformation
        }
        if let includeFileCreationDates = dto.includeFileCreationDates {
            self.includeFileCreationDates = includeFileCreationDates
        }
        if let includeIDFV = dto.includeIDFV {
            self.includeIDFV = includeIDFV
        }
    }

    // TODO: cache the default config?
    public static func defaultConfig() -> Config {
        if let url = Bundle.main.url(forResource: "config", withExtension: "json") {
            if let config = loadConfig(from: url) {
                return config
            }
        }
        return Config(version: "1.0.0")
    }
    
    // for integration testing
    public static func configAllDataCollectionDisabled() -> Config {
        var rules = Config(version: "1.0.0")
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
    
    // for integration testing
    public static func configAllDataCollectionEnabled() -> Config {
        var rules = Config(version: "1.0.0")
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
    
    // unit tests do not store resources in the main bundle, use the module bundle instead
    static func loadConfig(from fileURL: URL) -> Config? {
        do {
            let data = try Data(contentsOf: fileURL)
            let dto = try JSONDecoder().decode(ConfigDTO.self, from: data)
            return Config(from: dto)
        } catch {
            Logger.shared.logError(message:"Failed to load config: \(error)")
        }
        return nil
    }
}
