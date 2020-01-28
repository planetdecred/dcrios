//  TransactiontViewOnDcrdataCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class TransactiontViewOnDcrdataCell: UITableViewCell {
    var onViewOnDcrData: (() -> Void)?

    @IBAction func openLink(_ sender: Any) {
        self.onViewOnDcrData?()
    }
}
