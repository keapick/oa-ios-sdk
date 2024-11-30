//
//  LoggerSwiftUI.swift
//  Marketing
//
//  Created by echo on 11/24/24.
//

import Foundation

/// Helper class to get Logger to conform to ObservableObject for SwiftUI
/// For in app debug views, not terribly useful outside of test apps.
public final class LoggerSwiftUI: ObservableObject, LogDestination {
    
    // ideally, this would be readonly, but I can't seem to get that to work
    @Published public var text: String = ""
    
    // line limit, makes it easier to read than a character limit
    // this version trades data duplication for simplicity
    public var maxLines = 10
    private var textLines: [String] = []
    
    public init() {
        Logger.shared.destination = self
        Logger.shared.playbackBuffer()
    }
    
    @MainActor
    private func internalHandle(message: String) {
        self.textLines.append(message)
        if self.textLines.count > self.maxLines {
            self.textLines.removeFirst()
        }
        
        self.text = ""
        for line in self.textLines.reversed() {
            self.text.append(line)
            self.text.append("\n")
        }
    }
    
    public func handle(message: String) {
        
    }
    
    @MainActor
    private func internalClear() {
        // UI elements are cleared immediately on main.
        // The backing Logger is scheduled to be cleared on a background queue.
        Logger.shared.clearBuffer()
        self.text.removeAll()
        self.textLines.removeAll()
    }
    
    public func removalAll() {

    }
}
