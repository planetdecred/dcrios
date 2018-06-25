//  ConfirmToSendFundViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class ConfirmToSendFundViewController: UIViewController {
    @IBOutlet weak var labelTitle: UILabel!
    
    var confirm: (()->Void)?
    var cancel: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction private func cancelAction(_ sender: UIButton) {
        self.cancel?()
    }
    
    @IBAction private func confirmAction(_ sender: UIButton) {
        self.confirm?()
    }
}
