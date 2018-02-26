//
//  BaseTableViewCell.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 10/02/2018.
//  Copyright © 2018 Macsleven. All rights reserved.
//

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
        self.backgroundColor = UIColor(hex: "F1F8E9")
        //self.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
       //self.textLabel?.textColor = UIColor(hex: "9E9E9E")
        self.imageView?.image = UIImage(named: "AppIcon")
        if let menuText = data as? String {
            self.textLabel?.text = menuText
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
