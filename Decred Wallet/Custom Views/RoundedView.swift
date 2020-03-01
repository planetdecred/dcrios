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
    @IBInspectable var roundTopLeftCorner: Bool = true {
        didSet {
            self.setMaskedCorners()
        }
    }
    
    @IBInspectable var roundTopRightCorner: Bool = true {
        didSet {
            self.setMaskedCorners()
        }
    }
    
    @IBInspectable var roundBottomLeftCorner: Bool = true {
        didSet {
            self.setMaskedCorners()
        }
    }
    
    @IBInspectable var roundBottomRightCorner: Bool = true {
        didSet {
            self.setMaskedCorners()
        }
    }
    
    @IBInspectable var borderRadius: CGFloat = 14 {
        didSet {
            self.layer.cornerRadius = self.borderRadius
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            self.layer.borderColor = self.borderColor?.cgColor
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
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
    
    func setMaskedCorners() {
        var maskedCorners: CACornerMask = []
        
        if self.roundTopLeftCorner {
            maskedCorners.insert(.layerMinXMinYCorner)
        }
        if self.roundTopRightCorner {
            maskedCorners.insert(.layerMaxXMinYCorner)
        }
        if self.roundBottomLeftCorner {
            maskedCorners.insert(.layerMinXMaxYCorner)
        }
        if self.roundBottomRightCorner {
            maskedCorners.insert(.layerMaxXMaxYCorner)
        }

        self.layer.maskedCorners = maskedCorners
        self.setNeedsDisplay()
    }
    
    func redrawDropShadow() {
        self.dropShadow(color: self.shadowColor,
                         opacity: self.shadowOpacity,
                         offset: self.shadowOffset,
                         radius: self.shadowRadius,
                         spread: self.shadowSpread)

        self.setNeedsDisplay()
    }
}
