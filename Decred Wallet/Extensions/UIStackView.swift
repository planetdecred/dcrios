//
//  UIStackView.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

extension UIStackView {
    // Embed the UIstackiew components in a parent UIview with rounded edges as UIstackview does disregards it's layer.cornerRadius directive
    func cornerRadius(_ radius: CGFloat) {
        // Check if the stackview already has a corner radius providing view embedded
        if self.subviews[0].accessibilityIdentifier == "cornerRadius" {
            return
        }
        // No subviews with matching accessibility identifiers found, create one and embed all
        // child views in it.
        let subView = UIView(frame: bounds)
        subView.accessibilityIdentifier = "cornerRadius" // We give it an ID so we can always check
        subView.backgroundColor = backgroundColor
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
        subView.translatesAutoresizingMaskIntoConstraints = true
        subView.layer.cornerRadius = radius
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
