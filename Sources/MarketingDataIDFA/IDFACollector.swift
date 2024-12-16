//
//  IDFACollector.swift
//  EchoDeviceDataIDFA
//
//  Created by echo on 11/24/24.
//

import Foundation
import AdSupport // for IDFA
import AppTrackingTransparency // For ATT status
import MarketingData // For IDFASource protocol
import Marketing

/// Collects IDFA related data
/// Does NOT request access to IDFA or show the ATT prompt!
///
/// Apps using this code will need to display the ATT prompt and provide a Privacy Manifest.
public final class IDFACollector: IDFASource, Sendable {
    
    public init() { }
    
    /// Reads the advertising identifier
    /// This API requires disclosure and ATT permission for a valid response
    /// Simulators always return an all 0 response, regardless of ATT status
    ///
    /// Never cache this value per Apple's guidance.
    /// https://developer.apple.com/documentation/adsupport/asidentifiermanager/advertisingidentifier
    public func readIdentifierForAdvertiser() -> String? {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if ("00000000-0000-0000-0000-000000000000" == idfa) {
            Logger.shared.logDebug(message: "advertisingIdentifier is all 0. This is expected if the user has not granted permission via the AppTrackingTransparency prompt.")
        }
        return idfa
    }
    
    /// Reads app tracking transparency opt in status.
    ///
    /// Checking status does NOT trigger the ATT prompt.
    /// However, Apple rejects apps that have the `AppTrackingTransparancy.framework` included but do not show the ATT prompt.
    ///
    /// https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/authorizationstatus
    public func readAppTrackingTransparencyOptInStatus() -> String? {
        var status: String
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .notDetermined:
            status = "notDetermined"
        case .restricted:
            status = "restricted"
        case .denied:
            status = "denied"
        case .authorized:
            status = "authorized"
        @unknown default:
            status = "unknown"
        }
        return status
    }
}
