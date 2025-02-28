//
//  EventStore.swift
//  MarketingData
//
//  Created by echo on 2/26/25.
//

import Foundation
import SwiftData

// Stores events in SwiftData
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public struct EventStore: Sendable {
    
    public static let shared = MarketingData()
    
    // For direct access to the ModelContainer, allows SwiftUI Views to use Query
    public let container: ModelContainer
    
    public init() {
        self.container = EventStore.initModelContainer()
    }
    
    static func initModelContainer() -> ModelContainer {
        let schema = Schema([
            Event.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, migrationPlan: nil, configurations: [modelConfiguration])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public func create(_ event: Event) throws {
        let context = ModelContext(container)
        context.insert(event)
        try context.save()
    }
    
    public func delete(_ event: Event) throws {
        let context = ModelContext(container)
        let id = event.persistentModelID
        try context.delete(model: Event.self, where: #Predicate<Event> { event in
            event.persistentModelID == id
        })
        try context.save()
    }
    
    public func fetchAllEvents() throws -> [Event] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Event>(
            sortBy: [
                SortDescriptor(\.timestamp, order: .reverse)
            ]
         )
        return try context.fetch(descriptor)
    }
}
