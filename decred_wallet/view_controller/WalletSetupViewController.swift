//
//  WalletSetupViewController.swift
//  Decred Wallet

/// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class WalletSetupViewController : UIViewController {
    
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var restoreWallet: UILabel!
    @IBOutlet weak var createWallet: UILabel!
    @IBOutlet weak var build: UILabel!
    @IBOutlet weak var walletText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setScreenFont()
        createWallet.text = "Create a New \n Wallet"
        restoreWallet.text = "Restore Existing \n Wallet"
        infoText.text = "Create or recover your wallet and \nstart managing your decred."
        var compileDate:Date{
            let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
            if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
                let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
                let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
            { return infoDate }
            return Date()
        }
    
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        let netType = infoForKey(GlobalConstants.Strings.NetType)! == "mainnet" ? "mainnet" : "testnet"
        build?.text = "build \(netType) " + dateformater.string(from: compileDate as Date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btn_create_wallet(_ sender: Any) {}
    
    @IBAction func backToMenu(_:UIStoryboardSegue){}
    
    func setScreenFont(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                self.setFontSize(infoTxt: 15, restoreWalletTxt: 14, createWalletTxt: 14, buildTxt: 11, walletTxt: 17)
                print("iPhone 5 or 5S or 5C")
            case 1334:
                self.setFontSize(infoTxt: 18, restoreWalletTxt: 15, createWalletTxt: 15, buildTxt: 12, walletTxt: 20)
                print("iPhone 6/6S/7/8")
            case 2208:
                self.setFontSize(infoTxt: 19, restoreWalletTxt: 16, createWalletTxt: 16, buildTxt: 13, walletTxt: 21)
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                self.setFontSize(infoTxt: 19, restoreWalletTxt: 16, createWalletTxt: 16, buildTxt: 13, walletTxt: 21)
                print("iPhone X")
            default:
                print("unknown")
            }
        }
        else if UIDevice().userInterfaceIdiom == .pad{
            self.setFontSize(infoTxt: 36, restoreWalletTxt: 32, createWalletTxt: 32, buildTxt: 28, walletTxt: 38)
        }
    }
    func setFontSize(infoTxt: CGFloat ,restoreWalletTxt : CGFloat ,createWalletTxt : CGFloat ,buildTxt : CGFloat ,walletTxt: CGFloat){
        infoText.font = infoText.font.withSize(infoTxt)
        restoreWallet.font = restoreWallet.font.withSize(restoreWalletTxt)
        createWallet.font = createWallet.font.withSize(createWalletTxt)
        build.font = build.font.withSize(buildTxt)
        walletText.font = walletText.font.withSize(walletTxt)
    }
}
