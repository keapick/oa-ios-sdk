//
//  AccessGroupCollector.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Foundation
import Marketing

/// AccessGroup is a the team id + bundle id.
/// In older apps, the team id might be in the `Info.plist`, these days it's not populated there by default.
actor AccessGroupCollector {
    
    let service = "com.ieesizaq.accessgroup"
    let key = "dummy"

    /// The security access group string is prefixed with the Apple Developer Team ID
    func readAccessGroup() async -> String? {
        if let accessGroup = Keychain.readAccessGroupFromKeychain(service: service) {
            return accessGroup
        } else {
            
            // accessGroup does not return if the keychain is empty, add a dummy value
            let dummy = String(Date().timeIntervalSince1970)
            Keychain.deleteFromKeychain(service: service, key: key)
            Keychain.saveStringToKeychain(string: dummy, service: service, key: key)
            
            if let accessGroup = Keychain.readAccessGroupFromKeychain(service: service) {
                
                // cleanup so the user doesn't see this dummy value in the keychain
                Keychain.deleteFromKeychain(service: service, key: key)
                return accessGroup
            }
        }
        
        Logger.shared.logWarning(message: "Failed to read access group")
        return nil
    }
    
    
}
