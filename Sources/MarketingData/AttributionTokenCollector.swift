//
//  AttributionTokenCollector.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Foundation

#if !os(tvOS)
import AdServices
#endif

import Marketing

struct AttributionToken: Codable, Sendable {
    let token: String
    let collectionTimestamp: String
}

@MainActor
class AttributionTokenCollector {
        
    /// Apple recommends trying up to 3 times with a 5s retry interval
    let maxTries = 3
    let retryInterval = 5.0
    let appleTokenKey = "dev.openattribution.appleToken"
    let appleTokenTimeStampKey = "dev.openattribution.appleTokenTimeStamp"
    
    let keyValueStore: KeyValueStore
    init(keyValueStore: KeyValueStore) {
        self.keyValueStore = keyValueStore
    }
    
    /// Requests an Apple Attribution token for S2S integration.
    /// By default, this is only fetched once and cached. If your S2S service could not consume it in time you may need to request another.
    /// https://developer.apple.com/documentation/AdServices/
    ///
    /// With retries, fetching a new Apple attribution token  can take upwards of 15s, normally it's much faster.
    func requestAppleAttributionToken(forceFresh: Bool) async -> AttributionToken? {
        if forceFresh != true,
           let token = await keyValueStore.fetchString(key: self.appleTokenKey),
           let timestamp = await keyValueStore.fetchString(key: self.appleTokenTimeStampKey) {
            
            Logger.shared.logVerbose(message: "Using previously cached Apple attribution token.")
            return AttributionToken(token: token, collectionTimestamp: timestamp)
            
        } else {
            
            var attemptCount = 0
            while attemptCount < self.maxTries {
                
                if let token = self.requestToken() {
                    Logger.shared.logVerbose(message: "Using fresh Apple attribution token.")

                    let timestamp = String(Date().timeIntervalSince1970)
                    await keyValueStore.saveString(key: self.appleTokenKey, value: token)
                    await keyValueStore.saveString(key: self.appleTokenTimeStampKey, value: timestamp)
                    return AttributionToken(token: token, collectionTimestamp: timestamp)
                }
                attemptCount += 1
                
                do {
                    // Remember Task.sleep does not block like Thread.sleep does
                    try await Task.sleep(nanoseconds: UInt64(self.retryInterval * 1_000_000_000))
                } catch { }
            }
        }
        
        Logger.shared.logVerbose(message: "No Apple attribution token available.")
        return nil
    }
    
    /// Reads apple attribution token for Apple Search Ads attribution. This API is always allowed.
    /// https://developer.apple.com/documentation/adservices/aaattribution/attributiontoken()
    func requestToken() -> String? {
        #if !os(tvOS)
        do {
            let token = try AAAttribution.attributionToken()
            return token;
        } catch {
            Logger.shared.logDebug(message: "No Apple attribution token found.")
        }
        #endif
        return nil
    }
}
