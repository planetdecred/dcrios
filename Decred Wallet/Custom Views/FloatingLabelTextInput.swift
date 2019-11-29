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
    @IBInspectable var borderWidth: CGFloat = 2 {
        didSet {
            self.layer.borderWidth = self.borderWidth
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var activeBorderColor: UIColor = UIColor.appColors.decredBlue
    @IBInspectable var inactiveBorderColor: UIColor = UIColor.appColors.lightGray
    
    @IBInspectable var cornerRadius: CGFloat = 4 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var floatingLabelColor: UIColor = UIColor.appColors.decredBlue {
        didSet {
            self.floatingLabel.textColor = floatingLabelColor
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var floatingLabelFont: UIFont = UIFont(name: "Source Sans Pro", size: 14)! {
        didSet {
            self.floatingLabel.font = floatingLabelFont
            self.setNeedsLayout()
        }
    }
    
    lazy var floatingLabel: UILabel = {
        let floatingLabel = UILabel(frame: self.frame)
        floatingLabel.backgroundColor = UIColor.white
        floatingLabel.textColor = floatingLabelColor
        floatingLabel.font = floatingLabelFont
        floatingLabel.clipsToBounds = true
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        floatingLabel.sizeToFit()
        return floatingLabel
    }()
    
    var button = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }
    
    private func initView() {
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderColor = self.inactiveBorderColor.cgColor
        self.layer.borderWidth = self.borderWidth
        
        self.addTarget(self, action: #selector(self.editingBegan), for: .editingDidBegin)
        self.addTarget(self, action: #selector(self.editingEnded), for: .editingDidEnd)
        
        if self.text != "" {
            self.showFloatingLabel()
        }
    }
    
    @objc func editingBegan() {
        self.layer.borderColor = UIColor.appColors.decredBlue.cgColor
        self.showFloatingLabel()
    }
    
    @objc func editingEnded() {
        self.layer.borderColor = self.inactiveBorderColor.cgColor
        self.hideFloatingLabel()
    }
    
    func showFloatingLabel() {
        if self.placeholder == "" {
            // floating label already visible on view or
            // no text to display in floating label
            return
        }
        
        self.floatingLabel.text = self.placeholder
        self.placeholder = ""
        
        let constraints = [
            self.floatingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            self.floatingLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: 8),
        ]
        
        UIView.animate(withDuration: 4.0) {
            self.addSubview(self.floatingLabel)
            NSLayoutConstraint.activate(constraints)
            self.setNeedsLayout()
        }
    }
    
    func hideFloatingLabel() {
        if self.text != "" {
            return
        }
        
        self.placeholder = self.floatingLabel.text
        
        UIView.animate(withDuration: 0.13) {
            self.subviews.first(where: { $0 is UILabel })?.removeFromSuperview()
            self.setNeedsLayout()
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
