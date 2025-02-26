//
//  MarketingObjC.swift
//  oa-ios-sdk
//
//  Created by echo on 2/25/25.
//

import Foundation

// Singleton used by ObjC to access a minimal subset of the Swift SDK features.
@objcMembers public class MarketingObjC: NSObject {
    
    @objc nonisolated(unsafe) public static let shared: MarketingObjC = MarketingObjC()
    
    // debug messages
    @objc public func log(message: NSString) {
        if let string: String = message as String? {
            Logger.shared.logDebug(message: string)
        }
    }
}
