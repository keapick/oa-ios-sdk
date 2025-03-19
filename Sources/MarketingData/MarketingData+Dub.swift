//
//  MarketingData+Dub.swift
//  MarketingData
//
//  Created by echo on 3/12/25.
//
import Foundation
import Marketing

struct DubEvent: Codable, Sendable {
    
    // Metadata
    let sdkVersion: String
    let requestTimestamp: String
    
    // basic app and device data
    var bundleIdentifier: String?
    var deviceModel: String?
    var osVersion: String?
    var userAgent: String?

    // custom fields set by the developer
    var custom: [String: String]?
    
    init(from deviceSummary: DeviceSummary, custom: [String: String]? = nil) {
        self.sdkVersion = deviceSummary.sdkVersion
        self.requestTimestamp = deviceSummary.requestTimestamp
        
        self.bundleIdentifier = deviceSummary.bundleIdentifier
        self.deviceModel = deviceSummary.utsname?.machine
        self.osVersion = deviceSummary.systemVersion
        self.userAgent = deviceSummary.userAgent
        
        self.custom = custom
    }
}

extension MarketingData {
    
    public func dubEvent(custom: [String: String]? = nil) async -> String? {
        let summary = await summary()
        let event = DubEvent(from: summary, custom: custom)
        
        do {
            let data = try JSONEncoder().encode(event)
            return String(data: data, encoding: .utf8)
        } catch { }
        
        return nil
    }
    
}
