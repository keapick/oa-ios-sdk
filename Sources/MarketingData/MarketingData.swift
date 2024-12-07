//
//  MarketingData.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Foundation
import Marketing

// By default, do not use IDFA
public final class IDFAMock: IDFASource, Sendable {
    public func readIdentifierForAdvertiser() -> String? {
        return nil
    }
    
    public func readAppTrackingTransparencyOptInStatus() -> String? {
        return nil
    }
}

public struct DeviceSummary: Codable, Sendable {
    // Metadata
    let sdkVersion: String
    let requestTimestamp: String
    
    // App details
    var executableName: String?
    var teamIdentifier: String?
    var bundleIdentifier: String?
    var bundleShortVersion: String?
    var bundleVersion: String?
    var urlSchemes: [URLScheme]?
    var accessGroup: String?
    
    // Device details
    var systemVersion: String?
    var utsname: Utsname?
    var sysctl: Sysctl?
    var userAgent: String?
    var screen: ScreenDimensions?
    
    // Variable device details
    var locale: String?
    var networkPathSummary: NetworkPathSummary?
    var networkInterfaces: [NetworkInterface]?
    var executableCreationDate: String?
    var libraryDirectoryCreationDate: String?
    var encryptedReceipt: AppStoreReceiptData?
    var appleAttributionToken: AttributionToken?
    
    // Identifiers
    var identifierForVendor: String?
    var identiferForAdvertiser: String?
    var trackingAuthorizationStatus: String?
}


/// Generic app and device data often collected for fraud and marketing analysis.
/// This is not an exhaustive list and includes mostly things available to all app types.
///
/// Review AppTrackingTransparency and Privacy Manifest requirements
/// https://developer.apple.com/app-store/user-privacy-and-data-use/
/// https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
/// https://developer.apple.com/documentation/bundleresources/describing-data-use-in-privacy-manifests
/// https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api
///
/// For more detailed Purchase information use StoreKit.
/// https://developer.apple.com/documentation/storekit
///
/// For In app ads attribution use AdAttributionKit. Although not deprecated, SKAdNetwork is limited to the Apple App Store.
/// https://developer.apple.com/documentation/adattributionkit
///
/// For promo code fraud prevention, use DCDevice. It provides 2 bits that are unique to the device managed through Apple.
/// https://developer.apple.com/documentation/devicecheck/dcdevice
///
public final class MarketingData: Sendable {
    
    let networkMonitor = NetworkMonitor.shared
    let idfaSource: IDFASource
    
    public init(idfaSource: IDFASource) {
        self.idfaSource = idfaSource
    }
    
    public init() {
        self.idfaSource = IDFAMock()
    }
    
    // sample JSON typical of an install event
    public func jsonSummary(_ config: Config) async -> String? {
        let summary = await summary(config)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = ([.prettyPrinted, .sortedKeys])
        
        do {
            let data = try encoder.encode(summary)
            if let string = String(data: data, encoding: .utf8) {
                return string
            }
        } catch { }
        
        return nil
    }
    
    // marketing data struct, can be used to generate request JSONs
    public func summary(_ config: Config) async -> DeviceSummary {
        var dataStore: DataStore = NullDataStore()
        
        // UserDefaults requires a privacy disclosure but is helpful in caching expensive or one time calls
        if config.useUserDefaults {
            dataStore = UserDefaultsDataStore()
        }
        
        var summary = DeviceSummary(sdkVersion: "1.0.0", requestTimestamp: String(Date().timeIntervalSince1970))

        if config.includeAppDetails {
            summary.executableName = BundleDataCollector.readExecutableName()
            summary.teamIdentifier = BundleDataCollector.readTeamID()
            summary.bundleIdentifier = BundleDataCollector.readBundleID()
            summary.bundleShortVersion = BundleDataCollector.readBundleShortVersion()
            summary.bundleVersion = BundleDataCollector.readBundleVersion()
            summary.urlSchemes = BundleDataCollector.readURISchemes()
            summary.accessGroup = await AccessGroupCollector().readAccessGroup()
        }
        
        if config.includeDeviceDetails {
            summary.systemVersion = await SystemDataCollector.readSystemVersion()
            summary.utsname = SystemDataCollector.readUtsnameSystemInfo()
            summary.sysctl = SystemDataCollector.readSysctlSystemInfo()
            summary.userAgent = await UserAgentCollector(dataStore: dataStore).readCachedUserAgent()
            summary.screen = await ScreenDimensionCollector().readScreenDimensions()
        }
        
        if config.includeLocale {
            summary.locale = SystemDataCollector.readCurrentLocale()
        }
        
        if config.includeAttributionToken {
            summary.appleAttributionToken = await AttributionTokenCollector(dataStore: dataStore).requestAppleAttributionToken(forceFresh: false)
        }
        
        if config.includeAppleReceipt {
            summary.encryptedReceipt = BundleDataCollector.readAppStoreReceipt()
        }
        
        if config.includeNetworkInformation {
            
            // Network information, filtered for active connections
            // Anything that looks like a public IP address is not collected
            summary.networkPathSummary = self.networkMonitor.readCurrentPathData()
            if let activeInterfaceNames = summary.networkPathSummary?.interfaces.map({ $0.name }) {
                do {
                    let interfaces = try NetworkTools.readNetworkInterfaces()
                    summary.networkInterfaces = interfaces.filter{ activeInterfaceNames.contains($0.name) }
                } catch { }
            }
        }
        
        if config.includeFileCreationDates {
            summary.executableCreationDate = BundleDataCollector.readExecutableCreationDate()
            summary.libraryDirectoryCreationDate = BundleDataCollector.readLibraryDirectoryCreationDate()
        }
        
        if config.includeIDFV {
            summary.identifierForVendor = await SystemDataCollector.readIdentifierForVendor()
        }
        
        // The code to collect IDFA is not included by default.
        // If you want to collect the IDFA, include the MarketingDataIDFA library and pass in the IDFACollector.
        // https://developer.apple.com/app-store/user-privacy-and-data-use/
        summary.identiferForAdvertiser = self.idfaSource.readIdentifierForAdvertiser()
        summary.trackingAuthorizationStatus = self.idfaSource.readAppTrackingTransparencyOptInStatus()

        return summary
    }
    
}
