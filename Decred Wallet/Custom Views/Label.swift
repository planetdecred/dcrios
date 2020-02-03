//
//  Label.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class Label: UILabel {
    @IBInspectable var topPadding: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var bottomPadding: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var rightPadding: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.appColors.lightBlue {
        didSet {
            self.setNeedsDisplay()
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
        setupView()
    }

    fileprivate func setupView() {
        layer.borderWidth = borderWidth
        layer.cornerRadius = borderRadius
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        self.setNeedsDisplay()
    }
    
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        super.drawText(in: rect.inset(by: insets))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftPadding + rightPadding,
         height: size.height + topPadding + bottomPadding)
    }
}
