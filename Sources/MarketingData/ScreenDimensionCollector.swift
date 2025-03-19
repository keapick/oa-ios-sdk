//
//  ScreenDimensionCollector.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//
#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

import Marketing

struct ScreenDimensions: Codable, Sendable {
    let width: Double
    let height: Double
    let scale: Double
}

/// Reads Screen data
class ScreenDimensionCollector {
    
    /// Reads screen data using a deprecated API
    /// https://developer.apple.com/documentation/uikit/uiscreen/1617815-mainscreen
    @MainActor func readScreenDimensions() -> ScreenDimensions {
        
        var scale = 0.0
        var width = 0.0
        var height = 0.0
        
        #if canImport(UIKit)
        scale = UIScreen.main.scale
        width = UIScreen.main.bounds.size.width * scale
        height = UIScreen.main.bounds.size.height * scale
        #endif
        
        #if canImport(AppKit)
        // TODO: do we even want screen dimensions?
        #endif
        
        return ScreenDimensions(width: width, height: height, scale: scale)
    }
}
