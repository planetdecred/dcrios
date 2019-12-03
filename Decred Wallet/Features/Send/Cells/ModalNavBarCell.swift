//
//  WalletChooserNavBarCell.swift
//  Decred Wallet
//
//  Created by kayeli dennis on 03/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

class ModalNavBarCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    var close: (()->Void)?

    @IBAction func cancel(_ sender: UIButton) {
        close?()
    }

    func configure(with title: String, completion: @escaping ()-> Void) {
        titleLabel.text = title
        close = completion
    }
}
