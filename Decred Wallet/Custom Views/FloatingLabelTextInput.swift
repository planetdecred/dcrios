//
//  FloatingLabelTextInput.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class FloatingLabelTextInput: UITextField {
    let borderLayer = CALayer()
    let borderWidth: CGFloat = 2
    var activeBorderColor: UIColor = UIColor.appColors.decredBlue
    let inactiveBorderColor: UIColor = UIColor.appColors.lightGray
    
    let cornerRadius: CGFloat = 4
    let floatingPlaceholderLabelNormalSize: CGFloat = 16
    let floatingPlaceholderLabelSmallerSize: CGFloat = 14
    
    var floatingPlaceholderLabel = PaddedLabel()
    var placeholderLabelTopConstraint: NSLayoutConstraint?
    let placeholderColorNormal: UIColor = UIColor.appColors.bluishGray
    var placeholderColorActive: UIColor = UIColor.appColors.decredBlue
    
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
        borderLayer.cornerRadius = self.cornerRadius
        borderLayer.borderColor = self.inactiveBorderColor.cgColor
        borderLayer.borderWidth = self.borderWidth
        self.layer.addSublayer(borderLayer)
        
        self.initFloatingPlaceholderLabel()
        
        self.addTarget(self, action: #selector(self.editingBegan), for: .editingDidBegin)
        self.addTarget(self, action: #selector(self.editingEnded), for: .editingDidEnd)
    }
    
    private func initFloatingPlaceholderLabel() {
        self.floatingPlaceholderLabel.backgroundColor = UIColor.white
        self.floatingPlaceholderLabel.textColor = self.placeholderColorNormal
        self.floatingPlaceholderLabel.font = self.floatingPlaceholderLabel.font.withSize(self.floatingPlaceholderLabelNormalSize)
        self.floatingPlaceholderLabel.clipsToBounds = true
        self.floatingPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.floatingPlaceholderLabel.leftPadding = 4
        self.floatingPlaceholderLabel.rightPadding = 4
        self.floatingPlaceholderLabel.text = self.placeholder
        self.placeholder = ""
        self.floatingPlaceholderLabel.sizeToFit()
        self.addSubview(self.floatingPlaceholderLabel)
        
        self.placeholderLabelTopConstraint = self.floatingPlaceholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: (self.frame.size.height - self.floatingPlaceholderLabel.intrinsicContentSize.height) / 2)
        NSLayoutConstraint.activate([
            self.floatingPlaceholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            self.placeholderLabelTopConstraint!
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = self.bounds
    }
    
    @objc func editingBegan() {
        borderLayer.borderColor = self.activeBorderColor.cgColor
        self.showFloatingLabel()
    }
    
    @objc func editingEnded() {
        borderLayer.borderColor = self.inactiveBorderColor.cgColor
        self.hideFloatingLabel()
    }
    
    func showFloatingLabel() {
        UIView.animate(withDuration: 0.13) {
            self.floatingPlaceholderLabel.textColor = self.placeholderColorActive
            self.floatingPlaceholderLabel.font = self.floatingPlaceholderLabel.font.withSize(self.floatingPlaceholderLabelSmallerSize)
            self.placeholderLabelTopConstraint?.constant = self.floatingPlaceholderLabel.intrinsicContentSize.height / -2
            self.layoutIfNeeded()
        }
    }
    
    func hideFloatingLabel() {
        if self.text == "" {
            UIView.animate(withDuration: 0.13) {
                self.floatingPlaceholderLabel.textColor = self.placeholderColorNormal
                self.floatingPlaceholderLabel.font = self.floatingPlaceholderLabel.font.withSize(self.floatingPlaceholderLabelNormalSize)
                self.placeholderLabelTopConstraint?.constant = (self.frame.size.height - self.floatingPlaceholderLabel.intrinsicContentSize.height) / 2
                self.layoutIfNeeded()
            }
        } else {
            self.floatingPlaceholderLabel.textColor = self.placeholderColorNormal
        }
    }
    
    func showError() {
        self.activeBorderColor = UIColor.appColors.decredOrange
        self.placeholderColorActive = UIColor.appColors.decredOrange
        self.setBorderAndFloatingLabelColor()
    }
    
    func hideError() {
        self.activeBorderColor = UIColor.appColors.decredBlue
        self.placeholderColorActive = UIColor.appColors.decredBlue
        self.setBorderAndFloatingLabelColor()
    }
    
    private func setBorderAndFloatingLabelColor() {
        if self.isEditing {
            borderLayer.borderColor = self.activeBorderColor.cgColor
            self.floatingPlaceholderLabel.textColor = self.placeholderColorActive
        } else {
            borderLayer.borderColor = self.inactiveBorderColor.cgColor
            self.floatingPlaceholderLabel.textColor = self.placeholderColorNormal
        }
    }
    
    func addTogglePasswordVisibilityButton() {
        self.pwdVisibilityToggleBtn.setImage(UIImage(named: "ic_reveal"), for: .normal)
        self.pwdVisibilityToggleBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        self.pwdVisibilityToggleBtn.frame = CGRect(x: CGFloat(self.frame.size.width - 22), y: CGFloat(16), width: CGFloat(22), height: CGFloat(16))
        self.rightView = pwdVisibilityToggleBtn
        self.rightViewMode = .always
        self.pwdVisibilityToggleBtn.addTarget(self, action: #selector(self.enablePasswordVisibilityToggle), for: .touchUpInside)
    }
    
    @objc func enablePasswordVisibilityToggle() {
        isSecureTextEntry.toggle()
        if isSecureTextEntry {
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
