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
    
    var floatingPlaceholderLabel = PaddedLabel()
    var placeholderLabelBottomConstraint:NSLayoutConstraint?
    let placeholderLabelDefaultYPos:CGFloat = 33
    let placeholderLabelFloatingYPos:CGFloat = 8
    let placeholderColorNormal:UIColor = UIColor.appColors.bluishGray
    var placeholderColorActive:UIColor = UIColor.appColors.decredBlue
    
    var button = UIButton(type: .custom)
    
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    
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
        self.floatingPlaceholderLabel.font = UIFont(name: self.font!.familyName, size: 16)
        self.floatingPlaceholderLabel.clipsToBounds = true
        self.floatingPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.floatingPlaceholderLabel.sizeToFit()
        self.floatingPlaceholderLabel.leftPadding = 4
        self.floatingPlaceholderLabel.rightPadding = 4
        self.floatingPlaceholderLabel.text = self.placeholder
        self.placeholder = ""
        self.addSubview(self.floatingPlaceholderLabel)
        
        self.placeholderLabelBottomConstraint = self.floatingPlaceholderLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: self.placeholderLabelDefaultYPos)
        NSLayoutConstraint.activate([
            self.floatingPlaceholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            self.placeholderLabelBottomConstraint!
        ])
    }
    
    override var placeholder: String? {
        didSet {
            if placeholder != oldValue {
                self.floatingPlaceholderLabel.text = oldValue
                placeholder = ""
            }
        }
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
            self.placeholderLabelBottomConstraint?.constant = self.placeholderLabelFloatingYPos
            self.floatingPlaceholderLabel.textColor = self.placeholderColorActive
            self.floatingPlaceholderLabel.font = UIFont(name: self.font!.familyName, size: 14)
            self.layoutIfNeeded()
        }
    }
    
    func hideFloatingLabel() {
        if self.text == "" {
            UIView.animate(withDuration: 0.13) {
                self.placeholderLabelBottomConstraint?.constant = self.placeholderLabelDefaultYPos
                self.floatingPlaceholderLabel.textColor = self.placeholderColorNormal
                self.floatingPlaceholderLabel.font = UIFont(name: self.font!.familyName, size: 16)
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
    
    func addViewPasswordButton() {
        self.button.setImage(UIImage(named: "ic_reveal"), for: .normal)
        self.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        self.button.frame = CGRect(x: CGFloat(self.frame.size.width - 22), y: CGFloat(16), width: CGFloat(22), height: CGFloat(16))
        rightView = button
        rightViewMode = .always
        self.button.addTarget(self, action: #selector(self.enablePasswordVisibilityToggle), for: .touchUpInside)
    }
    
    @objc func enablePasswordVisibilityToggle() {
        isSecureTextEntry.toggle()
        if isSecureTextEntry{
            self.button.setImage(UIImage(named: "ic_reveal"), for: .normal)
        } else {
            self.button.setImage(UIImage(named: "ic_conceal"), for: .normal)
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }
}
