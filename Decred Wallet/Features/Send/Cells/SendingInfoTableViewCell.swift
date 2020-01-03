//
//  SendingInfoTableViewCell.swift
//  Decred Wallet
//
//  Created by kayeli dennis on 03/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

class SendingInfoTableViewCell: UITableViewCell {

    @IBOutlet var sourceWalletLabel: UILabel!
    @IBOutlet var sendingAmountLabel: UILabel!
    @IBOutlet var destinationAddressLabel: UILabel!

    func configureWith(_ sendingDetails: SendingDetails) {
        sourceWalletLabel.text = "Sending from \(sendingDetails.sourceWallet?.name ?? "")"
        sendingAmountLabel.text = "\(sendingDetails.amount) DCR"
        if sendingDetails.destinationWallet != nil {
            destinationAddressLabel.text = sendingDetails.destinationWallet?.name
        } else {
            destinationAddressLabel.text = sendingDetails.destinationAddress
        }
    }
}
