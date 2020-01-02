//
//  SendinDetails.swift
//  Decred Wallet
//
//  Created by kayeli dennis on 28/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import Foundation
import Dcrlibwallet

struct SendingDetails {
    var amount: Double
    var destinationAddress: String?
    var destinationWallet: WalletAccount?
    var sourceWallet: WalletAccount?
    var transactionFee: String
    var balanceAfterSend: String
    var totalCost: String
    var sendMax: Bool = false
}
