//
//  FloatingPlaceholderBorderLayer.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class FloatingPlaceholderBorderLayer: CALayer {
    var activeBorderColor: UIColor = UIColor.appColors.primary
    let inactiveBorderColor: UIColor = UIColor.appColors.lightGray

    override init() {
        super.init()
        self.initView()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        self.initView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initView()
    }

    func initView() {
        self.cornerRadius = 4
        self.borderWidth = 2
        self.changeBorderColor()
    }

    func changeBorderColor(acitve: Bool = false) {
        self.borderColor = acitve ? self.activeBorderColor.cgColor : self.inactiveBorderColor.cgColor
    }
}
