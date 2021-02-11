//
//  SimpleAlertDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SimpleAlertDialog: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    
    private var message: String!
    private var okButtonText: String!
    private var callback: (() -> Void)?

    static func show(sender vc: UIViewController,
                     message: String,
                     okButtonText: String,
                     callback: (() -> Void)? = nil) {

        let dialog = SimpleAlertDialog.instantiate(from: .CustomDialogs)
        dialog.message = message
        dialog.callback = callback
        dialog.okButtonText = okButtonText

        dialog.modalTransitionStyle = .crossDissolve
        dialog.modalPresentationStyle = .overFullScreen
        vc.present(dialog, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.messageLabel.text = self.message
        self.okBtn.setTitle(self.okButtonText, for: .normal)
    }

    @IBAction func gotItButtonTapped(_ sender: Any) {
        self.dismissView()
        self.callback?()
    }
}
