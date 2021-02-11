//
//  ImportWatchWalletInput.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

typealias ImportWatchWalletInputDialogCallBack = (_ publicKey: String, _ dialogDelegate: ImportWatchWalletInputDelegate?) -> Void

protocol ImportWatchWalletInputDelegate {
    func dismissDialog()
    func displayError(errorMessage: String)
}

class ImportWatchWalletInput: UIViewController {
    @IBOutlet weak var inputKeyTextField: FloatingPlaceholderTextField!
    @IBOutlet weak var importButton: Button!
    @IBOutlet weak var warningLabel: UILabel!
    
    private var callback: ImportWatchWalletInputDialogCallBack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputKeyTextField.placeholder = "Extended public key"
        self.inputKeyTextField.addTarget(self, action: #selector(self.textFieldEditingChanged), for: .editingChanged)
    }
    
    static func show(sender vc: UIViewController, callback: @escaping ImportWatchWalletInputDialogCallBack) {
        
        let dialog = ImportWatchWalletInput.instantiate(from: .CustomDialogs)
        
        dialog.callback = callback
        dialog.modalPresentationStyle = .pageSheet
        vc.present(dialog, animated: true, completion: nil)
    }
    
    @objc func textFieldEditingChanged() {
        self.importButton.isEnabled = (self.inputKeyTextField.text ?? "").count > 0
        
        if !self.warningLabel.isHidden {
            self.inputKeyTextField.hideError()
            self.warningLabel.isHidden = true
            return
        }
    }
    
    @IBAction func infoButtonTap(_ sender: Any) {
        SimpleAlertDialog.show(sender: self, message: LocalizedStrings.extendPublicKeyInfo, okButtonText: LocalizedStrings.gotIt)
    }
    
    @IBAction func importButtonTap(_ sender: Any) {
        guard let publicKey = self.inputKeyTextField.text, !publicKey.isEmpty else {
            return
        }
        self.callback(publicKey, self)
    }
    
    @IBAction func cancelButtonTap(_ sender: Any) {
        self.dismissView()
    }
}

extension ImportWatchWalletInput: ImportWatchWalletInputDelegate {
    func dismissDialog() {
        self.dismissView()
    }
    
    func displayError(errorMessage: String) {
        self.inputKeyTextField.showError()
        self.warningLabel.becomeFirstResponder()
        self.warningLabel.text = errorMessage
        self.warningLabel.isHidden = false
    }
}
