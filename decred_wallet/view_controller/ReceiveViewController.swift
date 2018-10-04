//  ReceiveViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class ReceiveViewController: UIViewController {
    @IBOutlet private var accountDropdown: DropMenuButton!
    @IBOutlet private var imgWalletAddrQRCode: UIImageView!
    @IBOutlet var walletAddress: UIButton!
    var firstTrial = true
    var starttime: Int64 = 0
    var myacc: AccountsEntity!
    var account: GetAccountResponse?
    var tapGesture = UITapGestureRecognizer()
    
    private var selectedAccount = ""
    
    // MARK: - View Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TAP Gesture
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.CopyImgAddress(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        imgWalletAddrQRCode.addGestureRecognizer(tapGesture)
        imgWalletAddrQRCode.isUserInteractionEnabled = true
        self.accountDropdown.backgroundColor = UIColor.white
        self.showFirstWalletAddressAndQRCode()
        self.populateWalletDropdownMenu()
        self.starttime = Int64(NSDate().timeIntervalSince1970)
        print(self.starttime)
        print(self.starttime * 1000)
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
    }
    
    private func showFirstWalletAddressAndQRCode() {
        self.account?.Acc.removeAll()
        do{
            let strAccount = try SingleInstance.shared.wallet?.getAccounts(0)
            self.account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
        } catch let error{
            print(error)
        }
        let acc = self.account?.Acc
        if acc != nil {
            let accNames: [String] = (self.account?.Acc.map({ $0.Name }))!
            self.myacc = self.account?.Acc.first
            
            if let firstWalletAddress = accNames.first {
                self.selectedAccount = firstWalletAddress
                self.accountDropdown.setTitle(self.selectedAccount, for: .normal)
                self.getAddress(accountNumber: (self.myacc.Number))
            }
        } else {
            print("no account")
        }
    }

    @IBAction func tapCopy(_ sender: Any) {
        self.copyAddress()
    }
    @IBAction func CopyImgAddress(_ sender: UITapGestureRecognizer) {
        self.copyAddress()
    }
    
    private func copyAddress(){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = self.walletAddress.currentTitle
            
            //Alert
            let alertController = UIAlertController(title: "", message: "Wallet address copied", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func populateWalletDropdownMenu() {
        self.account?.Acc.removeAll()
        do{
            
            let strAccount = try SingleInstance.shared.wallet?.getAccounts(0)
            self.account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
        } catch let error{
            print(error)
        }
        // let acc = self.account?.Acc
        
        let defaultNumber = UserDefaults.standard.integer(forKey: "wallet_default")
        
        if let defaultAccount = account?.Acc.filter({ $0.Number == defaultNumber }).first {
            
            accountDropdown.setTitle(
                defaultAccount.Name,
                for: UIControlState.normal
            )
            self.accountDropdown.backgroundColor = UIColor.white
            
            /*self.accountDropdown.backgroundColor = UIColor(
                red: 173.0 / 255.0,
                green: 231.0 / 255.0,
                blue: 249.0 / 255.0,
                alpha: 1.0
            )*/
        }
        
        let accNames: [String] = (self.account?.Acc.map({ $0.Name }))!
        
        accountDropdown.initMenu(
            accNames
        ) { [weak self] _, val in
            guard let this = self else { return }
            this.selectedAccount = val
            if self?.account?.Acc.filter({ $0.Name == val }).first != nil {
                self?.myacc = self?.account?.Acc.map({ $0 }).first
                self?.getAddress(accountNumber: (self?.myacc.Number)!)
            }
        }
    }
    
    private func getAddress(accountNumber : Int32){
        let receiveAddress = try?SingleInstance.shared.wallet?.address(forAccount: Int32(accountNumber))
        print("got address in  ".appending(String(Int64(NSDate().timeIntervalSince1970) - starttime)))
       // UserDefaults.standard.setValue(receiveAddress!, forKey: "KEY_RECENT_ADDRESS")
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            this.walletAddress.setTitle(receiveAddress!, for: .normal)
            this.imgWalletAddrQRCode.image = generateQRCodeFor(
                with: receiveAddress!!,
                forImageViewFrame: this.imgWalletAddrQRCode.frame
            )
            print("generate QR  in  ".appending(String(Int64(NSDate().timeIntervalSince1970) - this.starttime)))
            print("generated address for account ".appending(String(accountNumber)))
            print(receiveAddress!!)
        }
    }
}
