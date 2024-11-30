//
//  NetworkMonitor.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Network

public struct NetworkInterfaceSummary: Codable {
    public let name: String
    public let type: String
}

public struct NetworkPathSummary: Codable {
    public let status: String
    public let interfaces: [NetworkInterfaceSummary]
}

/// Monitors network connectivity.
///
/// Do not disable features based on this information. It often makes for poor user experience.
/// Network connectivity can be flakey and the app should smooth out the experience for the end user.
/// Consider retries, offline storage, etc
///
/// https://developer.apple.com/documentation/network/nwpathmonitor
public final class NetworkMonitor: NSObject, Sendable {
    
    public static let shared: NetworkMonitor = NetworkMonitor()
    
    let queue = DispatchQueue(label:"com.ieesizaq.networkMonitor")
    let monitor = NWPathMonitor()
    
    public override init() {
        super.init()
        self.monitor.start(queue: self.queue)
    }
    
    public func readCurrentPathData() -> NetworkPathSummary {
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
