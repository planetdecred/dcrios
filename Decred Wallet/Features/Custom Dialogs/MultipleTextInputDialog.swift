//
//  MultipleTextInputDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

typealias MultipleTextInputDialogCallback = (_ userName: String, _ userPass: String, _ dialogDelegate: MultipleInputDialogDelegate?) -> Void

protocol MultipleInputDialogDelegate {
    func dismissDialog()
    func displayError(errorMessage: String)
}

class MultipleTextInputDialog: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userName: FloatingPlaceholderTextField!
    @IBOutlet weak var userPass: FloatingPlaceholderTextField!
    @IBOutlet weak var inputErrorLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: Button!
    
    @IBOutlet weak var dialogViewBottomConstraint: NSLayoutConstraint!

    private var dialogTitle: String!
    private var userNamePlaceholder: String!
    private var userPassPlaceholder: String!
    private var cancelButtonText: String?
    private var submitButtonText: String?
    private var callback: MultipleTextInputDialogCallback!
    
    static func show(sender vc: UIViewController,
                     title: String,
                     userNamePlaceholder: String,
                     userPassPlaceholder: String,
                     cancelButtonText: String? = nil,
                     submitButtonText: String? = nil,
                     callback: @escaping MultipleTextInputDialogCallback) {
        
        let dialog = MultipleTextInputDialog.instantiate(from: .CustomDialogs)
        dialog.dialogTitle = title
        dialog.userNamePlaceholder = userNamePlaceholder
        dialog.userPassPlaceholder = userPassPlaceholder
        dialog.cancelButtonText = cancelButtonText
        dialog.submitButtonText = submitButtonText
        dialog.callback = callback
        
        dialog.modalPresentationStyle = .pageSheet
        vc.present(dialog, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.dialogTitle
        self.userName.placeholder = self.userNamePlaceholder
        self.userPass.placeholder = self.userPassPlaceholder
        self.cancelButton.setTitle(self.cancelButtonText ?? LocalizedStrings.cancel, for: .normal)
        self.submitButton.setTitle(self.submitButtonText ?? LocalizedStrings.ok, for: .normal)
        
        self.userName.addTarget(self, action: #selector(self.textFieldEditingChanged), for: .editingChanged)
        self.userPass.addTarget(self, action: #selector(self.textFieldEditingChanged), for: .editingChanged)
        self.userName.delegate = self
        self.userPass.delegate = self
        self.userName.becomeFirstResponder()
        
        self.listenForKeyboardVisibilityChanges(delegate: self)
    }
    
    @objc func textFieldEditingChanged() {
        self.submitButton.isEnabled = (self.userName.text ?? "").count > 0 && (self.userPass.text ?? "").count > 0
        
        if !self.inputErrorLabel.isHidden {
            self.userName.hideError()
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
        guard let userName = self.userName.text, !userName.isEmpty else {
            return
        }
        
        guard let userPass = self.userPass.text, !userPass.isEmpty else {
            return
        }
        
        self.callback(userName, userPass, self)
    }
}

extension MultipleTextInputDialog: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.submitUserInput()
        return true
    }
}

extension MultipleTextInputDialog: MultipleInputDialogDelegate {
    func dismissDialog() {
        self.dismissView()
    }
    
    func displayError(errorMessage: String) {
        self.userName.showError()
        self.userName.becomeFirstResponder()
        
        self.inputErrorLabel.text = errorMessage
        self.inputErrorLabel.isHidden = false
        
        self.cancelButton?.isEnabled = true
        self.submitButton.isEnabled = true
        self.submitButton.stopLoading()
    }
}

extension MultipleTextInputDialog: KeyboardVisibilityDelegate {
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
