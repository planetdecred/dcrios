//
//  FloatingLabelTextInput.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class FloatingLabelTextInput: UITextField {
    let borderWidth: CGFloat = 2
    let activeBorderColor: UIColor = UIColor.appColors.decredBlue
    let inactiveBorderColor: UIColor = UIColor.appColors.lightGray
    let cornerRadius: CGFloat = 4
    var floatingLabel = UIPaddedLabel()
    var button = UIButton(type: .custom)
    let border = CALayer()
    var floatingLabelBottomConstraint:NSLayoutConstraint?
    let floatingLabelBottomPaddingNormal:CGFloat = 33
    let floatingLabelBottomPaddingActive:CGFloat = 8
    let floatingLabelColorNormal:UIColor = UIColor.appColors.bluishGray
    let floatingLabelColorActive:UIColor = UIColor.appColors.decredBlue
    var isInErrorState:Bool = false
    
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
        self.addTarget(self, action: #selector(self.showFloatingLabel), for: .editingDidBegin)
        self.addTarget(self, action: #selector(self.hideFloatingLabel), for: .editingDidEnd)
    }
    
    private func initFloatedLabel() {
        floatingLabel.backgroundColor = UIColor.white
        floatingLabel.textColor = self.floatingLabelColorNormal
        floatingLabel.font = UIFont(name: self.font!.familyName, size: 16)
        floatingLabel.clipsToBounds = true
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        floatingLabel.sizeToFit()
        floatingLabel.leftInset = 4
        floatingLabel.rightInset = 4
        self.floatingLabel.text = self.placeholder
        self.placeholder = ""
        self.addSubview(self.floatingLabel)
        self.floatingLabelBottomConstraint = self.floatingLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: self.floatingLabelBottomPaddingNormal)
        NSLayoutConstraint.activate([
            self.floatingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            floatingLabelBottomConstraint!
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = self.bounds
    }
    
    func showError() {
        self.isInErrorState = true
        showFloatingLabel()
    }
    
    func hideError() {
        self.isInErrorState = false
        showFloatingLabel()
    }
    
    @objc func showFloatingLabel() {
        border.borderColor = self.isInErrorState ? UIColor.appColors.decredOrange.cgColor : UIColor.appColors.decredBlue.cgColor
        UIView.animate(withDuration: 0.13) {
            self.floatingLabelBottomConstraint?.constant = self.floatingLabelBottomPaddingActive
            self.floatingLabel.textColor = self.isInErrorState ? UIColor.appColors.decredOrange : self.floatingLabelColorActive
            self.floatingLabel.font = UIFont(name: self.font!.familyName, size: 14)
            self.layoutIfNeeded()
        }
    }
    
    @objc func hideFloatingLabel() {
        border.borderColor = self.inactiveBorderColor.cgColor
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
}
