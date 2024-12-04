//
//  Compression.swift
//  Marketing
//
//  Created by echo on 11/24/24.
//

import Foundation
import Compression

public enum CompressionError: Error {
    case compressionFailed
    case decompressionFailed
}

/// Helper methods using the Apple Compression framework
public struct Compression {

    /// Compress string with given algorithm
    /// Returns data and original buffer size. The string count is NOT a good substitute for the buffer size.
    public static func compress(string: String, algorithm: compression_algorithm) throws -> (Data, Int)? {
        var sourceBuffer = Array(string.utf8)
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: string.count)
        defer {
            destinationBuffer.deallocate()
        }
        
        let compressedSize = compression_encode_buffer(destinationBuffer,
                                                       sourceBuffer.count,
                                                       &sourceBuffer,
                                                       sourceBuffer.count,
                                                       nil,
                                                       algorithm)
        
        if compressedSize == 0 {
            throw CompressionError.compressionFailed
        }
        
        // copies the buffer, so the deallocate is ok
        let data = Data(bytes: destinationBuffer, count: compressedSize)
        return (data, sourceBuffer.count)
    }
    
    /// Decompress string with a given algorithm
    public static func decompress(compressedString: Data, size: Int, algorithm: compression_algorithm) throws -> String? {
        let decodedCapacity = size
        let decodedDestinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: decodedCapacity)
        defer {
            decodedDestinationBuffer.deallocate()
        }
        
        let decodedCount: Int = compressedString.withUnsafeBytes { encodedSourceBuffer in
            let typedPointer = encodedSourceBuffer.bindMemory(to: UInt8.self)
            let decodedCharCount = compression_decode_buffer(decodedDestinationBuffer,
                                                             decodedCapacity,
                                                             typedPointer.baseAddress!,
                                                             compressedString.count,
                                                             nil,
                                                             algorithm)
            return decodedCharCount
        }
        
        if decodedCount == 0 {
            throw CompressionError.decompressionFailed
        }
        
        // copies the buffer, so the deallocate is ok
        let data = Data(bytes: decodedDestinationBuffer, count: decodedCount)
        return String(data: data, encoding: .utf8)
    }
}
