//
//  BackupVerifyButton.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class BackupVerifyButton: UIButton {
    @IBInspectable var borderColor : UIColor = UIColor.appColors.thinnerGray {
        didSet {
            setupView()
        }
    }

    @IBInspectable var selectedBorderColor : UIColor = UIColor.appColors.decredBlue {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderRadius: CGFloat = 8 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2 {
        didSet {
            setupView()
        }
    }

    override var isSelected: Bool {
        didSet {
            setupView()
        }
    }
    
    fileprivate func setupView() {
        if isSelected {
            layer.borderColor = selectedBorderColor.cgColor
        } else {
            layer.borderColor = borderColor.cgColor
        }
        
        layer.borderWidth = borderWidth
        layer.cornerRadius = borderRadius
        self.setNeedsDisplay()
    }
}
