//
//  PoliteiaTableViewCell.swift
//  Decred Wallet
//
// Copyright © 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class PoliteiaTableViewCell: UITableViewCell {
    @IBOutlet weak var politeiaBackgroundView: UIView!
    @IBOutlet weak var percentView: PlainHorizontalProgressBar!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var timeSinceLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.politeiaBackgroundView.layer.cornerRadius = 5
        self.statusLabel.layer.cornerRadius = 5
        self.statusLabel.clipsToBounds = true
    }
    
    class var politeiaIdentifier: String {
        return "\(self)"
    }
    
    func displayInfo(_ politeia: Politeia) {
        self.nameLabel.text = politeia.name
        self.usernameLabel.text = politeia.username
        self.commentCountLabel.text = String(format: LocalizedStrings.commentCount, politeia.numcomments)
        let publishAge = Int64(Date().timeIntervalSince1970) - politeia.timestamp
        let publishAgeAsTimeAgo = Utils.timeAgo(timeInterval: publishAge)
        self.timeSinceLabel.text = String(format: publishAgeAsTimeAgo)
        self.versionLabel.text = String(format: LocalizedStrings.politeiaVersion, politeia.version)
        self.statusWidthConstraint.constant = politeia.status.description.width(withConstrainedHeight: 14, font: UIFont(name: "SourceSansPro-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)) + 20
        self.statusLabel.text = politeia.status.description
        self.statusLabel.backgroundColor = Utils.politeiaColorBGStatus(politeia.status)
        self.percentView.setProgress(Float(politeia.yesPercent), animated: false)
        self.percentLabel.text = "\((politeia.yesPercent).round(decimals: 2))%"
        self.percentLabel.superview?.bringSubviewToFront(self.percentLabel)
    }
}
