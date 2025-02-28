//
//  LinkResolution.swift
//  Marketing
//
//  Created by echo on 2/26/25.
//

import Foundation

public enum LinkResolutionError: Error {
    case dubConfigurationError
    case linkValidationFailure
}

// Dub server response format
public struct DubResponse: Codable, Sendable {
    let url: String
    
    // Not terribly useful as this is what we submitted to the server
    let shortLink: String
}

// Helper to resolve links with linking services
public struct LinkResolution: Sendable {
    
    var urlSession: URLSession
    var config: Config
    
    public init(urlSession: URLSession = URLSession.shared, config: Config = .shared) {
        self.urlSession = urlSession
        self.config = config
    }
    
    @available(iOS 16.0, *)
    public func resolveWithDub(_ link: String) async throws {
        
        // TODO: split the link to be compatible with Dub's current API
        guard let open = URL(string: link) else {
            throw LinkResolutionError.linkValidationFailure
        }
        let host = open.host() ?? ""
        let key = open.lastPathComponent
        
        guard let baseURL = config.dubLinkService, let publishableKey = config.dubPublishableKey else {
            throw LinkResolutionError.dubConfigurationError
        }
        
        guard let url = URL(string: "\(baseURL)/links/resolve?domain=\(host)&key=\(key)") else {
            throw LinkResolutionError.dubConfigurationError
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(publishableKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // TODO: parse the dub response
        if let string = String(data: data, encoding: .utf8) {
            print("Test: \(string)")
        } else {
            print("Did not return text")
        }
    }
    
}

