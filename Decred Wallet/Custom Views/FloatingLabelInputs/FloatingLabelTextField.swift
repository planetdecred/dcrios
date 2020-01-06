//
//  FloatingLabelTextField.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class FloatingLabelTextField: UITextField {
    let borderLayer = FloatingLabelBorderLayer()
    let floatingPlaceholderLabel = FloatingLabelPlaceholder()

    lazy var pwdVisibilityToggleBtn: UIButton = {
        return UIButton(type: .custom)
    }()

    let textPadding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

    override var placeholder: String? {
        didSet {
            // compare new placeholder value against previous value to prevent recursion
            if placeholder != oldValue {
                self.floatingPlaceholderLabel.text = oldValue
                placeholder = ""
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }

    private func initView() {
        self.layer.addSublayer(borderLayer)
        self.layer.masksToBounds = false

        self.addSubview(self.floatingPlaceholderLabel)
        self.floatingPlaceholderLabel.text = self.placeholder
        self.placeholder = ""
        self.floatingPlaceholderLabel.setFontAndTopConstraint()

        self.addTarget(self, action: #selector(self.editingBegan), for: .editingDidBegin)
        self.addTarget(self, action: #selector(self.editingEnded), for: .editingDidEnd)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = self.bounds
    }

    @objc func editingBegan() {
        borderLayer.setColor(isParentEditing: self.isEditing)
        self.floatingPlaceholderLabel.parentEditingDidBegin()
    }

    @objc func editingEnded() {
        borderLayer.setColor(isParentEditing: self.isEditing)
        self.floatingPlaceholderLabel.parentEditingDidEnd()
    }

    func showError() {
        self.borderLayer.activeBorderColor = UIColor.appColors.orange
        self.floatingPlaceholderLabel.activeColor = UIColor.appColors.orange
        self.borderLayer.setColor(isParentEditing: self.isEditing)
        self.floatingPlaceholderLabel.setTextColor(isParentEditing: self.isEditing)
    }

    func hideError() {
        self.borderLayer.activeBorderColor = UIColor.appColors.lightBlue
        self.floatingPlaceholderLabel.activeColor = UIColor.appColors.lightBlue
        self.borderLayer.setColor(isParentEditing: self.isEditing)
        self.floatingPlaceholderLabel.setTextColor(isParentEditing: self.isEditing)
    }

    func addTogglePasswordVisibilityButton() {
        self.pwdVisibilityToggleBtn.setImage(UIImage(named: "ic_reveal"), for: .normal)
        self.pwdVisibilityToggleBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        self.pwdVisibilityToggleBtn.frame = CGRect(x: CGFloat(self.frame.size.width - 22), y: CGFloat(16), width: CGFloat(22), height: CGFloat(16))
        self.rightView = self.pwdVisibilityToggleBtn
        self.rightViewMode = .always
        self.pwdVisibilityToggleBtn.addTarget(self, action: #selector(self.enablePasswordVisibilityToggle), for: .touchUpInside)
    }

    @objc func enablePasswordVisibilityToggle() {
        self.isSecureTextEntry.toggle()
        if self.isSecureTextEntry {
            self.pwdVisibilityToggleBtn.setImage(UIImage(named: "ic_reveal"), for: .normal)
        } else {
            self.pwdVisibilityToggleBtn.setImage(UIImage(named: "ic_conceal"), for: .normal)
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: textPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: textPadding)
    }
}

extension FloatingLabelTextField: FloatingLabelProtocol {
    func isParentEmpty() -> Bool {
        return self.text?.isEmpty ?? false
    }
}
