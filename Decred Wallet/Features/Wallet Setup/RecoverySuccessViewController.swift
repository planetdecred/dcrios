//
//  RecoverySuccessViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 25/11/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

class RecoverySuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func getStarted(_ sender: Any) {
        NavigationMenuViewController.setupMenuAndLaunchApp(isNewWallet: true)
    }
}
