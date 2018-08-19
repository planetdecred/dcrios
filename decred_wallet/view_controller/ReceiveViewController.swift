//  ReceiveViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class ReceiveViewController: UIViewController {
    @IBOutlet private var accountDropdown: DropMenuButton!
    @IBOutlet private var imgWalletAddrQRCode: UIImageView!
    @IBOutlet weak var walletAddress: UILabel!
    var firstTrial = true
    var starttime: Int64 = 0
    var myacc: AccountsEntity!
    
    private var selectedAccount = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountDropdown.backgroundColor = UIColor.clear
        showFirstWalletAddressAndQRCode()
        populateWalletDropdownMenu()
        starttime = Int64(NSDate().timeIntervalSince1970)
        print(starttime)
        print(starttime * 1000)
       
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
        self.getAddress(accountNumber: (self.myacc.Number))
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    private func showFirstWalletAddressAndQRCode() {
        if let acc =  AppContext.instance.decrdConnection?.getAccounts()?.Acc {
            if acc != nil{
            let accNames: [String] = acc.map({ $0.Name })
            self.myacc = acc.first
            
            if let firstWalletAddress = accNames.first {
                selectedAccount = firstWalletAddress
                accountDropdown.setTitle(selectedAccount, for: .normal)
                self.getAddress(accountNumber: (self.myacc.Number))
            }
            }
            else{
                print("no account")
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
                    if acc.filter({ $0.Name == val }).first != nil {
                        self?.myacc = acc.map({ $0 }).first
                        self?.getAddress(accountNumber:(self?.myacc.Number)!)
                    }
            })
        }
    }
    
    private func getAddress(accountNumber : Int32){
        let receiveAddress = try?AppContext.instance.decrdConnection?.wallet?.address(forAccount: Int32(accountNumber))
        print("got address in  ".appending(String(Int64(NSDate().timeIntervalSince1970) - starttime)))
       // UserDefaults.standard.setValue(receiveAddress!, forKey: "KEY_RECENT_ADDRESS")
        DispatchQueue.main.async {
            self.walletAddress.text = receiveAddress!
            self.imgWalletAddrQRCode.image = AppContext.instance.decrdConnection?.generateQRCodeFor(
                with: receiveAddress!!,
                forImageViewFrame: self.imgWalletAddrQRCode.frame)
            print("generate QR  in  ".appending(String(Int64(NSDate().timeIntervalSince1970) - self.starttime)))
            print("generated address for account ".appending(String(accountNumber)))
            print(receiveAddress!!)
        }
        
      
    }
}
