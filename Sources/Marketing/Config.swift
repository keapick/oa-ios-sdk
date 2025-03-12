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
    
    var openAttributionService: String?
    var openAttributionPublishableKey: String?
    
    var dubLinkService: String?
    var dubPublishableKey: String?
    var dubSupportedDomains: [String]?
}

// JSON config file to control behavior of this library
// Helpful when supporting platforms such as React Native, Unity or handling early lifecycle events
public struct Config: Equatable, Sendable {
        
    public let version: String
    public var logLevel: LogLevel = .debug
    
    // UserDefaults requires a privacy disclosure but is helpful in caching expensive or one time data.
    // 1. Getting the user agent from WebKit is expensive and only changes on OS updates
    // 2. Apple Attribution Token should only be collected and consumed on install
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
    // Potentially high specificity, requires disclosure
    public var includeFileCreationDates: Bool = false
    
    // ID for Vendor, consistent across apps from the same vendor
    // Requires disclosure
    public var includeIDFV: Bool = false
    
    // Note that IDFA is a build time option.
    // This is because Apple has strict rules around it and many apps can't even link it.
    
    // open attribution configuration
    // https://openattribution.dev/
    public var openAttributionService: String?
    public var openAttributionPublishableKey: String?
    
    // dub.co configuration
    // https://dub.co
    public var dubLinkService: String?
    public var dubPublishableKey: String?
    public var dubSupportedDomains: [String] = []
    
    public init(version: String) {
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
        
        // open attribution config
        self.openAttributionService = dto.openAttributionService
        self.openAttributionPublishableKey = dto.openAttributionPublishableKey
        
        // dub.co config
        self.dubLinkService = dto.dubLinkService
        self.dubPublishableKey = dto.dubPublishableKey
        self.dubSupportedDomains = dto.dubSupportedDomains ?? []
    }

    // Default config file. Assumed to be "config.json" in the main bundle
    public static let shared = Config.defaultConfig()
    static func defaultConfig() -> Config {
        if let url = Bundle.main.url(forResource: "config", withExtension: "json") {
            if let config = loadConfig(from: url) {
                return config
            }
        }
        return Config(version: "1.0.0")
    }
    
    // Loads the config from a URL
    public static func loadConfig(from fileURL: URL) -> Config? {
        do {
            let data = try Data(contentsOf: fileURL)
            let dto = try JSONDecoder().decode(ConfigDTO.self, from: data)
            return Config(from: dto)
        } catch {
            // Cannot use the logger prior to the logger initializing
            print("Failed to load config file: \(error)")
        }
        return nil
    }
}
