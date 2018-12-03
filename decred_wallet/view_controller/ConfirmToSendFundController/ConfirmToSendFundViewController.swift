//  ConfirmToSendFundViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class ConfirmToSendFundViewController: UIViewController {
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet weak var lbMinorDigits: UILabel!
    var amount: Double = 0.0 {
        willSet (newValue) {
            labelTitle?.text = major(amount: newValue)
            lbMinorDigits?.text = minor(amount: newValue)
        }
    }
    
    var confirm: ((String)->Void)?
    var cancel: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        labelTitle?.text = major(amount: amount)
        lbMinorDigits.text = minor(amount: amount)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    private func major(amount:Double) -> String{
        let major = String(format: "%.2f", amount)
        return major
    }
    
    private func minor(amount:Double) -> String{
        let sAmount = "\(amount)"
        let majorCount = major(amount: amount).count
        if sAmount.count <= majorCount{
            return "000000"
        }else{
            return sAmount.substring(majorCount)
            
        }
    }
    
    @IBAction private func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.cancel?()
    }
    
    @IBAction private func confirmAction(_ sender: UIButton) {
        self.confirm?(tfPassword.text ?? "")
        dismiss(animated: true, completion: nil)
    }
}
