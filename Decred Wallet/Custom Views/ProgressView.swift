//
//  ProgressView.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class ProgressView: UIProgressView {
    // When increasing the height of UIProgressView with constraint, it does not affect the gray background. When you increase it from code with CGAffineTransformMakeScale function, the corner radius messing up. This is a workaround for this problem using UIBezierPath for drawing the rounded rectangle.
    override func layoutSubviews() {
        super.layoutSubviews()

        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4.0)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        layer.mask = maskLayer
    }
}
