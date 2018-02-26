//
//  ImageHeaderView.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 10/02/2018.
//  Copyright © 2018 Macsleven. All rights reserved.
//

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
