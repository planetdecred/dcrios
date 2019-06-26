//
//  MenuItemCell
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

open class MenuItemCell: UITableViewCell {
    @IBOutlet weak var activeMenuIndicator: UIView!
    @IBOutlet weak var menuIconImageView: UIImageView!
    @IBOutlet weak var menuTitleLabel: UILabel!
    @IBOutlet weak var menuBackground: UIView!
    
    static let height: CGFloat = 60
    
    class var identifier: String {
        return "\(self)"
    }
    
    func render(_ menuItem: MenuItem, isCurrentItem: Bool = false) {
        self.menuTitleLabel.text = menuItem.displayTitle
        self.menuIconImageView.image = menuItem.icon
        
        if isCurrentItem {
            self.menuBackground.backgroundColor = UIColor.white
            self.activeMenuIndicator.isHidden = false
            self.menuTitleLabel.textColor = UIColor.black
        } else {
            self.menuBackground.backgroundColor = UIColor.appColors.lightOffWhite
            self.activeMenuIndicator.isHidden = true
            self.menuTitleLabel.textColor = UIColor.gray
        }
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.appColors.offWhite
        }
    }
}
