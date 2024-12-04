//
//  DataStore.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Foundation

/// Just in case the app wants to store data somewhere other than UserDefaults
public protocol DataStore: Actor {
    func saveString(key: String, value: String) async
    func fetchString(key: String) async -> String?
    func clearString(key: String) async
}

/// In case the app does NOT want to cache values. Likely not a good idea as a few data collection calls are expensive.
actor NullDataStore: DataStore {
    public func saveString(key: String, value: String) async {}
    public func fetchString(key: String) async -> String? { return nil }
    public func clearString(key: String) async {}
}

/// Trivial passthrough to UserDefaults for data storage.
///
/// UserDefaults requires a privacy disclosure!
/// https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api
actor UserDefaultsDataStore: DataStore {
    
    public func saveString(key: String, value: String) async {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    public func fetchString(key: String) async -> String? {
        if let string = UserDefaults.standard.string(forKey: key) {
            return string
        }
        return nil
    }
    
    public func clearString(key: String) async {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
