//
//  SyncDecodableDataTypes.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 13/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

struct GeneralSyncProgressReport: Decodable {
    var status: String
    var connectedPeers: Int32
    var error: String
    var done: Bool
    
    var totalSyncProgress: Int32
    var totalTimeRemainingSeconds: Int64
    
    var peerCount: String {
        if self.connectedPeers == 1 {
            return "\(self.connectedPeers) peer"
        } else {
            return "\(self.connectedPeers) peers"
        }
    }
    
    var totalTimeRemaining: String {
        let minutes = self.totalTimeRemainingSeconds / 60
        if minutes > 0 {
            return "\(minutes) min"
        }
        return "\(self.totalTimeRemainingSeconds) sec"
    }
}

struct HeadersFetchProgressReport: Decodable {
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

struct AddressDiscoveryProgressReport: Decodable {
    var addressDiscoveryProgress: Int32
}

struct HeadersRescanProgressReport: Decodable {
    var totalHeadersToScan: Int32
    var rescanProgress: Int32
    var currentRescanHeight: Int32
}
