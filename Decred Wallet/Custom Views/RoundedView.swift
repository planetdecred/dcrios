//
//  RoundedView.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class RoundedView: UIView {
    @IBInspectable var borderRadius: CGFloat = 14 {
        didSet {
            self.layer.cornerRadius = self.borderRadius
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            self.redrawDropShadow()
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.4 {
        didSet {
            self.redrawDropShadow()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            self.redrawDropShadow()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 16 {
        didSet {
            self.redrawDropShadow()
        }
    }
    
    @IBInspectable var shadowSpread: CGFloat = 0 {
        didSet {
            self.redrawDropShadow()
        }
    }
    
    func redrawDropShadow() {
        self.dropShadow2(color: self.shadowColor,
                         opacity: self.shadowOpacity,
                         offset: self.shadowOffset,
                         radius: self.shadowRadius,
                         spread: self.shadowSpread)

        self.setNeedsDisplay()
    }
}
