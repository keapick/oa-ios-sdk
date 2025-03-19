//
//  BundleDataCollector.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Foundation
import Marketing

struct AppStoreReceiptData: Codable, Sendable {
    let receipt: String
    let isSandboxReceipt: Bool
}

struct URLScheme: Codable, Sendable {
    let type: String
    let schemes: [String]
    
    init?(dict: [String: Any]) {
        guard let type = dict["CFBundleTypeRole"] as? String,
              let schemes = dict["CFBundleURLSchemes"] as? [String]
        else {
            return nil
        }
        
        // omits optional icon and name
        self.type = type
        self.schemes = schemes
    }
}

/// Reads general app data from the main Bundle
/// Most are shared across all users of an app version.
struct BundleDataCollector {
    
    /// Reads main bundleIdentifier
    /// https://developer.apple.com/documentation/foundation/nsbundle/1418023-bundleidentifier
    static func readBundleID() -> String? {
        if let bundleId = Bundle.main.bundleIdentifier {
            return bundleId
        }
        
        Logger.shared.logWarning(message: "No main bundleIdentifier found.")
        return nil
    }
    
    /// Read Team Identifier
    /// Not added to the Info.plist by default.
    ///
    /// Add the following snippet to the Info.plist
    /// ```xml
    /// <key>AppIdentifierPrefix</key>
    /// <string>$(AppIdentifierPrefix)</string>
    /// ```
    static func readTeamID() -> String? {
        if let appIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as? String {
            return appIdentifierPrefix
        }
        
        Logger.shared.logVerbose(message: "No AppIdentifierPrefix found in main Bundle. This no longer added to the Info.plist by default.")
        return nil
    }
    
    /// Read app version
    /// https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleshortversionstring
    static func readBundleShortVersion() -> String? {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return nil
    }
    
    /// Read app build number
    /// https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleversion
    static func readBundleVersion() -> String? {
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return version
        }
        return nil
    }
    
    /// Reads URI schemes
    /// https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleurltypes
    static func readURISchemes() -> [URLScheme] {
        var schemeList = [URLScheme]()
        
        // urlTypes is a list of Dictionaries
        if let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [Any] {
            for urlType in urlTypes {
                // Each urlType is a Dictionary containing at least the type and a list of URI schemes
                if let dict = urlType as? [String: Any] {
                    if let data = URLScheme(dict: dict) {
                        schemeList.append(data)
                    }
                }
            }
        }
        return schemeList
    }
    
    /// Reads executable name
    /// https://developer.apple.com/documentation/corefoundation/kcfbundleexecutablekey
    static func readExecutableName() -> String? {
        if let executableName = Bundle.main.object(forInfoDictionaryKey: kCFBundleExecutableKey as String) as? String {
            return executableName
        }
        
        Logger.shared.logDebug(message: "Unable to read executable name from main Bundle")
        return nil
    }
    
    /// Reads executable creation date, this can be  a proxy for build date. This value changes with each app update.
    ///
    /// NOT user specific, but checking file timestamps requires disclosure.
    /// https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api
    static func readExecutableCreationDate() -> String? {
        guard let executableName = self.readExecutableName() else {
            return nil
        }
        
        let url = Bundle.main.bundleURL.appendingPathComponent(executableName)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let creation = attributes[.creationDate] as? Date {
                return String(creation.timeIntervalSince1970)
            }
        } catch {
            Logger.shared.logDebug(message: "Unable to read executable creation date.")
        }
        return nil
    }
    
    /// Reads library directory creation date. This is roughly the app installation date and persists through app upgrades.
    /// Note this does not account for app backups, reinstalls, or the "Offload Unused Apps" feature
    ///
    /// User specific and requires disclosure.
    /// https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api
    static func readLibraryDirectoryCreationDate() -> String? {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                
                if let creation = attributes[.creationDate] as? Date {
                    return String(creation.timeIntervalSince1970)
                }
            } catch {
                Logger.shared.logDebug(message: "Unable to read library directory creation date.")
            }
        } else {
            Logger.shared.logDebug(message: "Unable to read library directory url.")
        }
        return nil
    }
    
    /// Reads encrypted App Store Receipt
    /// https://developer.apple.com/documentation/foundation/nsbundle/1407276-appstorereceipturl
    ///
    /// User specific and requires disclosure.
    /// https://developer.apple.com/documentation/bundleresources/describing-data-use-in-privacy-manifests
    static func readAppStoreReceipt() -> AppStoreReceiptData? {
        var receipt: String?
        var isSandboxReceipt = false
        
        if let url = Bundle.main.appStoreReceiptURL {
            
            // Test or Testflight receipts
            if (url.lastPathComponent == "sandboxReceipt") {
                isSandboxReceipt = true
            }
            
            do {
                let data = try Data(contentsOf: url)
                receipt = data.base64EncodedString()
            } catch {
                Logger.shared.logWarning(message: "No App Store receipt found. This is expected in apps that are not installed from the Apple App Store.")
            }
            
        } else {
            Logger.shared.logWarning(message: "No App Store receipt URL found. This is expected on unhosted unit tests.")
        }
        
        if let receipt {
            return AppStoreReceiptData(receipt: receipt, isSandboxReceipt: isSandboxReceipt)
        }
        return nil
    }
    
}
