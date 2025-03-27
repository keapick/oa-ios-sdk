//
//  LinkResolution.swift
//  Marketing
//
//  Created by echo on 2/26/25.
//

import Foundation

public enum LinkResolutionError: Error {
    case dubConfigurationError
    case unsupportedDomain
    case linkValidationFailure
}

// Helper to resolve links with linking services
public struct LinkResolution: Sendable {
    
    var urlSession: URLSession
    var config: Config
    
    public init(urlSession: URLSession = URLSession.shared, config: Config = .shared) {
        self.urlSession = urlSession
        self.config = config
    }
    
}

public struct DubRequest: Codable, Sendable {
    let version: String = "1.0.0"
    
    // Link that opened the App
    let link: String
    
    // TODO: add app or device info
}

public struct DubResponse: Codable, Sendable {
    
    // destination url
    let url: String
    let shortLink: String?
    
    // TODO: add other possible payload data
}

// Dub.co link resolution
extension LinkResolution {
    
    public func resolveWithDub(_ link: String) async throws -> DubResponse {

        guard let baseURL = config.dubLinkService, let publishableKey = config.dubPublishableKey else {
            throw LinkResolutionError.dubConfigurationError
        }
        
        guard let url = URL(string: "\(baseURL)/links/resolve") else {
            throw LinkResolutionError.dubConfigurationError
        }
        
        let payload = try JSONEncoder().encode(DubRequest(link: link))
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(publishableKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = payload
        
        let (data, _) = try await URLSession.shared.data(for: request)

//        if let string = String(data: data, encoding: .utf8) {
//            print("Response: \(string)")
//        }
        
        let response = try JSONDecoder().decode(DubResponse.self, from: data)
        return response
    }
    
    // Dub links are https://domain/key and requires it to be split to submit
    func splitLink(_ link: String) throws -> (host: String, key: String) {
        guard let open = URL(string: link) else {
            throw LinkResolutionError.linkValidationFailure
        }
        
        if #available(iOS 16.0, *) {
            let host = open.host() ?? ""
            let key = open.lastPathComponent
            return (host, key)
        } else {
            // TODO: add support for pre-iOS 16
        }
        
        throw LinkResolutionError.linkValidationFailure
    }
}

