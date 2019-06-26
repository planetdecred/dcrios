//
//  UILabel.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
extension UILabel {
    @IBInspectable var xibLocalizedStringKey: String? {
        get { return nil }
        set(key) {
            self.text = NSLocalizedString(key!, comment: "")
            self.setNeedsLayout()
        }
    }
}

