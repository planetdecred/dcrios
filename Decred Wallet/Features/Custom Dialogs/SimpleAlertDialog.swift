//
//  SimpleAlertDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SimpleAlertDialog: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okBtn: Button!
    @IBOutlet weak var warningTextLabel: UILabel!
    @IBOutlet weak var alertIcon: UIImageView!
    
    private var dialogTitle: String!
    private var message: String!
    private var attribMessage: NSAttributedString!
    private var warningText:String!
    private var okButtonText: String?
    private var hideAlertIcon: Bool!
    private var callback: ((_ ok: Bool) -> Void)?
    
    static func show(sender vc: UIViewController,
                     title: String? = nil,
                     message: String? = nil,
                     warningText: String? = nil,
                     cancelButtonText: String? = nil,
                     okButtonText: String? = nil,
                     hideAlertIcon: Bool? = true,
                     callback: ((_ ok: Bool) -> Void)?) {
        
        let dialog = SimpleAlertDialog.instantiate(from: .CustomDialogs)
        dialog.dialogTitle = title
        dialog.message = message
        dialog.warningText = warningText
        dialog.okButtonText = okButtonText
        dialog.hideAlertIcon = hideAlertIcon
        dialog.callback = callback
        
        dialog.modalTransitionStyle = .crossDissolve
        dialog.modalPresentationStyle = .overCurrentContext
        vc.present(dialog, animated: true, completion: nil)
    }
    
    static func show(sender vc: UIViewController,
                     title: String? = nil,
                     attribMessage: NSAttributedString? = nil,
                     warningText: String? = nil,
                     cancelButtonText: String? = nil,
                     okButtonText: String? = nil,
                     hideAlertIcon: Bool? = true,
                     callback: ((_ ok: Bool) -> Void)?) {
        
        let dialog = SimpleAlertDialog.instantiate(from: .CustomDialogs)
        dialog.dialogTitle = title
        dialog.attribMessage = attribMessage
        dialog.warningText = warningText
        dialog.okButtonText = okButtonText
        dialog.hideAlertIcon = hideAlertIcon
        dialog.callback = callback
        
        dialog.modalTransitionStyle = .crossDissolve
        dialog.modalPresentationStyle = .overFullScreen
        vc.present(dialog, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.dialogTitle
        if self.message != nil {
            self.messageLabel.text = message
        }
        
        if self.attribMessage != nil {
            self.messageLabel.attributedText = self.attribMessage
        }
        self.warningTextLabel.text = self.warningText
        self.okBtn.setTitle(self.okButtonText ?? LocalizedStrings.ok, for: .normal)
        self.alertIcon.isHidden = self.hideAlertIcon
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        self.dismissView()
        self.callback?(true)
    }
}
