//
//  SendinDetails.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

struct SendingDetails {
    var amount: Double
    var destinationAddress: String?
    var destinationWallet: DcrlibwalletAccount?
    var sourceWallet: DcrlibwalletAccount?
    var transactionFee: String
    var balanceAfterSend: String
    var totalCost: String
    var sendMax: Bool = false
}
