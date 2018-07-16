//
//  BaseTableViewCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

open class BaseTableViewCell : UITableViewCell {
    class var identifier: String { return String.className(self) }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    open override func awakeFromNib() {
    }
    
    open func setup() {
    }
    
    open class func height() -> CGFloat {
        return 48
    }
    
    open func setData(_ data: Any?) {
        self.backgroundColor = GlobalConstants.Colors.greenishGrey
        //self.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
       self.textLabel?.textColor = GlobalConstants.Colors.black
        if let menuText = data as? String {
            self.textLabel?.text = menuText
            if(menuText == "Overview"){
                self.imageView?.image = UIImage(named: "overview")
            }
            else if(menuText == "Account"){
                self.imageView?.image = UIImage(named: "account")
            }
            else if(menuText == "Send"){
                self.imageView?.image = UIImage(named: "send")
            }
            else if(menuText == "Receive"){
                self.imageView?.image = UIImage(named: "receive")
            }
            else if(menuText == "Settings"){
                self.imageView?.image = UIImage(named: "settings")
            }
            else if(menuText == "History"){
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
    override open func setSelected(_ selected: Bool, animated: Bool) {
    }
    
}
