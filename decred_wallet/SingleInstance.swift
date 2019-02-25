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
    
    var syncStartPoint = -1, syncCurrentPoint = -1, syncEndPoint = -1;
    var syncProgress = 0, accountDiscoveryStartTime = 0, totalDiscoveryTime = 0;
    var fetchHeaderTime = -1, totalFetchTime = -1, rescanTime = 0, syncRemainingTime = 0, initialSyncEstimate = -1;
    var syncStatus = "", syncVerbose = "";
    public class var shared: SingleInstance {
        struct Static {
            static let instance: SingleInstance = SingleInstance()
        }
        return Static.instance
    }
}
