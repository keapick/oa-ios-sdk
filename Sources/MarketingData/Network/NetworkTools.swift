//
//  NetworkTools.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import Foundation

public enum NetworkError: Error {
    case getifaddrsFailure // failure to read network interfaces
}

public struct NetworkInterface: Codable {
    public let name: String
    public let type: String
    public let address: String
}

public struct NetworkTools {
    
    /// Read network interface info from getifaddrs
    ///
    /// includeIPv4 - includes interfaces with IPv4 addresses
    /// includeIPv6 - includes interfaces with IPv6 addresses
    /// privateOnly - only includes interfaces with private addresses
    ///
    /// https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/getifaddrs.3.html
    public static func readNetworkInterfaces(includeIPv4: Bool = true,
                                             includeIPv6: Bool = true,
                                             privateOnly: Bool = true) throws -> [NetworkInterface] {
         
        var listOfInterfaces = [NetworkInterface]()
        
        // getifaddrs creates the linked list itself, but we must free it
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        defer {
            // freeifaddrs expects a non-nil input
            if let interfaces {
                freeifaddrs(interfaces)
            }
        }
        
        guard getifaddrs(&interfaces) == 0 else {
            throw NetworkError.getifaddrsFailure
        }
        
        var interface = interfaces
        while (interface != nil) {
            if let ptr = interface?.pointee {
                // get addresses for AF_INET and AF_INET6
                // https://github.com/apple/darwin-xnu/blob/main/bsd/sys/socket.h
                
                // interface name
                let name = String(cString: ptr.ifa_name, encoding: .utf8)
                
                // sockaddr can be cast to sockaddr_in
                let sockaddr = ptr.ifa_addr.pointee
                var addr = unsafeBitCast(sockaddr, to: sockaddr_in.self)
                
                if includeIPv4 && sockaddr.sa_family == AF_INET {
                    // create buffer and request IPv4 address
                    var address = [CChar](repeating: 0, count:Int(INET_ADDRSTRLEN))
                    inet_ntop(AF_INET, &addr.sin_addr, &address, socklen_t(INET_ADDRSTRLEN))
                    
                    // optionally filter for private networks
                    if !privateOnly || isPrivateNetwork(ipv4: address) {
                        
                        // save name, ip address and type
                        let addressString = String(cString: address, encoding: .utf8)
                        if let name, let addressString {
                            listOfInterfaces.append(NetworkInterface(name: name, type: "ipv4", address: addressString))
                        }
                    }
                    
                } else if includeIPv6 && sockaddr.sa_family == AF_INET6 {
                    // create buffer and request IPv6 address
                    var address = [CChar](repeating: 0, count:Int(INET6_ADDRSTRLEN))
                    inet_ntop(AF_INET6, &addr.sin_addr, &address, socklen_t(INET6_ADDRSTRLEN))
                    
                    if !privateOnly || isPrivateNetwork(ipv6: address) {
                        
                        // save name, ip address and type
                        let addressString = String(cString: address, encoding: .utf8)
                        if let name, let addressString {
                            listOfInterfaces.append(NetworkInterface(name: name, type: "ipv6", address: addressString))
                        }
                    }
                }
            }
            
            interface = interface?.pointee.ifa_next
        }
                
        return listOfInterfaces
    }
    
    // CChars
    static let charDot = CChar(truncatingIfNeeded: 46)
    static let char0 = CChar(truncatingIfNeeded: 48)
    static let char1 = CChar(truncatingIfNeeded: 49)
    static let char2 = CChar(truncatingIfNeeded: 50)
    static let char3 = CChar(truncatingIfNeeded: 51)
    static let char6 = CChar(truncatingIfNeeded: 54)
    static let char7 = CChar(truncatingIfNeeded: 55)
    static let char8 = CChar(truncatingIfNeeded: 56)
    static let char9 = CChar(truncatingIfNeeded: 57)
    static let charColon = CChar(truncatingIfNeeded: 58)
    static let chard = CChar(truncatingIfNeeded: 100)
    static let charf = CChar(truncatingIfNeeded: 102)
    
    // 192.168.0.0/16
    static let charArray192: [CChar] = [ char1, char9, char2 ]
    static let charArray168: [CChar] = [ char1, char6, char8 ]
    
    // 172.16.0.0/12
    static let charArray172: [CChar] = [ char1, char7, char2 ]
    
    // 10.0.0.0/8
    static let charArray10: [CChar] = [ char1, char0 ]
    
    // Assumes the input is a valid IPv4
    // Does NOT validate the whole IP address!
    static func isPrivateNetwork(ipv4: [CChar]) -> Bool {
        
        let slices = ipv4.split(separator: charDot)
        guard slices.count == 4 else {
            return false
        }
        
        if slices[0].count == 3 {
            // handle 192.168.0.0/16
            if charArray192.elementsEqual(slices[0]) {
                return charArray168.elementsEqual(slices[1])
                
            // handle 172.16.0.0/12
            } else if charArray172.elementsEqual(slices[0]) {
                
                // Second octet is 16-31
                if (slices[1].count == 2) {
                    
                    // slices preseve the parent array indices, so only the first slice indexes from 0!
                    let j = slices[1].startIndex
                    
                    // 16-19 is valid
                    if slices[1][j] == char1 {
                        return (slices[1][j+1] >= char6 && slices[1][j+1]  <= char9)
                    }
                    
                    // 20-29 is valid
                    if slices[1][j] == char2 {
                        return true
                    }
                    
                    // 30-31 is valid
                    if slices[1][j] == char3 {
                        return (slices[1][j+1] == char0 || slices[1][j+1] == char1)
                    }
                }
            }
            
        // handle 10.0.0.0/8
        } else if slices[0].count == 2 {
            return charArray10.elementsEqual(slices[0])
        }
        
        return false
    }
    
    // Assumes the input is a valid IPv6
    static func isPrivateNetwork(ipv6: [CChar]) -> Bool {
        
        // fd00::/8
        // scans for fd start
        var count = 0
        for char in ipv6 {
            if char == charColon || char == char0 {
                // ignore any : or 0 prior to the first starting char
            } else {
                if count == 0 {
                    // f must be first
                    if char != charf {
                        return false
                    } else {
                        count = count + 1
                    }
                } else if count == 1 {
                    // d must be second
                    if char != chard {
                        return false
                    } else {
                        return true
                    }
                }
            }
        }
        return false
    }
}
