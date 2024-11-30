//
//  CompressionTests.swift
//  MarketingTests
//
//  Created by echo on 11/24/24.
//

import XCTest
import Compression
@testable import Marketing

final class CompressionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // In unit tests, the bundle is the one associated with the module
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
    
    func loadTestText() -> String? {
        return self.loadFile(name: "compression_lorem", fileExtension: "txt")
    }
    
    func loadAmbrostText() -> String? {
        return self.loadFile(name: "compression_ambrose", fileExtension: "txt")
    }

    func testLoadTest() throws {
        guard let string = self.loadTestText() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string.count == 365)
    }
    
    func testLoadAmbrose() throws {
        guard let string = self.loadAmbrostText() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string.count == 384350)
    }
    
    func testCompressionBasic() throws {
        let string = """
            Lorem ipsum dolor sit amet consectetur adipiscing elit mi
            nibh ornare proin blandit diam ridiculus, faucibus mus
            dui eu vehicula nam donec dictumst sed vivamus bibendum
            aliquet efficitur. Felis imperdiet sodales dictum morbi
            vivamus augue dis duis aliquet velit ullamcorper porttitor,
            lobortis dapibus hac purus aliquam natoque iaculis blandit
            montes nunc pretium.
            """
        
        guard let (compressedData, expectedSize) = try Compression.compress(string: string, algorithm: COMPRESSION_ZLIB) else {
            XCTFail()
            return
        }
        
        guard let uncompressedString = try Compression.decompress(compressedString: compressedData, size: expectedSize, algorithm: COMPRESSION_ZLIB) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string.count == uncompressedString.count)
    }
    
    func testCompressionBasicFromFile() throws {
        guard let string = self.loadTestText() else {
            XCTFail()
            return
        }
        
        guard let (compressedData, expectedSize) = try Compression.compress(string: string, algorithm: COMPRESSION_ZLIB) else {
            XCTFail()
            return
        }
        
        guard let uncompressedString = try Compression.decompress(compressedString: compressedData, size: expectedSize, algorithm: COMPRESSION_ZLIB) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string.count == uncompressedString.count)
    }
    
    func testCompressDecompressAmbrose() throws {
        guard let string = self.loadAmbrostText() else {
            XCTFail()
            return
        }
        
        guard let (compressedData, expectedSize) = try Compression.compress(string: string, algorithm: COMPRESSION_ZLIB) else {
            XCTFail()
            return
        }
        
        guard let uncompressedString = try Compression.decompress(compressedString: compressedData, size: expectedSize, algorithm: COMPRESSION_ZLIB) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(string.count == uncompressedString.count)
    }

}
