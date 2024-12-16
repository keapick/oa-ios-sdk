//
//  IDFASource.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Foundation

// Used to dependency inject IDFA and AppTrackingTransparency
public protocol IDFASource: Sendable {
    func readIdentifierForAdvertiser() -> String?
    func readAppTrackingTransparencyOptInStatus() -> String?
}
