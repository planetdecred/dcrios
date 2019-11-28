//
//  CustomTabMenuView.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class CustomTabMenuView: UIStackView {
    var itemTapped: ((_ index: Int) -> Void)?
    var activeTabIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(menuItems: [MenuItem], frame: CGRect) {
        self.init(frame: frame)
        self.axis = .horizontal
        self.distribution = .fillEqually
        self.layer.backgroundColor = UIColor.white.cgColor
        
        for menuItem in menuItems {
            let itemView = self.createTabItemButton(for: menuItem)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemView.clipsToBounds = true
            self.addArrangedSubview(itemView)
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.activateTab(viewId: self.activeTabIndex)
    }
    
    // Create a custom nav menu item
    func createTabItemButton(for menuItem: MenuItem) -> MenuItemView {
        let tabBarItem = MenuItemView(frame: CGRect.zero)
        tabBarItem.menuItem = menuItem
        tabBarItem.backgroundColor = UIColor.white
        tabBarItem.translatesAutoresizingMaskIntoConstraints = false
        tabBarItem.clipsToBounds = true
        
        let itemTitleLabel = UILabel(frame: CGRect.zero)
        
        itemTitleLabel.font = UIFont(name: "Source Sans Pro", size: 13)
        itemTitleLabel.text = menuItem.displayTitle
        itemTitleLabel.numberOfLines = 0
        itemTitleLabel.adjustsFontSizeToFitWidth = true
        itemTitleLabel.textColor = UIColor.appColors.darkGray
        itemTitleLabel.textAlignment = .center
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTitleLabel.clipsToBounds = true
        
        tabBarItem.itemIconView.image = menuItem.inactive_icon!.withRenderingMode(.automatic)
        tabBarItem.itemIconView.translatesAutoresizingMaskIntoConstraints = false
        tabBarItem.itemIconView.clipsToBounds = true
        
        tabBarItem.addSubview(tabBarItem.itemIconView)
        tabBarItem.addSubview(itemTitleLabel)
        
        let constraints = [
            tabBarItem.itemIconView.heightAnchor.constraint(equalToConstant: 25), // Fixed height for our tab item icon
            tabBarItem.itemIconView.widthAnchor.constraint(equalToConstant: 25), // Fixed width for our tab item icon
            tabBarItem.itemIconView.centerXAnchor.constraint(equalTo: tabBarItem.centerXAnchor),
            tabBarItem.itemIconView.topAnchor.constraint(equalTo: tabBarItem.topAnchor, constant: 8), // Position menu item icon 8pts from the top of it's parent view
            
            itemTitleLabel.heightAnchor.constraint(equalToConstant: 13), // Fixed height for title label
            itemTitleLabel.widthAnchor.constraint(equalTo: tabBarItem.widthAnchor), // Position label full width across tab bar item
            itemTitleLabel.topAnchor.constraint(equalTo: tabBarItem.itemIconView.bottomAnchor, constant: 4), // Position title label 4pts below item icon
        ]
        NSLayoutConstraint.activate(constraints)
        
        // Each item should be able to trigger an action on tap
        tabBarItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleMenuItemTap)))
        return tabBarItem
    }
    
    @objc func handleMenuItemTap(_ gesture: UIGestureRecognizer) {
        let selectedItemIndex = self.subviews.firstIndex(of: gesture.view!)
        self.switchTab(from: self.activeTabIndex, to: selectedItemIndex!)
    }
    
    public func switchTab(from previousTabId: Int, to newTabId: Int) {
        self.deactivateTab(viewId: previousTabId)
        self.activateTab(viewId: newTabId)
    }
    
    func deactivateTab(viewId: Int) {
        let tab = self.subviews[viewId] as! MenuItemView
        let layersToRemove = tab.layer.sublayers!.filter({ $0.name == "active border" })
        tab.itemIconView.image = tab.menuItem!.inactive_icon!.withRenderingMode(.automatic)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                layersToRemove.forEach({ $0.removeFromSuperlayer() })
                tab.setNeedsLayout()
                tab.layoutIfNeeded()
            })
        }
    }
    
    func activateTab(viewId: Int) {
        let tab = self.subviews[viewId] as! MenuItemView
        let borderWidth = tab.frame.size.width - 20
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.appColors.decredGreen.cgColor
        borderLayer.name = "active border"
        borderLayer.frame = CGRect(x: 10, y: 0, width: borderWidth, height: 2)
        tab.itemIconView.image = tab.menuItem!.active_icon!.withRenderingMode(.automatic)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.8, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                tab.layer.addSublayer(borderLayer)
                tab.setNeedsLayout()
                tab.layoutIfNeeded()
            })
            self.itemTapped?(viewId) // Send an item tapped event to listener
        }
        self.activeTabIndex = viewId
    }
}
