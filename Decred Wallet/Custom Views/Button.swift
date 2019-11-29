//
//  Button.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class Button: UIButton {
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var normalBackgroundColor: UIColor? {
        didSet {
            self.updateBackgroundColor()
        }
    }
    
    @IBInspectable var disabledBackgroundColor: UIColor? {
        didSet {
            self.updateBackgroundColor()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.updateBackgroundColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initView()
    }
    
    private func initView() {
        if self.normalBackgroundColor == nil {
            self.normalBackgroundColor = self.backgroundColor
        }
        if self.disabledBackgroundColor == nil {
            self.disabledBackgroundColor = self.backgroundColor
        }
        self.updateBackgroundColor()
    }
    
    private func updateBackgroundColor() {
        self.backgroundColor = self.isEnabled ? self.normalBackgroundColor : self.disabledBackgroundColor
        self.setNeedsLayout()
    }
}
