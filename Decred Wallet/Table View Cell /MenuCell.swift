//  BaseTableViewCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

open class MenuCell: UITableViewCell_Theme {
    class var identifier: String { return String.className(self) }
    @IBOutlet var menuImage: UIImageView!
    @IBOutlet var lblMenu: UILabel_DefaultTextColor!
    @IBOutlet var selectedView: UIView!
    @IBOutlet var backView: UIView_Theme!

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
        lblMenu.changeSkin()
    }

    open func setup() {
    }

    open class func height() -> CGFloat {
        return 60
    }

    open func setData(_ data: Any?) {
        // self.backgroundColor = GlobalConstants.Colors.greenishGrey

        if let menuText = data as? String {
            lblMenu?.text = menuText
            if menuText == "Overview" {
                menuImage?.image = UIImage(named: "overview")
            } else if menuText == "Account" {
                menuImage?.image = UIImage(named: "account")
            } else if menuText == "Send" {
                menuImage?.image = UIImage(named: "send")
            } else if menuText == "Receive" {
                menuImage?.image = UIImage(named: "receive")
            } else if menuText == "Settings" {
                menuImage?.image = UIImage(named: "settings")
            } else if menuText == "History" {
                menuImage?.image = UIImage(named: "history")
            }
        }
    }

    open override func setHighlighted(_ highlighted: Bool, animated _: Bool) {
        if highlighted {
            alpha = 0.4
        } else {
            alpha = 1.0
        }
    }

    // ignore the default handling
    open override func setSelected(_: Bool, animated _: Bool) {
    }
}
