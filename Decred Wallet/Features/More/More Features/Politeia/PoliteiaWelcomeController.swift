//
//  PoliteiaWelcomeController.swift
//  Decred Wallet
//
//  Created by Justin Do on 09/12/2021.
//  Copyright © 2021 Decred. All rights reserved.
//

import Foundation
import UIKit

class PoliteiaWelcomeController: UIViewController {
    
    var navi: UINavigationController?
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onInfoTapped(_ sender: Any) {
        let alertController = UIAlertController(title: LocalizedStrings.governance, message: LocalizedStrings.poliWelcomInfo, preferredStyle: .alert)
        let gotItAction = UIAlertAction(title: LocalizedStrings.gotIt, style: .cancel, handler: nil)
        alertController.addAction(gotItAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onFetchProposalsTapped(_ sender: Any) {
        let multiWallet = WalletLoader.shared.multiWallet!
        multiWallet.setBoolConfigValueForKey(GlobalConstants.Strings.HAS_SHOW_POLITEIA_WELCOME, value: true)
        let politeiaVc = PoliteiaController.instantiate(from: .Politeia)
        self.navi?.pushViewController(politeiaVc, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
}
