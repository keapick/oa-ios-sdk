//
//  File.swift
//  oa-ios-sdk
//
//  Created by echo on 12/14/24.
//

import Foundation
import SwiftData

//enum EventMigrationPlan: SchemaMigrationPlan {
//    
//    
//    static var schemas: [any VersionedSchema.Type] {
//        [ServerVersionSchemaV1.self, ServerVersionSchemaV2.self]
//    }
//}

//@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
//public enum EventVersionSchemaV1: VersionedSchema {
//    public static var versionIdentifier: Schema.Version {
//        return Schema.Version(1, 0, 0)
//    }
//    
//    public static var models: [any PersistentModel.Type] {
//        [Server.self]
//    }
//    
//    @Model
//    public final class Server {
//        @Attribute(.unique) public var macAddress: String
//        public var name: String
//        
//        // sort by most recently accessed
//        public var lastUsed: Date?
//        
//        public init(macAddress: String, name: String) {
//            self.macAddress = macAddress
//            self.name = name
//        }
//    }
//}
