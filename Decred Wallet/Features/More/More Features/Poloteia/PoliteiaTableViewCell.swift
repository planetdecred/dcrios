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
    @IBOutlet weak var percentLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var usernameLable: UILabel!
    @IBOutlet weak var commentCountLable: UILabel!
    @IBOutlet weak var timeSinceLable: UILabel!
    @IBOutlet weak var versionLable: UILabel!
    @IBOutlet weak var statusLable: UILabel!
    @IBOutlet weak var statusWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.politeiaBackgroundView.layer.cornerRadius = 5
        self.statusLable.layer.cornerRadius = 5
        self.statusLable.clipsToBounds = true
    }
    
    class var politeiaIdentifier: String {
        return "\(self)"
    }
    
    func displayInfo(_ politeia: Politeia) {
        self.nameLable.text = politeia.name
        self.usernameLable.text = politeia.username
        self.commentCountLable.text = String(format: LocalizedStrings.commentCount, politeia.numcomments)
        let publishAge = Int64(Date().timeIntervalSince1970) - politeia.timestamp
        let publishAgeAsTimeAgo = Utils.timeAgo(timeInterval: publishAge)
        let latestBlockText = String(format: publishAgeAsTimeAgo)
        self.timeSinceLable.text = latestBlockText
        self.versionLable.text = String(format: LocalizedStrings.politeiaVersion, politeia.version)
        self.statusWidthConstraint.constant = politeia.status.description.width(withConstrainedHeight: 14, font: UIFont(name: "SourceSansPro-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)) + 20
        self.statusLable.text = politeia.status.description
        self.statusLable.backgroundColor = self.colorBGStatus(politeia.status)
        
        
//        let bestBlockHeight = bestBlockInfo.height
//        let bestBlockAge = Int64(Date().timeIntervalSince1970) - bestBlockInfo.timestamp
//        let bestBlockAgeAsTimeAgo = Utils.timeAgo(timeInterval: bestBlockAge)
//
//        let latestBlockText = String(format: LocalizedStrings.latestBlockAge, bestBlockHeight, bestBlockAgeAsTimeAgo)
//
//        let bestBlockHeightRange = (latestBlockText as NSString).range(of: "\(bestBlockHeight)")
//        let bestBlockAgeRange = (latestBlockText as NSString).range(of: bestBlockAgeAsTimeAgo)
//
//        let attributedString = NSMutableAttributedString(string: latestBlockText)
//        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                      value: UIColor.appColors.darkBlue,
//                                      range: bestBlockHeightRange)
//        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                      value: UIColor.appColors.darkBlue,
//                                      range: bestBlockAgeRange)
//
//        self.latestBlockLabel.attributedText = attributedString
    }
    
    func colorBGStatus(_ politeiaStatus: PoliteiaStatus) -> UIColor {
        switch politeiaStatus {
        case .NOT_AUTHORIZED:
            return UIColor.appColors.orange
        case .AUTHORIZED:
            return UIColor.appColors.lightBlue
        case .VOTE_STARTED:
            return UIColor.appColors.lightBlue
        case .RESULTAPPROVED:
            return UIColor.appColors.turquoise
        case .NON_EXISTENT:
            return UIColor.appColors.orange
        case .ABANDONED:
            return UIColor.appColors.orange
        default:
            return UIColor.appColors.darkGray
        }
    }
}


//case INVALID = 0
//    case NOT_AUTHORIZED = 1
//    case AUTHORIZED = 2
//    case VOTE_STARTED = 3
//    case RESULTAPPROVED = 4
////    case RESULTREJECT = 4
//    case NON_EXISTENT = 5
//    case ABANDONED = 6
