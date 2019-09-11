//
//  BaseTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

open class BaseTableViewCell : UITableViewCell {
    
    class var identifier: String {
        return String.className(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    open override func awakeFromNib() {}
    
    open func setup() {
        self.setData(self)
    }
    
    open class func height() -> CGFloat {
        return 48
    }
    
    open func setData(_ data: Any?) {
        self.backgroundColor = GlobalConstants.Colors.greenishGrey
        self.textLabel?.textColor = GlobalConstants.Colors.black
        
        if let menuText = data as? String {
            self.textLabel?.text = menuText
            if (menuText == LocalizedStrings.overview) {
                self.imageView?.image = UIImage(named: "overview")
            } else if (menuText == LocalizedStrings.wallets) {
                self.imageView?.image = UIImage(named: "account")
            } else if (menuText == LocalizedStrings.send) {
                self.imageView?.image = UIImage(named: "send")
            } else if (menuText == LocalizedStrings.receive) {
                self.imageView?.image = UIImage(named: "receive")
            } else if (menuText == LocalizedStrings.settings) {
                self.imageView?.image = UIImage(named: "settings")
            } else if (menuText == LocalizedStrings.security) {
                self.imageView?.image = UIImage(named: "left")
            } else if (menuText == LocalizedStrings.history) {
                self.imageView?.image = UIImage(named: "history")
            }
        }
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.alpha = 0.4
        } else {
            self.alpha = 1.0
        }
    }
    
    // ignore the default handling
    override open func setSelected(_ selected: Bool, animated: Bool) {}
}
