//  ReceiveViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class ReceiveViewController: UIViewController {
    @IBOutlet var accountDropdown: DropMenuButton!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        accountDropdown.backgroundColor = UIColor.clear

        if let acc = AppContext.instance.decrdConnection?.getAccounts()?.Acc {
            let accNames: [String] = acc.map({ $0.Name })

            accountDropdown.initMenu(
                accNames,
                actions: { _, val in
                    debugPrint(val)
                    if let selected = acc.filter({ $0.Name == val }).first {
                        debugPrint(selected)
                    }
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        navigationItem.title = "Receive"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
