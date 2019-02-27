//
//  SingleInstance.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet
public class SingleInstance{
    var wallet: DcrlibwalletLibWallet?
    var  synced = false, syncing = true;
    var peers = 0;
    var syncStartPoint : Int64 = -1, syncCurrentPoint : Int64 = -1, syncEndPoint : Int64 = -1;
    var syncProgress = 0, accountDiscoveryStartTime: Int64 = 0, totalDiscoveryTime: Int64 = 0;
    var fetchHeaderTime : Int64 = -1, totalFetchTime : Int64 = -1, rescanTime : Int64 = 0, syncRemainingTime  : Int64 = 0, initialSyncEstimate : Int64 = -1;
    var syncStatus = "", syncVerbose = "";
    var bestBlockTime = ""
    var ChainStatus = ""
    public class var shared: SingleInstance {
        struct Static {
            static let instance: SingleInstance = SingleInstance()
        }
        return Static.instance
    }
}
