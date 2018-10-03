//  ConfirmToSendFundViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class ConfirmToSendFundViewController: UIViewController {
    @IBOutlet private weak var labelTitle: UILabel!
    var amount: Double = 0.0 {
        willSet (newValue) {
            labelTitle?.text = "Sending \(newValue) DCR"
        }
    }
    
    var confirm: (()->Void)?
    var cancel: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        labelTitle?.text = "Sending \(amount) DCR"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction private func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.cancel?()
    }
    
    @IBAction private func confirmAction(_ sender: UIButton) {
        self.confirm?()
        dismiss(animated: true, completion: nil)
    }
}
