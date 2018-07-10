//  BaseTableViewCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

open class MenuCell : UITableViewCell_Theme {
    class var identifier: String { return String.className(self) }
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var lblMenu: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var backView: UIView_Theme!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppDelegate.shared.theme.backgroundColor
        contentView.backgroundColor = AppDelegate.shared.theme.backgroundColor
    }
    
    open func setup() {
    }
    
    open class func height() -> CGFloat {
        return 60
    }
    
    open func setData(_ data: Any?) {
        //self.backgroundColor = GlobalConstants.Colors.greenishGrey
        
        if let menuText = data as? String {
            self.lblMenu?.text = menuText
            if(menuText == "Overview"){
                self.menuImage?.image = UIImage(named: "overview")
            }
            else if(menuText == "Account"){
                self.menuImage?.image = UIImage(named: "account")
            }
            else if(menuText == "Send"){
                self.menuImage?.image = UIImage(named: "send")
            }
            else if(menuText == "Receive"){
                self.menuImage?.image = UIImage(named: "receive")
            }
            else if(menuText == "Settings"){
                self.menuImage?.image = UIImage(named: "settings")
            }
            else if(menuText == "History"){
                self.menuImage?.image = UIImage(named: "history")
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

