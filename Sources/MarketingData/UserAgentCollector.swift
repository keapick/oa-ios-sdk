//
//  UserAgentCollector.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Foundation
#if !os(tvOS)
import WebKit
#endif
import Marketing

/// Reads userAgent string from WKWebView, this should match what Safari reports.
/// https://developer.apple.com/documentation/webkit/wkwebview
@MainActor
class UserAgentCollector {

    #if !os(tvOS)
    lazy var webkit: WKWebView = WKWebView(frame: CGRect.zero)
    #endif
    
    let dataStore: DataStore
    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    /// Fetching the user agent is a rather expensive call, therefore cache the result. It only changes with OS updates.
    func readCachedUserAgent() async -> String? {
        let buildVersionKey = "dev.openattribution.osversion"
        let userAgentStringKey = "dev.openattribution.userAgentString"
        
        let currentBuildVersion = SystemDataCollector.readSysctlSystemInfo().osversion
        let savedBuildVersion = await dataStore.fetchString(key: buildVersionKey)
        
        // Use saved user agent if it's still valid
        if let userAgentString = await dataStore.fetchString(key: userAgentStringKey) {
            if currentBuildVersion == savedBuildVersion {
                Logger.shared.logVerbose(message: "Using cached user agent string")
                return userAgentString
            }
        }
        
        // Otherwise fetch a fresh user agent
        if let currentUserAgentString = self.readUserAgentFromWebViewViaKVO() {
            await dataStore.saveString(key: buildVersionKey, value: currentBuildVersion)
            await dataStore.saveString(key: userAgentStringKey, value: currentUserAgentString)
            
            Logger.shared.logVerbose(message: "Using fresh user agent string")
            return currentUserAgentString
        } else {
            return nil
        }
    }
    
    /// Uses KVO to check the userAgent private field
    func readUserAgentFromWebViewViaKVO() -> String? {
        #if !os(tvOS)
        if let agent = self.webkit.value(forKey: "userAgent") as? String {
            return agent
        }
        #endif
        return nil
    }
    
    /// Executes a bit of JS to get the userAgent
    func readUserAgentFromWebViewViaJS() async -> String? {
        #if !os(tvOS)
        do {
            if let agent = try await self.webkit.evaluateJavaScript("navigator.userAgent") as? String {
                return agent
            }
        } catch {
            Logger.shared.logDebug(message: "Failed to request userAgent via JS")
        }
        #endif
        return nil
    }
}
