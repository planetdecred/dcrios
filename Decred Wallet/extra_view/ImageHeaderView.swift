//
//  ImageHeaderView.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

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
