//
//  SimpleTextInputDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

typealias SimpleTextInputDialogCallback = (_ userInput: String, _ dialogDelegate: InputDialogDelegate?) -> Void

protocol InputDialogDelegate {
    func dismissDialog()
    func displayError(errorMessage: String)
}

class SimpleTextInputDialog: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: FloatingPlaceholderTextField! // rename!
    @IBOutlet weak var inputErrorLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: Button!
    
    private var dialogTitle: String!
    private var placeholder: String!
    private var callback: SimpleTextInputDialogCallback!
    
    static func show(sender vc: UIViewController, dialogTitle: String,
                     placeholder: String,
                     callback: @escaping SimpleTextInputDialogCallback) {
        
        let dialog = SimpleTextInputDialog.instantiate(from: .CustomDialogs)
        dialog.dialogTitle = dialogTitle
        dialog.placeholder = placeholder
        dialog.callback = callback
        
        dialog.modalPresentationStyle = .pageSheet
        vc.present(dialog, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.dialogTitle
        self.textField.placeholder = self.placeholder
        self.textField.addTarget(self, action: #selector(self.textFieldEditingChanged), for: .editingChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.becomeFirstResponder()
    }
    
    @objc func textFieldEditingChanged() {
        if !self.inputErrorLabel.isHidden {
            self.textField.hideError()
            self.inputErrorLabel.isHidden = true
        }
    }
}

extension SimpleTextInputDialog: InputDialogDelegate {
    func dismissDialog() {
        self.dismissView()
    }
    
    func displayError(errorMessage: String) {
        self.textField.showError()
        self.textField.becomeFirstResponder()
        
        self.inputErrorLabel.text = errorMessage
        self.inputErrorLabel.isHidden = false
        
        self.cancelButton?.isEnabled = true
        self.submitButton.isEnabled = true
        self.submitButton.stopLoading()
    }
}
