//
//  FloatingLabelBorderLayer.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class FloatingLabelBorderLayer: CALayer {
    var activeBorderColor: UIColor = UIColor.appColors.lightBlue
    let inactiveBorderColor: UIColor = UIColor.appColors.lightGray

    override init() {
        super.init()
        self.initView()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func initView() {
        self.cornerRadius = 4
        self.borderWidth = 2
        self.setColor()
    }

    func setColor(isParentEditing: Bool = false) {
        self.borderColor = isParentEditing ? self.activeBorderColor.cgColor : self.inactiveBorderColor.cgColor
    }
}
