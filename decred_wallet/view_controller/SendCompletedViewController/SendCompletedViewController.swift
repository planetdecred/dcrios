//  SendCompletedViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class SendCompletedViewController: UIViewController {
    @IBOutlet private weak var labelTransactionHash: UILabel!
    var transactionHash: String?
    
    var openDetails: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        labelTransactionHash.text = transactionHash
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        dismiss(animated: false) { [weak self] in
            self?.openDetails?()
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
