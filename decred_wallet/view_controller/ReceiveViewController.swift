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
        showFirstWalletAddressAndQRCode()
        populateWalletDropdownMenu()
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
        imgWalletAddrQRCode.image = AppContext.instance.decrdConnection?.generateQRCodeFor(
            with: selectedAccount,
            forImageViewFrame: imgWalletAddrQRCode.frame
        )
    }
    
    private func showFirstWalletAddressAndQRCode() {
        if let acc = AppContext.instance.decrdConnection?.getAccounts()?.Acc {
            let accNames: [String] = acc.map({ $0.Name })
            
            if let firstWalletAddress = accNames.first {
                selectedAccount = firstWalletAddress
                accountDropdown.setTitle(selectedAccount, for: .normal)
                imgWalletAddrQRCode.image = AppContext.instance.decrdConnection?.generateQRCodeFor(
                    with: selectedAccount,
                    forImageViewFrame: imgWalletAddrQRCode.frame
                )
            }
        }
    }
    
    private func populateWalletDropdownMenu() {
        if let acc = AppContext.instance.decrdConnection?.getAccounts()?.Acc {
            let accNames: [String] = acc.map({ $0.Name })
            
            accountDropdown.initMenu(
                accNames,
                actions: { [weak self] index, val in
                    guard let this = self else { return }
                    this.selectedAccount = val
                    if let selectedAccount = acc.filter({ $0.Name == val }).first {
                        let address = AppContext.instance.decrdConnection?.getCurrentAddress(account: selectedAccount.Number)
                        this.accountDropdown.setTitle(val, for: .normal)
                        this.imgWalletAddrQRCode.image = AppContext.instance.decrdConnection?.generateQRCodeFor(
                            with: address ?? "",
                            forImageViewFrame: this.imgWalletAddrQRCode.frame
                        )
                    }
            })
        }
    }
}
