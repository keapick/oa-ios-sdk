//
//  MarketingDataDubTests.swift
//  MarketingData
//
//  Created by echo on 3/18/25.
//

import Testing
@testable import MarketingData

struct MarketingDataDubTests {

    @Test func helloWorld() async throws {
        let config = MarketingDataTests.configAllDataCollectionEnabled()
        let marketingData = MarketingData(config)
        
        if let json = await marketingData.dubEvent(custom: ["hello": "world"]) {
            print("\(json)")
        }
    }

}
