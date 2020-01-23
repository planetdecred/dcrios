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
}
