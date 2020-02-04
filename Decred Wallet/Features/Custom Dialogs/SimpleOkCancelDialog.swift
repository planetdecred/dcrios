//
//  SimpleOkCancelDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SimpleOkCancelDialog: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: Button!
    
    private var dialogTitle: String!
    private var message: String!
    private var cancelButtonText: String?
    private var okButtonText: String?
    private var callback: ((_ ok: Bool) -> Void)?
    
    static func show(sender vc: UIViewController,
                     title: String,
                     message: String,
                     cancelButtonText: String? = nil,
                     okButtonText: String? = nil,
                     callback: ((_ ok: Bool) -> Void)?) {
        
        let dialog = SimpleOkCancelDialog.instantiate(from: .CustomDialogs)
        dialog.dialogTitle = title
        dialog.message = message
        dialog.cancelButtonText = cancelButtonText
        dialog.okButtonText = okButtonText
        dialog.callback = callback
        
        dialog.modalTransitionStyle = .crossDissolve
        dialog.modalPresentationStyle = .overCurrentContext
        vc.present(dialog, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.dialogTitle
        self.messageLabel.text = self.message
        self.cancelButton.setTitle(self.cancelButtonText ?? LocalizedStrings.cancel, for: .normal)
        self.okButton.setTitle(self.okButtonText ?? LocalizedStrings.ok, for: .normal)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismissView()
        self.callback?(false)
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        self.dismissView()
        self.callback?(true)
    }
}
