//
//  WatchOnlyWalletTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

protocol WatchOnlyWalletTableViewCellDelegate {
    func showWatchOnlyWalletMenu(walletName: String, walletID: Int, type: DropDowMenuEnum)
}

class WatchOnlyWalletTableViewCell: UITableViewCell {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var totalAccountBalanceLabel: UILabel!
    @IBOutlet weak var walletMenuButton: DropMenuButton!
    
    var delegate: WatchOnlyWalletTableViewCellDelegate?
    
    var wallet: Wallet! {
        didSet {
            self.walletNameLabel.text = wallet?.name
            self.totalAccountBalanceLabel.text = wallet.balance
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setupMenuDropDown()
    }
    
    func setupMenuDropDown() {
        let menuOption = [
            DropMenuButtonItem(LocalizedStrings.rename, isSeparate: true, textLabel: ""),
            DropMenuButtonItem(LocalizedStrings.settings, isSeparate: false, textLabel: ""),
        ]
        self.walletMenuButton.initMenu(menuOption, marginRight: 16, isDissmissOutside: true, superView: self.superview?.superview?.superview?.superview?.superview?.superview?.superview) { [weak self] index, value in
            guard let `self` = self else {return}
            self.delegate?.showWatchOnlyWalletMenu(walletName: self.wallet.name, walletID: self.wallet.id, type: DropDowMenuEnum(rawValue: index + 3)!)
            
        }
    }
}
