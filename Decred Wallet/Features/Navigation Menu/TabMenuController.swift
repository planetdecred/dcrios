//
//  TabMenuController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Signals

class TabMenuController: UITabBarController {
    
    var customTabBar: TabMenu!
    
    func setupCustomTabMenu(_ withItems: [TabMenuItem], completion: @escaping ([UIViewController]) -> Void) {
        let frame = tabBar.frame
        var viewControllers = [UIViewController]()
        
        customTabBar = TabMenu(items: withItems, frame: frame)
        customTabBar.clipsToBounds = true
        
        view.addSubview(customTabBar)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            customTabBar.widthAnchor.constraint(equalToConstant: tabBar.frame.width),
            customTabBar.heightAnchor.constraint(equalToConstant: 67),
            customTabBar.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
        ])
        for i in 0 ..< withItems.count{
            viewControllers.append(withItems[i].controller)
        }
        tabBar.isHidden = true
        self.view.bringSubviewToFront(customTabBar)
        view.layoutIfNeeded()
        completion(viewControllers)
    }
}
