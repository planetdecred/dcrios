//
//  ImageHeaderView.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class ImageHeaderView : UIView {
    
    @IBOutlet weak var profileImage : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImage.layoutIfNeeded()
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.size.height / 2
        self.profileImage.clipsToBounds = true
       // self.profileImage.layer.borderWidth = 1
        //self.profileImage.layer.borderColor = UIColor.white.cgColor
       // self.profileImage.setRandomDownloadImage(80, height: 80)

    }
}
