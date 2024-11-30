//
//  ScreenDimensionCollector.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import UIKit
import Marketing

struct ScreenDimensions: Codable {
    let width: Double
    let height: Double
    let scale: Double
}

/// Reads Screen data
class ScreenDimensionCollector: NSObject {
    
    /// Reads screen data using a deprecated API
    /// https://developer.apple.com/documentation/uikit/uiscreen/1617815-mainscreen
    @MainActor func readScreenDimensions() -> ScreenDimensions {
        
        // TODO: replace this, UIScreen.main is deprecated. Also is this even actually useful?
        let scale = UIScreen.main.scale
        let width = UIScreen.main.bounds.size.width * scale
        let height = UIScreen.main.bounds.size.height * scale
        
        return ScreenDimensions(width: width, height: height, scale: scale)
    }
}
