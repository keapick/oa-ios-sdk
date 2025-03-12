//
//  Event.swift
//  MarketingData
//
//  Created by echo on 12/14/24.
//

import Foundation
import SwiftData

// Apple hasn't made this Swift 6 compatible yet
// https://developer.apple.com/forums/thread/756802
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
extension MigrationStage: @unchecked @retroactive Sendable { }

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
extension Schema.Version: @unchecked @retroactive Sendable { }

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public typealias Event = EventVersionSchemaV1.Event

// Sample migration code, easier to setup up front than to retrofit it
//@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
//enum EventMigrationPlan: SchemaMigrationPlan {
//    static var schemas: [any VersionedSchema.Type] {
//        [EventVersionSchemaV1.self, EventVersionSchemaV2.self]
//    }
//    
//    static var stages: [MigrationStage] {
//        [migrateV1toV2]
//    }
//    
//    static let migrateV1toV2 = MigrationStage.custom(
//        fromVersion: EventVersionSchemaV1.self,
//        toVersion: EventVersionSchemaV2.self,
//        willMigrate: nil,
//        didMigrate: { context in
//            
//        }
//    )
//}
//
//@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
//public enum EventVersionSchemaV2: VersionedSchema {
//    public static var versionIdentifier: Schema.Version {
//        return Schema.Version(2, 0, 0)
//    }
//    
//    public static var models: [any PersistentModel.Type] {
//        [Event.self]
//    }
//    
//    @Model
//    public final class Event {
//        @Attribute(.unique) public var id: UUID
//        
//        public init() {
//
//        }
//    }
//}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
public enum EventVersionSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version {
        return Schema.Version(1, 0, 0)
    }
    
    public static var models: [any PersistentModel.Type] {
        [Event.self]
    }
    
    @Model
    public final class Event {
        @Attribute(.unique) public var key: UUID

        // local event timestamp
        @Attribute public var timestamp: Double
        
        // saved to server?
        @Attribute public var synced: Bool = false
        
        public init() {
            self.key = UUID()
            self.timestamp = Date.now.timeIntervalSince1970
        }
    }
}
