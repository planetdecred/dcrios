//  ReceiveViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class ReceiveViewController: UIViewController {
    @IBOutlet private var accountDropdown: DropMenuButton!
    @IBOutlet private var imgWalletAddrQRCode: UIImageView!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        accountDropdown.backgroundColor = UIColor.clear

        if let acc = AppContext.instance.decrdConnection?.getAccounts()?.Acc {
            let accNames: [String] = acc.map({ $0.Name })

            accountDropdown.initMenu(
                accNames,
                actions: { [weak self] _, val in
                    guard let this = self else { return }
                    if let selectedAccount = acc.filter({ $0.Name == val }).first {
                        let address = AppContext.instance.decrdConnection?.getCurrentAddress(account: selectedAccount.Number)
                        // debugPrint(address)
                        this.imgWalletAddrQRCode.image = AppContext.instance.decrdConnection?.generateQRCodeFor(
                            with: address ?? "",
                            forImageViewFrame: this.imgWalletAddrQRCode.frame
                        )
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
