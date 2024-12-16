//
//  Linking.swift
//  Marketing
//
//  Created by echo on 11/24/24.
//

//import UIKit
import Foundation
import Compression

public enum LinkingError: Error {
    case failedToCreateLink
    case failedToConvertCodableToString
    case failedToConvertStringToCodable
    case failedToConvertCodableToCompressedString
}

/// Helper methods for creation and consumption links
/// TODO: consider integration with link shorteners
public struct Linking {
    
    // Most browsers cannot handle URLs over ~2k characters
    public static let maxSafeURLLength: Int = 2048

    /// Link creation with option to append codable as a query parameter
    ///
    /// baseURL - base url
    /// route - path components required for basic functionality. This should be short and SEO friendly. ~75 chars or less.
    /// codable - Swift Codable converted to a JSON String and appended as a query parameter.
    /// compress - option to attempt compression of JSON String, this is not guaranteed for small items.
    ///
    /// Example:
    ///
    public static func createLink(baseURL: URL, route: [String], codable: Codable, compress: Bool = false) throws -> URL {
        if compress {
            let (momento, size) = try Linking.compressedStringFrom(codable: codable)
            if size > 0 {
                // compression worked
                return try Linking.createLink(baseURL: baseURL, route:route, queryParameters: ["json":momento, "json_size":"\(size)"])
            } else {
                // no compression was possible, return link with uncompressed momento
                return try Linking.createLink(baseURL: baseURL, route:route, queryParameters: ["json":momento])
            }

        } else {
            let momento = try Linking.stringFrom(codable: codable)
            return try Linking.createLink(baseURL: baseURL, route:route, queryParameters: ["json":momento])
        }
    }
    
    
    /// Generic link creation
    ///
    /// baseURL - base url
    /// route - path components required for basic functionality. This should be short and SEO friendly. ~75 chars or less.
    /// queryParameters - optional data. Additional parameters are often appended by 3rd parties, such as ad networks or network infrastructure.
    ///
    /// Example:
    /// https://openattribution.dev/e/resource?momento=compressedJSON&momento_s=1234
    public static func createLink(baseURL: URL, route: [String], queryParameters: [String : String]) throws -> URL {
        if #available(iOS 16.0, tvOS 16.0, *) {
            if var copy = URL(string: baseURL.absoluteString) {
                
                // add route
                for component in route {
                    copy.append(component: component)
                }
                
                // Add query parameters
                var queryItems: [URLQueryItem] = []
                queryParameters.forEach { name, value in
                    if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        let queryItem = URLQueryItem(name: encodedName, value: encodedValue)
                        queryItems.append(queryItem)
                    }
                }
                copy.append(queryItems: queryItems)
                return copy
            }
        } else {
           print("TODO: Add pre-iOS 16 support for query parameters")
        }
        throw LinkingError.failedToCreateLink
    }
    
    /// Reads a query parameter name off the URL
    static func readQueryParameter(name: String, url: URL) -> String? {
        if #available(iOS 16.0, tvOS 16.0, *) {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return nil
            }
            guard let queryItems = components.queryItems else {
                return nil
            }
            
            for queryItem in queryItems {
                if queryItem.name == name {
                    if let value = queryItem.value?.removingPercentEncoding {
                        return value
                    }
                }
            }
        } else {
            print("TODO: Add pre-iOS 16 support for query parameters")
        }
        return nil
    }
    
    /// Converts a Codable to a String.
    static func stringFrom(codable: Codable) throws -> String {
        // encode codable to json
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(codable)
        
        // convert the json data to a string
        if let string = String(data: data, encoding: .utf8) {
            return string
        } else {
            throw LinkingError.failedToConvertCodableToString
        }
    }
    
    /// Converts a String to Codable
    static func codableFrom<T>(string: String, type: T.Type) throws -> T where T : Decodable {
        if let data = string.data(using: .utf8) {
            return try JSONDecoder().decode(type, from: data)
        }
        
        throw LinkingError.failedToConvertStringToCodable
    }
    
    /// Converts Codable to a String
    /// Attempts to Brotli compress and base 64 encode the returned string.
    /// Only useful  for Codables over ~800 chars, otherwise it falls back to returning the same string representation as stringFrom(codable: Codable)
    ///
    /// Returns a compressed and base64 encoded string, along with original size.
    static func compressedStringFrom(codable: Codable) throws -> (String, Int) {
        let string = try self.stringFrom(codable: codable)
        
        do {
            if let (buffer, size) = try Compression.compress(string: string, algorithm: COMPRESSION_BROTLI) {
                let base64EncodedString = buffer.base64EncodedString()
                return (base64EncodedString, size)
            }
        } catch { }
        
        // Compression failed, this usually indicates the string was too small to compress.
        return (string, 0)
    }
    
    static func codableFrom(compressedString: Data, size: Int, type: Codable.Type) throws -> Codable? {
        if let string = try Compression.decompress(compressedString: compressedString, size: size, algorithm: COMPRESSION_BROTLI) {
            return try codableFrom(string: string, type: type)
        }
        return nil
    }
}

