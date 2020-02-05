//
//  AccountSelectDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

typealias AccountSelectDialogCallback = (_ selectedWallet: Wallet, _ selectedAccount: DcrlibwalletAccount) -> Void

class AccountSelectDialog: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!

    private var dialogTitle: String!
    private var callback: AccountSelectDialogCallback!
    
    static func show(sender vc: UIViewController,
                     title: String,
                     callback: @escaping AccountSelectDialogCallback) {

        let dialog = AccountSelectDialog.instantiate(from: .Receive)
        dialog.dialogTitle = title
        dialog.callback = callback

        dialog.modalPresentationStyle = .pageSheet
        vc.present(dialog, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.dialogTitle
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismissView()
    }
}
