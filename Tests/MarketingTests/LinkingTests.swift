//
//  LinkingTests.swift
//  MarketingTests
//
//  Created by echo on 11/24/24.
//

import XCTest
import Compression
@testable import Marketing

struct Book: Codable, Equatable {
    let title: String
    let text: String
}

final class LinkingTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func loadFile(name: String, fileExtension: String) -> String? {
        if let url = Bundle.module.url(forResource: name, withExtension: fileExtension) {
            do {
                let string = try String(contentsOf: url, encoding: .utf8)
                return string
            } catch {
                print("Failed to read \(name).\(fileExtension)")
            }
        }
        return nil
    }

    func loadLoremText() -> String? {
        return self.loadFile(name: "compression_lorem", fileExtension: "txt")
    }
    
    func loadAmbroseText() -> String? {
        return self.loadFile(name: "compression_ambrose", fileExtension: "txt")
    }
    
    func loadCompressedAmbroseText() -> String? {
        if var compressed = self.loadFile(name: "compressed_ambrose", fileExtension: "txt") {
            compressed.removeLast()
            return compressed
        }
        return nil
    }
    
    func testCreateLinkWithParams() throws {
        guard let baseURL = URL(string:"https://ieesizaq.com/") else {
            XCTFail()
            return
        }
        
        let url = try Linking.createLink(baseURL: baseURL, route:["e", "resource"], queryParameters: ["number":"12345"])
        let expected = "https://ieesizaq.com/e/resource?number=12345"
        let actual = url.absoluteString
        
        XCTAssertTrue(actual == expected)
    }
    
    func testReadQueryParameter() throws {
        guard let baseURL = URL(string:"https://ieesizaq.com/") else {
            XCTFail()
            return
        }
        
        let url = try Linking.createLink(baseURL: baseURL, route:["e", "resource"], queryParameters: ["number":"12345", "letter":"abcde"])
        guard let param = Linking.readQueryParameter(name: "number", url: url) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(param == "12345");
    }
    
    func testReadQueryParameter_WrongName() throws {
        guard let baseURL = URL(string:"https://ieesizaq.com/") else {
            XCTFail()
            return
        }
        
        let url = try Linking.createLink(baseURL: baseURL, route:["e", "resource"], queryParameters: ["number":"12345"])
        if let _ = Linking.readQueryParameter(name: "letter", url: url) {
            XCTFail()
            return
        }
    }
    
    func testStringFromCodable() throws {
        let expected = "{\"text\":\"Hello World!\",\"title\":\"title\"}"
        
        let codable = Book(title: "title", text: "Hello World!")
        let actual = try Linking.stringFrom(codable: codable)
        
        XCTAssertTrue(actual == expected)
    }
    
    func testCodableFromString() throws {
        let expected = Book(title: "title", text: "Hello World!")
        
        let string = "{\"text\":\"Hello World!\",\"title\":\"title\"}"
        let actual = try Linking.codableFrom(string: string, type: Book.self)
        
        XCTAssertTrue(actual == expected)
    }
    
    func testCompressedStringFromCodable_SmallCodable() throws {
        let expected = "{\"text\":\"Hello World!\",\"title\":\"title\"}"
        
        let codable = Book(title: "title", text: "Hello World!")
        let (actual, size) = try Linking.compressedStringFrom(codable: codable)
        
        // the codable is small, so it will fallback to a non-compressed string
        XCTAssertTrue(actual == expected)
        XCTAssertTrue(size == 0)
    }
    
    func testCompressedStringFromCodable() throws {
        guard let text = loadLoremText() else {
            XCTFail()
            return
        }
        
        // compressed size, is not the same as character count!
        let expectedCharacterCount = 368
        let expectedSize = 413
        
        let codable = Book(title: "title", text: text)
        let (actual, size) = try Linking.compressedStringFrom(codable: codable)
        
        XCTAssertTrue(actual.count == expectedCharacterCount)
        XCTAssertTrue(size == expectedSize)
    }
        
    func testCreateLinkWithCodable() throws {
        guard let baseURL = URL(string:"https://ieesizaq.com/") else {
            XCTFail()
            return
        }
        
        let codable = Book(title: "title", text: "Hello World!")
        let url = try Linking.createLink(baseURL: baseURL, route: ["e", "resource"], codable: codable)

        let expected = "https://ieesizaq.com/e/resource?json=%257B%2522text%2522:%2522Hello%2520World!%2522,%2522title%2522:%2522title%2522%257D"
        let actual = url.absoluteString
        
        XCTAssertTrue(actual == expected)
    }

    func testCreateLinkWithCodableCompressed() throws {
        guard let baseURL = URL(string:"https://ieesizaq.com/") else {
            XCTFail()
            return
        }
        
        guard let text = self.loadAmbroseText() else {
            XCTFail()
            return
        }
        
        let codable = Book(title: "title", text: text)
        let url = try Linking.createLink(baseURL: baseURL, route: ["e", "resource"], codable: codable, compress: true)

        if let compressed = loadCompressedAmbroseText() {
            
            // Ugly brute force string check since the query parameter order is undefined
            let expected1 = "https://ieesizaq.com/e/resource?json=\(compressed)&json_size=414241"
            let expected2 = "https://ieesizaq.com/e/resource?json_size=414241&json=\(compressed)"
            
            let actual = url.absoluteString
            XCTAssertTrue(actual == expected1 || actual == expected2)
        }
    }
}
