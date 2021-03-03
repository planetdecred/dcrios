//
//  PrivacyViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class PrivacyViewController: UIViewController {
    
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var mixerStatusInfo: UILabel!
    @IBOutlet weak var unmixedBalance: UILabel!
    @IBOutlet weak var mixedBalance: UILabel!
    @IBOutlet weak var MixedAccount: UILabel!
    @IBOutlet weak var changeAccount: UILabel!
    @IBOutlet weak var accountBranch: UILabel!
    @IBOutlet weak var shuffleServer: UILabel!
    @IBOutlet weak var shufflePort: UILabel!
    @IBOutlet weak var mixerSwitch: UISwitch!
    @IBOutlet weak var spendUnmixedSwitch: UISwitch!
    @IBOutlet weak var mixerStatusIcon: UIImageView!
    @IBOutlet weak var mixingInfo: UILabel!
    
    var wallet: DcrlibwalletWallet!
    @IBOutlet weak var mixerDetailViewConst: NSLayoutConstraint!
    @IBOutlet weak var mixerDropdownArrow: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.walletName.text = wallet.name
    }
    
    @IBAction func privacyInfo(_ sender: Any) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: LocalizedStrings.receiveDCR,
                                                    message: LocalizedStrings.receiveInfo,
                                                    preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "LocalizedStrings.gotIt",
                                                    style: UIAlertAction.Style.default,
                                                    handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func mixAccount(_ sender: Any) {
        do {
            try WalletLoader.shared.multiWallet.startAccountMixer(self.wallet.id_, walletPassphrase: "spendingCode")
            DispatchQueue.main.async {
                self.mixerSwitch.isOn = true
            }
        } catch let error {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.mixerSwitch.isOn = false
            }
        }
    }
}

extension PrivacyViewController: DcrlibwalletAccountMixerNotificationListenerProtocol {
    func onAccountMixerEnded(_ walletID: Int) {
    
        self.mixerStatusInfo.text = LocalizedStrings.allBalanceMixed
       // self.mixerStatusIcon.image = UIImageView.init(image: UIImage(named: "ic_confirmedNew"))
        self.mixerDetailViewConst.constant = 72
        self.mixerDropdownArrow.isHidden = true
        self.mixingInfo.isHidden = true
    }
    
    func onAccountMixerStarted(_ walletID: Int) {
        self.mixerStatusInfo.text = LocalizedStrings.keepThisAppOpened
       // self.mixerStatusIcon.image = UIImageView.init(image: UIImage(named: "ic_confirmedNew"))
        self.mixerDetailViewConst.constant = 104
        self.mixerDropdownArrow.isHidden = false
        self.mixingInfo.isHidden = false
    }
}
