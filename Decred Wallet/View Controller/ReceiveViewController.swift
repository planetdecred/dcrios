//  ReceiveViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class ReceiveViewController: UIViewController {
    @IBOutlet private var accountDropdown: DropMenuButton!
    @IBOutlet private var imgWalletAddrQRCode: UIImageView!

    private var selectedAccount = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        accountDropdown.backgroundColor = UIColor.clear
        generateQRCode()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        navigationItem.title = "Receive"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction private func generateNewAddress() {
        generateQRCode()
    }
    
    private func generateQRCode() {
        if let acc = AppContext.instance.decrdConnection?.getAccounts()?.Acc {
            let accNames: [String] = acc.map({ $0.Name })
            
            if let firstWalletAddress = accNames.first {
                accountDropdown.setTitle(firstWalletAddress, for: .normal)
                imgWalletAddrQRCode.image = AppContext.instance.decrdConnection?.generateQRCodeFor(
                    with: firstWalletAddress,
                    forImageViewFrame: imgWalletAddrQRCode.frame
                )
            }
            
            accountDropdown.initMenu(
                accNames,
                actions: { [weak self] _, val in
                    guard let this = self else { return }
                    this.selectedAccount = val
                    if let selectedAccount = acc.filter({ $0.Name == this.selectedAccount }).first {
                        let address = AppContext.instance.decrdConnection?.getCurrentAddress(account: selectedAccount.Number)
                        this.imgWalletAddrQRCode.image = AppContext.instance.decrdConnection?.generateQRCodeFor(
                            with: address ?? "",
                            forImageViewFrame: this.imgWalletAddrQRCode.frame
                        )
                    }
            })
        }
    }
}
