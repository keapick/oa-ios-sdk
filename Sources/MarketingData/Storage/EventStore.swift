//
//  File.swift
//  MarketingData
//
//  Created by echo on 2/26/25.
//

import Foundation
import SwiftData

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public struct EventStore: Sendable {
    
    public static let shared = MarketingData()
    
    // For direct access to the ModelContainer, allows SwiftUI Views to use Query
    public let container: ModelContainer
    
    public init() {
        self.container =
    }
    
    static func initModelContainer() -> ModelContainer {
        let schema = Schema([
            Event.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, migrationPlan: EventMigrationPlan.self, configurations: [modelConfiguration])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
