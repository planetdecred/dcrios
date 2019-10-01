//
//  TabNavigationMenu.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Signals

class TabNavigationMenu: UIView {    
    var itemTapped: Signal = Signal<Int>()
    var activeItem: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    convenience init(items: [MenuItem], frame: CGRect) {
        self.init(frame: frame)
        self.layer.backgroundColor = UIColor.white.cgColor
        
        for i in 0 ..< items.count {
            let itemView = self.createTabItem(item: items[i])
            itemView.tag = i
            self.addSubview(itemView)
           
            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemView.clipsToBounds = true
            let itemWidth = self.frame.width / CGFloat(items.count)
            let leadingAnchor = itemWidth * CGFloat(i)
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalTo: self.heightAnchor),
                itemView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingAnchor),
                itemView.topAnchor.constraint(equalTo: self.topAnchor),
            ])
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.activateTab(viewId: self.activeItem)
    }
    
    // Create a custom nav menu item
    func createTabItem(item: MenuItem) -> UIView {
        let tabBarItem = UIView(frame: CGRect.zero)
        
        let itemTitleLabel = UILabel(frame: CGRect.zero)
        let itemIconView = UIImageView(frame: CGRect.zero)
        
        itemTitleLabel.font = UIFont(name: "Source Sans Pro", size: 13)
        itemTitleLabel.text = item.displayTitle
        itemTitleLabel.textColor = UIColor.appColors.darkGray
        itemTitleLabel.textAlignment = .center
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTitleLabel.clipsToBounds = true
        
        itemIconView.image = item.icon!.withRenderingMode(.automatic)
        itemIconView.translatesAutoresizingMaskIntoConstraints = false
        itemIconView.clipsToBounds = true
        
        tabBarItem.layer.backgroundColor = UIColor.white.cgColor
        tabBarItem.addSubview(itemIconView)
        tabBarItem.addSubview(itemTitleLabel)
        tabBarItem.translatesAutoresizingMaskIntoConstraints = false
        tabBarItem.clipsToBounds = true
        
        let constraints = [
            itemIconView.heightAnchor.constraint(equalToConstant: 25), // Fixed height for our tab item
            itemIconView.widthAnchor.constraint(equalToConstant: 25), // Fixed width for our tab item
            itemIconView.centerXAnchor.constraint(equalTo: tabBarItem.centerXAnchor),
            itemIconView.topAnchor.constraint(equalTo: tabBarItem.topAnchor, constant: 8), // Position menu item icon 8pts from the top of it's parent view
            itemIconView.leadingAnchor.constraint(equalTo: tabBarItem.leadingAnchor, constant: 35),
            itemTitleLabel.heightAnchor.constraint(equalToConstant: 13), // Fixed height for title label
            itemTitleLabel.widthAnchor.constraint(equalTo: tabBarItem.widthAnchor), // Position label full width across tab bar item
            itemTitleLabel.topAnchor.constraint(equalTo: itemIconView.bottomAnchor, constant: 4), // Position title label 4pts below item icon
        ]
        NSLayoutConstraint.activate(constraints)
        tabBarItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap))) // Each item should be able to trigger and action on tap
        return tabBarItem
    }
    
    @objc func handleTap(_ gesture: UIGestureRecognizer) {
        self.switchTab(from: self.activeItem, to: gesture.view!.tag)
    }
    
    public func switchTab(from: Int, to: Int) {
        self.deactivateTab(viewId: from)
        self.activateTab(viewId: to)
    }
    
    func deactivateTab(viewId: Int) {
        let tab = self.subviews[viewId]
        let layersToRemove = tab.layer.sublayers!.filter({ $0.name == "active border" })
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                layersToRemove.forEach({ $0.removeFromSuperlayer() })
                tab.setNeedsLayout()
                tab.layoutIfNeeded()
            })
        }
    }
    
    func activateTab(viewId: Int) {
        let tab = self.subviews[viewId]
        let borderWidth = tab.frame.size.width - 20
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.appColors.decredGreen.cgColor
        borderLayer.name = "active border"
        borderLayer.frame = CGRect(x: 10, y: 0, width: borderWidth, height: 2)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.8, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                tab.layer.addSublayer(borderLayer)
                tab.setNeedsLayout()
                tab.layoutIfNeeded()
            })
            self.itemTapped => viewId // Fire a Signal event on tap so listening views can react to tap
        }
        self.activeItem = viewId
    }
}
