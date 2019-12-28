//
//  TabMenuItemView.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class TabMenuItemView: UIView {
    let iconView = UIImageView(frame: CGRect.zero)
    
    var topBorderWidth: CGFloat {
        return self.frame.size.width - 20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(for menuItem: MenuItem) {
        self.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.white
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        
        self.display(menuItemIcon: menuItem.icon!)
        self.display(menuItemTitle: menuItem.displayTitle)
    }
    
    func display(menuItemIcon: UIImage) {
        self.iconView.image = menuItemIcon.withRenderingMode(.automatic)
        self.iconView.alpha = 0.5
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.iconView.clipsToBounds = true
        
        self.addSubview(self.iconView)
        
        NSLayoutConstraint.activate([
            self.iconView.heightAnchor.constraint(equalToConstant: 25), // Fixed height for our tab item icon
            self.iconView.widthAnchor.constraint(equalToConstant: 25), // Fixed width for our tab item icon
            self.iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8) // Position icon 8pts from the top
        ])
    }
    
    func display(menuItemTitle: String) {
        let itemTitleLabel = UILabel(frame: CGRect.zero)
        itemTitleLabel.font = UIFont(name: "Source Sans Pro", size: 13)
        itemTitleLabel.text = menuItemTitle
        itemTitleLabel.numberOfLines = 0
        itemTitleLabel.adjustsFontSizeToFitWidth = true
        itemTitleLabel.textColor = UIColor.appColors.darkerGray
        itemTitleLabel.textAlignment = .center
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTitleLabel.clipsToBounds = true
        
        self.addSubview(itemTitleLabel)
        
        NSLayoutConstraint.activate([
            itemTitleLabel.heightAnchor.constraint(equalToConstant: 13), // Fixed height for title label
            itemTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            itemTitleLabel.topAnchor.constraint(equalTo: self.iconView.bottomAnchor, constant: 4) // Position title label 4pts below icon
        ])
    }
    
    // Sets this menu item icon alpha to 1 and adds a top border to this view.
    func activate() {
        self.iconView.alpha = 1.0
        
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.appColors.decredGreen.cgColor
        borderLayer.name = "active border"
        borderLayer.frame = CGRect(x: 10, y: 0, width: topBorderWidth, height: 2)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.layer.addSublayer(borderLayer)
            self.setNeedsLayout()
        })
    }
    
    // Sets this menu item icon alpha to 0.5 and removes the top border previously added to this view.
    func deactivate() {
        self.iconView.alpha = 0.5
        
        let borderLayers = self.layer.sublayers!.filter({ $0.name == "active border" })
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            borderLayers.forEach({ $0.removeFromSuperlayer() })
            self.setNeedsLayout()
        })
    }
}
