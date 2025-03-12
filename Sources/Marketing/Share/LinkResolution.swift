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
    
    // Link that opened the App
    let url: String
    
    // TODO: stuff
}

public struct DubResponse: Codable, Sendable {
    
    // destination url
    let url: String
    
    // TODO: add other possible payload data
}

// Dub.co link resolution
extension LinkResolution {
    
    // TODO: refactor the dub link resolution service
    public func resolveWithDub(_ link: String) async throws -> DubResponse {
        guard let baseURL = config.dubLinkService, let publishableKey = config.dubPublishableKey else {
            throw LinkResolutionError.dubConfigurationError
        }
        
        let (host, key) = try splitLink(link)
        guard config.dubSupportedDomains.contains(host) else {
            throw LinkResolutionError.unsupportedDomain
        }
        
        guard let url = URL(string: "\(baseURL)/links/resolve?domain=\(host)&key=\(key)") else {
            throw LinkResolutionError.dubConfigurationError
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(publishableKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
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

