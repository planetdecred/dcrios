//
//  TabMenu.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Signals

class TabMenu: UIView {    
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
        layer.backgroundColor = UIColor.white.cgColor
        
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
    
    func createTabItem(item: MenuItem) -> UIView {
        let barItem = UIView(frame: CGRect.zero)
        
        let titleLabel = UILabel(frame: CGRect.zero)
        let iconView = UIImageView(frame: CGRect.zero)

        titleLabel.font = UIFont(name: "Source Sans Pro", size: 13)
        titleLabel.text = item.displayTitle
        titleLabel.textColor = UIColor.appColors.darkGray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.clipsToBounds = true
        
        iconView.image = item.icon!.withRenderingMode(.automatic)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.clipsToBounds = true
        
        barItem.layer.backgroundColor = UIColor.white.cgColor
        barItem.addSubview(iconView)
        barItem.addSubview(titleLabel)
        barItem.translatesAutoresizingMaskIntoConstraints = false
        barItem.clipsToBounds = true

        let constraints = [
            iconView.heightAnchor.constraint(equalToConstant: 25),
            iconView.widthAnchor.constraint(equalToConstant: 25),
            iconView.centerXAnchor.constraint(equalTo: barItem.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: barItem.topAnchor, constant: 8),
            iconView.leadingAnchor.constraint(equalTo: barItem.leadingAnchor, constant: 35),
            titleLabel.heightAnchor.constraint(equalToConstant: 13),
            titleLabel.widthAnchor.constraint(equalTo: barItem.widthAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
        ]
        NSLayoutConstraint.activate(constraints)
        barItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        return barItem
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
            self.itemTapped => viewId            
        }
        self.activeItem = viewId
    }
}
