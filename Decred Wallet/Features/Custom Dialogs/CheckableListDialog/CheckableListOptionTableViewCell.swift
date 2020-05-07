//
//  CheckableListOptionTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class CheckableListOptionTableViewCell: UITableViewCell {
    @IBOutlet weak private var checkIconImageView: UIImageView!
    @IBOutlet weak private var optionLabel: UILabel!
    
    override class func height() -> CGFloat {
        return 46
    }
    
    func set(optionTitle: String, isOptionSelected: Bool) {
        self.optionLabel.text = optionTitle
        self.checkIconImageView.image = isOptionSelected ? UIImage(named: "ic_checkmark") : nil
    }
}
