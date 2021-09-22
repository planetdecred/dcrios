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
    func displayPassphraseError(errorMessage: String)
}

extension InputDialogDelegate {
    func displayPassphraseError(errorMessage: String) {
        
    }
}

class SimpleTextInputDialog: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: FloatingPlaceholderTextField! // rename!
    @IBOutlet weak var inputErrorLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: Button!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var noticeTitle: UILabel!
    @IBOutlet weak var noticeIcon: UIButton!
    
    @IBOutlet weak var dialogViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldTopTitleConstrant: NSLayoutConstraint!
    
    private var dialogTitle: String!
    private var placeholder: String!
    private var currentValue: String!
    private var cancelButtonText: String?
    private var submitButtonText: String?
    private var verifyInput: Bool!
    private var showInfoButton: Bool!
    private var infoText: String!
    private var noticeText: String = ""
    private var showNoticeIcon: Bool = false
    private var callback: SimpleTextInputDialogCallback!
    
    static func show(sender vc: UIViewController,
                     title: String,
                     placeholder: String,
                     currentValue: String = "",
                     cancelButtonText: String? = nil,
                     submitButtonText: String? = nil,
                     verifyInput: Bool = false,
                     showInfoButton: Bool = false,
                     infoText: String = "",
                     noticeText: String = "",
                     showNoticeIcon: Bool = false,
                     callback: @escaping SimpleTextInputDialogCallback) {
        
        let dialog = SimpleTextInputDialog.instantiate(from: .CustomDialogs)
        dialog.dialogTitle = title
        dialog.placeholder = placeholder
        dialog.currentValue = currentValue
        dialog.cancelButtonText = cancelButtonText
        dialog.submitButtonText = submitButtonText
        dialog.verifyInput = verifyInput
        dialog.callback = callback
        dialog.showInfoButton = showInfoButton
        dialog.infoText = infoText
        dialog.showNoticeIcon = showNoticeIcon
        dialog.noticeText = noticeText
        
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
        self.infoButton.isHidden = !self.showInfoButton
        self.noticeIcon.isHidden = !self.showNoticeIcon
        if !self.noticeText.isEmpty {
            self.noticeTitle.text = self.noticeText
            self.noticeTitle.isHidden = false
            self.textFieldTopTitleConstrant.constant = 70
        } else {
            self.noticeTitle.isHidden = true
            self.textFieldTopTitleConstrant.constant = 25
        }
        
        self.textField.updateConstraintsIfNeeded()
        
        self.listenForKeyboardVisibilityChanges(delegate: self)
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.verifyInput {
            self.textField.text = self.currentValue.trimmingCharacters(in: .whitespaces)
        }
    }
    
    @objc func textFieldEditingChanged() {
        self.submitButton.isEnabled = self.verifyInput ? self.currentValue.trimmingCharacters(in: .whitespaces) == self.textField.text?.trimmingCharacters(in: .whitespaces)  : (self.textField.text?.trimmingCharacters(in: .whitespaces) ?? "").count > 0
        
        if !self.inputErrorLabel.isHidden {
            self.textField.hideError()
            self.inputErrorLabel.isHidden = true
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        self.submitButton.startLoading()
        self.submitUserInput()
    }
    
    func submitUserInput() {
        guard let userInput = self.textField.text?.trimmingCharacters(in: .whitespaces), !userInput.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        self.callback(userInput, self)
    }
    @IBAction func infoButtonTapped(_ sender: Any) {
        SimpleAlertDialog.show(sender: self, message: infoText, okButtonText: LocalizedStrings.gotIt, callback: nil)
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
