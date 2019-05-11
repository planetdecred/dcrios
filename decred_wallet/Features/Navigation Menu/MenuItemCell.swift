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
    
//    open class func height() -> CGFloat {
//        return 60
//    }
//    class var identifier: String {
//        return "\(self)"
//    }
    open func setData(_ data: Any?) {
//        if let menuText = data as? String {
//            self.lblMenu?.text = menuText
//            if (menuText == "Overview") {
//                self.menuImage?.image = UIImage(named: "overview")
//            } else if (menuText == "Accounts") {
//                self.menuImage?.image = UIImage(named: "menu-account")
//            } else if (menuText == "Send") {
//                self.menuImage?.image = UIImage(named: "send")
//            } else if (menuText == "Receive") {
//                self.menuImage?.image = UIImage(named: "receive")
//            } else if (menuText == "Settings") {
//                self.menuImage?.image = UIImage(named: "settings")
//            } else if (menuText == "Security") {
//                self.imageView?.image = UIImage(named: "security")
//            } else if (menuText == "History") {
//                self.menuImage?.image = UIImage(named: "history")
//            } else if (menuText == "Help") {
//                self.menuImage?.image = UIImage(named: "help")
//            }
//        }
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor(hex: "#FFFFFF")
        } else {
            self.backgroundColor = UIColor(hex: "#F9FAFA")
        }
    }
}
