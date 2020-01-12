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
            let menuItemView = TabMenuItemView(for: menuItem)
            menuItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleMenuItemTap)))
            self.addArrangedSubview(menuItemView)
        }
        
        self.menuItemViewTapped(self.subviews.first!)
    }
    
    @objc func handleMenuItemTap(_ gesture: UIGestureRecognizer) {
        self.menuItemViewTapped(gesture.view!)
    }
    
    func menuItemViewTapped(_ menuItemView: UIView) {
        guard let selectedItemIndex = self.subviews.firstIndex(of: menuItemView) else {
            return
        }
        self.switchTab(from: self.activeTabIndex, to: selectedItemIndex)
        self.itemTapped?(selectedItemIndex) // todo rename this listener
    }
    
    public func switchTab(from previousTabId: Int, to newTabId: Int) {
        self.activeTabIndex = newTabId
        DispatchQueue.main.async {
            (self.subviews[previousTabId] as! TabMenuItemView).deactivate()
            (self.subviews[newTabId] as! TabMenuItemView).activate()
        }
    }
}
