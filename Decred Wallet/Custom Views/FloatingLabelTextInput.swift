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
    let border = CALayer()
    let borderWidth: CGFloat = 2
    var activeBorderColor: UIColor = UIColor.appColors.decredBlue
    let inactiveBorderColor: UIColor = UIColor.appColors.lightGray
    
    let cornerRadius: CGFloat = 4
    
    var floatingLabel = PaddedLabel()
    var floatingLabelBottomConstraint:NSLayoutConstraint?
    let floatingLabelBottomPaddingNormal:CGFloat = 33
    let floatingLabelBottomPaddingActive:CGFloat = 8
    let floatingLabelColorNormal:UIColor = UIColor.appColors.bluishGray
    var floatingLabelColorActive:UIColor = UIColor.appColors.decredBlue
    
    var button = UIButton(type: .custom)
    
    var isActive:Bool = false
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
        border.cornerRadius = self.cornerRadius
        border.borderColor = self.inactiveBorderColor.cgColor
        border.borderWidth = self.borderWidth
        self.layer.addSublayer(border)
        
        self.initFloatedLabel()
        self.addTarget(self, action: #selector(self.editingBegan), for: .editingDidBegin)
        self.addTarget(self, action: #selector(self.editingEnded), for: .editingDidEnd)
    }
    
    private func initFloatedLabel() {
        self.floatingLabel.backgroundColor = UIColor.white
        self.floatingLabel.textColor = self.floatingLabelColorNormal
        self.floatingLabel.font = UIFont(name: self.font!.familyName, size: 16)
        self.floatingLabel.clipsToBounds = true
        self.floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.floatingLabel.sizeToFit()
        self.floatingLabel.leftPadding = 4
        self.floatingLabel.rightPadding = 4
        self.floatingLabel.text = self.placeholder
        self.placeholder = ""
        self.addSubview(self.floatingLabel)
        self.floatingLabelBottomConstraint = self.floatingLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: self.floatingLabelBottomPaddingNormal)
        NSLayoutConstraint.activate([
            self.floatingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            self.floatingLabelBottomConstraint!
        ])
    }
    
    func setPlaceHolder(text:String) {
        self.floatingLabel.text = text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = self.bounds
    }
    
    @objc func editingBegan() {
        self.isActive = true
        border.borderColor = self.activeBorderColor.cgColor
        self.showFloatingLabel()
    }
    
    @objc func editingEnded() {
        self.isActive = false
        border.borderColor = self.inactiveBorderColor.cgColor
        self.hideFloatingLabel()
    }
    
    func showError() {
        self.activeBorderColor = UIColor.appColors.decredOrange
        self.floatingLabelColorActive = UIColor.appColors.decredOrange
        self.setBorderAndFloatingLabelColor()
    }
    
    func hideError() {
        self.activeBorderColor = UIColor.appColors.decredBlue
        self.floatingLabelColorActive = UIColor.appColors.decredBlue
        self.setBorderAndFloatingLabelColor()
    }
    
    private func setBorderAndFloatingLabelColor() {
        if self.isActive {
            border.borderColor = self.activeBorderColor.cgColor
            self.floatingLabel.textColor = self.floatingLabelColorActive
        } else {
            border.borderColor = self.inactiveBorderColor.cgColor
            self.floatingLabel.textColor = self.floatingLabelColorNormal
        }
    }
    
    func showFloatingLabel() {
        UIView.animate(withDuration: 0.13) {
            self.floatingLabelBottomConstraint?.constant = self.floatingLabelBottomPaddingActive
            self.floatingLabel.textColor = self.floatingLabelColorActive
            self.floatingLabel.font = UIFont(name: self.font!.familyName, size: 14)
            self.layoutIfNeeded()
        }
    }
    
    @objc func hideFloatingLabel() {
        if self.text == "" {
            UIView.animate(withDuration: 0.13) {
                self.floatingLabelBottomConstraint?.constant = self.floatingLabelBottomPaddingNormal
                self.floatingLabel.textColor = self.floatingLabelColorNormal
                self.floatingLabel.font = UIFont(name: self.font!.familyName, size: 16)
                self.layoutIfNeeded()
            }
        } else {
            self.floatingLabel.textColor = self.floatingLabelColorNormal
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
