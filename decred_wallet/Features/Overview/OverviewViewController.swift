//
//  OverviewViewControllerr.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 11/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {
    @IBOutlet weak var syncProgressViewContainer: UIView!
    @IBOutlet weak var overviewPageViewContainer: UIView!
    
    override func viewDidLoad() {
        self.overviewPageViewContainer.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar(withTitle: "Overview")
    }
    
}

extension OverviewViewController {
    static func instantiate() -> Self {
        return Storyboards.Overview.instantiateViewController(for: self)
    }
}
