//
//  SyncDecodableDataTypes.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 13/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//
import Foundation

protocol GeneralSyncProgressProtocol {
    var totalSyncProgress: Int32 { get }
    var totalTimeRemainingSeconds: Int64 { get }
}

extension GeneralSyncProgressProtocol {
    var totalTimeRemaining: String {
        let minutes = self.totalTimeRemainingSeconds / 60
        if minutes > 0 {
            return "\(minutes) min"
        }
        return "\(self.totalTimeRemainingSeconds) sec"
    }
}

struct HeadersFetchProgressReport: Decodable, GeneralSyncProgressProtocol {
    var totalSyncProgress: Int32
    var totalTimeRemainingSeconds: Int64
    
    var totalHeadersToFetch: Int32
    var currentHeaderTimestamp: Int64
    var fetchedHeadersCount: Int32
    var headersFetchProgress: Int32
    
    var bestBlockAge: String {
        if self.currentHeaderTimestamp == 0 {
            return ""
        }
        
        let nowSeconds = Date().millisecondsSince1970 / 1000
        let hoursBehind = Float(nowSeconds - self.currentHeaderTimestamp) / Float(Utils.TimeInSeconds.Hour)
        let daysBehind = Int64(round(hoursBehind / 24.0))
        
        if daysBehind < 1 {
            return "<1 day"
        } else if daysBehind == 1 {
            return "1 day"
        } else {
            return "\(daysBehind) days"
        }
    }
}

struct AddressDiscoveryProgressReport: Decodable, GeneralSyncProgressProtocol {
    var totalSyncProgress: Int32
    var totalTimeRemainingSeconds: Int64
    
    var addressDiscoveryProgress: Int32
}

struct HeadersRescanProgressReport: Decodable, GeneralSyncProgressProtocol {
    var totalSyncProgress: Int32
    var totalTimeRemainingSeconds: Int64
    
    var totalHeadersToScan: Int32
    var rescanProgress: Int32
    var currentRescanHeight: Int32
}
