//
//  NetworkMonitor.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Network

struct NetworkInterfaceSummary: Codable, Sendable {
    let name: String
    let type: String
}

struct NetworkPathSummary: Codable, Sendable {
    let status: String
    let interfaces: [NetworkInterfaceSummary]
}

/// Monitors network connectivity.
///
/// Do not disable features based on this information. It often makes for poor user experience.
/// Network connectivity can be flakey and the app should smooth out the experience for the end user.
/// Consider retries, offline storage, etc
///
/// https://developer.apple.com/documentation/network/nwpathmonitor
final class NetworkMonitor: Sendable {
    
    static let shared: NetworkMonitor = NetworkMonitor()
    
    let queue = DispatchQueue(label:"dev.openattribution.networkMonitor")
    let monitor = NWPathMonitor()
    
    init() {
        self.monitor.start(queue: self.queue)
    }
    
    func readCurrentPathData() -> NetworkPathSummary {
        let path = self.monitor.currentPath
        
        let status = self.statusString(status: path.status)
        var interfaceSummaries = [NetworkInterfaceSummary]()
        
        for interface in path.availableInterfaces {
            let interfaceSummary = NetworkInterfaceSummary(name: interface.name, type: self.interfaceTypeString(type: interface.type))
            interfaceSummaries.append(interfaceSummary)
        }
        
        return NetworkPathSummary(status: status, interfaces: interfaceSummaries)
    }
    
    func interfaceTypeString(type: NWInterface.InterfaceType) -> String {
        switch type {
        case .other:
            return "other"
        case .wifi:
            return "wifi"
        case .cellular:
            return "cellular"
        case .wiredEthernet:
            return "wiredEthernet"
        case .loopback:
            return "loopback"
        @unknown default:
            return "unknown"
        }
    }
    
    func statusString(status: NWPath.Status) -> String {
        switch status {
        case .satisfied:
            return "satisfied"
        case .unsatisfied:
            return "unsatisfied"
        case .requiresConnection:
            return "requiresConnection"
        @unknown default:
            return "unknown"
        }
    }
}
