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
    
    @IBOutlet weak var dialogViewBottomConstraint: NSLayoutConstraint!

    private var dialogTitle: String!
    private var placeholder: String!
    private var currentValue: String!
    private var cancelButtonText: String?
    private var submitButtonText: String?
    private var callback: SimpleTextInputDialogCallback!
    
    static func show(sender vc: UIViewController,
                     title: String,
                     placeholder: String,
                     currentValue: String = "",
                     cancelButtonText: String? = nil,
                     submitButtonText: String? = nil,
                     callback: @escaping SimpleTextInputDialogCallback) {
        
        let dialog = SimpleTextInputDialog.instantiate(from: .CustomDialogs)
        dialog.dialogTitle = title
        dialog.placeholder = placeholder
        dialog.currentValue = currentValue
        dialog.cancelButtonText = cancelButtonText
        dialog.submitButtonText = submitButtonText
        dialog.callback = callback
        
        dialog.modalPresentationStyle = .pageSheet
        vc.present(dialog, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.dialogTitle
        self.textField.placeholder = self.placeholder
        self.cancelButton.setTitle(self.cancelButtonText ?? LocalizedStrings.cancel, for: .normal)
        self.submitButton.setTitle(self.submitButtonText ?? LocalizedStrings.ok, for: .normal)
        
        self.textField.addTarget(self, action: #selector(self.textFieldEditingChanged), for: .editingChanged)
        self.textField.delegate = self
        self.textField.becomeFirstResponder()
        
        self.listenForKeyboardVisibilityChanges(delegate: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.text = self.currentValue
    }
    
    @objc func textFieldEditingChanged() {
        self.submitButton.isEnabled = (self.textField.text ?? "").count > 0
        
        if !self.inputErrorLabel.isHidden {
            self.textField.hideError()
            self.inputErrorLabel.isHidden = true
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        self.submitUserInput()
    }
    
    func submitUserInput() {
        guard let userInput = self.textField.text, !userInput.isEmpty else {
            return
        }
        
        self.callback(userInput, self)
    }
}

extension SimpleTextInputDialog: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.submitUserInput()
        return true
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

extension SimpleTextInputDialog: KeyboardVisibilityDelegate {
    func onKeyboardWillShowOrHide(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0

            let keyboardAnimationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: keyboardAnimationDuration.doubleValue) {
                    if endFrameY >= UIScreen.main.bounds.size.height {
                        self.dialogViewBottomConstraint?.constant = 0.0
                    } else {
                        self.dialogViewBottomConstraint?.constant = endFrame?.size.height ?? 0.0
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}
