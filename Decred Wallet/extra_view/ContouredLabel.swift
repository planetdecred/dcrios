//
//  ContouredLabel.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class ContouredLabel: UILabel {
    @IBInspectable var borderColor: UIColor = UIColor.appColors.decredBlue {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderRadius: CGFloat = 30 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            setupView()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupView() {
        layer.borderWidth = borderWidth
        layer.cornerRadius = borderRadius
        layer.borderColor = borderColor.cgColor
    }
}
