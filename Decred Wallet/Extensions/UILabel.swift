//
//  UILabel.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

extension UILabel {
    
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }


    @IBInspectable var xibLocalizedStringKey: String? {
        get { return nil }
        set(key) {
            self.text = NSLocalizedString(key!, comment: "")
            self.setNeedsLayout()
        }
    }
        
    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

