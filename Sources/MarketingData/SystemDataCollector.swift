//
//  SystemDataCollector.swift
//  MarketingData
//
//  Created by echo on 11/24/24.
//

import UIKit
import Marketing

struct Utsname: Codable {
    let sysname: String
    let nodename: String
    let release: String
    let version: String
    let machine: String
}

struct Sysctl: Codable {
    let osversion: String
    let model: String
    let machine: String
    let cputype: String
    let cpusubtype: String
}

/// Utility that collects Device level data
/// These are generally shared across all users for a device model and app version
struct SystemDataCollector {
    
    /// User specific, but shared across a large number of users. For example, nearly all US users will be set to `en_US` or `es_US`.
    static func readCurrentLocale() -> String {
        return Locale.current.identifier
    }
    
    /// IDFV, shared across apps from the same vendor on this device
    /// https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor
    @MainActor static func readIdentifierForVendor() -> String {
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            if ("00000000-0000-0000-0000-000000000000" == idfv) {
                Logger.shared.logDebug(message: "identifierForVendor is all 0. This is expected on AppClips.")
            }
            return idfv
        } else {
            Logger.shared.logDebug(message: "IDFV not found")
        }
        return ""
    }
    
    @MainActor static func readSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    /// Read system info from uname
    /// https://opensource.apple.com/source/xnu/xnu-124.8/bsd/sys/utsname.h.auto.html
    static func readUtsnameSystemInfo() -> Utsname {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        // All these values are normally present, but fallback to empty string just in case
        // Converts c strings to String and removes trailing null chars
        let sysname = String(bytes: Data(bytes: &systemInfo.sysname, count: Int(_SYS_NAMELEN)), encoding: .utf8)?.trimmingCharacters(in: ["\0"]) ?? ""
        let nodename = String(bytes: Data(bytes: &systemInfo.nodename, count: Int(_SYS_NAMELEN)), encoding: .utf8)?.trimmingCharacters(in: ["\0"]) ?? ""
        let release = String(bytes: Data(bytes: &systemInfo.release, count: Int(_SYS_NAMELEN)), encoding: .utf8)?.trimmingCharacters(in: ["\0"]) ?? ""
        let version = String(bytes: Data(bytes: &systemInfo.version, count: Int(_SYS_NAMELEN)), encoding: .utf8)?.trimmingCharacters(in: ["\0"]) ?? ""
        let machine = String(bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)), encoding: .utf8)?.trimmingCharacters(in: ["\0"]) ?? ""
        return Utsname(sysname: sysname, nodename: nodename, release: release, version: version, machine: machine)
    }
    
    /// Read system info from sysctlbyname
    /// https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/sysctlbyname.3.html
    static func readSysctlSystemInfo() -> Sysctl {
        
        // All these values are normally present, but fallback to empty string just in case
        let osversion = self.readStringFromSysctlbyname(name: "kern.osversion") ?? ""
        let model = self.readStringFromSysctlbyname(name: "hw.model") ?? ""
        let machine = self.readStringFromSysctlbyname(name: "hw.machine") ?? ""
        let cputype = self.readSysctlbynameCPUType()
        let cpusubtype = self.readSysctlbynameCPUSubtype()
            
        return Sysctl(osversion: osversion, model: model, machine: machine, cputype: String(cputype), cpusubtype: String(cpusubtype))
    }
    
    /// Reads a String value from sysctlbyname
    static func readStringFromSysctlbyname(name: String) -> String? {
        // load size
        var size = 0
        sysctlbyname(name, nil, &size, nil, 0)
        
        // fetch string
        var string = [CChar](repeating: 0, count: size)
        sysctlbyname(name, &string, &size, nil, 0)
        
        return String(cString:string, encoding: .utf8) ?? nil
    }
    
    static func readSysctlbynameCPUType() -> Int {
        var size: size_t = 0
        var type: cpu_type_t = 0
        
        size = MemoryLayout<cpu_type_t>.size;
        sysctlbyname("hw.cputype", &type, &size, nil, 0)
        
        return Int(type)
    }
    
    static func readSysctlbynameCPUSubtype() -> Int {
        var size: size_t = 0
        var subtype: cpu_subtype_t = 0
        
        size = MemoryLayout<cpu_subtype_t>.size;
        sysctlbyname("hw.cpusubtype", &subtype, &size, nil, 0)
        
        return Int(subtype)
    }
}
