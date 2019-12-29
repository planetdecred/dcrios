//
//  SimpleInfoTableViewCell.swift
//  Decred Wallet
//
//  Created by kayeli dennis on 03/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

class SimpleInfoTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!

    func configureWith(title: String?, and informtion: String?) {
        titleLabel.text = title
        infoLabel.text = informtion
    }
}
