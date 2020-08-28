//
//  PoliteiaTableViewCell.swift
//  Decred Wallet
//
//  Created by JustinDo on 8/17/20.
//  Copyright © 2020 Decred. All rights reserved.
//

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
        if let voteStatus = politeia.votestatus {
            self.statusWidthConstraint.constant = voteStatus.status.description.width(withConstrainedHeight: 14, font: UIFont(name: "SourceSansPro-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)) + 20
            self.statusLabel.text = voteStatus.status.description
            self.statusLabel.backgroundColor = Utils.politeiaColorBGStatus(voteStatus.status)
            self.percentView.setProgress(Float(voteStatus.yesPercent), animated: false)
            self.percentLabel.text = "\(voteStatus.yesPercent.round(decimals: 2))%"
            self.percentLabel.superview?.bringSubviewToFront(self.percentLabel)
        }
    }
    
//    func colorBGStatus(_ politeiaStatus: PoliteiaVoteStatus) -> UIColor {
//        switch politeiaStatus {
//        case .NOT_AUTHORIZED:
//            return UIColor.appColors.orange
//        case .AUTHORIZED:
//            return UIColor.appColors.lightBlue
//        case .VOTE_STARTED:
//            return UIColor.appColors.lightBlue
//        case .APPROVED:
//            return UIColor.appColors.turquoise
//        case .REJECT:
//            return UIColor.appColors.orange
//        case .NON_EXISTENT:
//            return UIColor.appColors.orange
//        case .ABANDONED:
//            return UIColor.appColors.orange
//        default:
//            return UIColor.appColors.darkGray
//        }
//    }
}
