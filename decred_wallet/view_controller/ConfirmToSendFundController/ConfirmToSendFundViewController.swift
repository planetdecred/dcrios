//  ConfirmToSendFundViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class ConfirmToSendFundViewController: UIViewController {
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    var amount: String = "" {
        willSet (newValue) {
            labelTitle?.text = "Sending \(newValue)"
        }
    }
    var fee: String = "" {
        willSet (newValue) {
            feeLabel?.text = "with a fee of \(newValue) "
        }
    }
    var address: String = "" {
        willSet (newValue) {
            addressLabel?.text = newValue
        }
    }
    var account: String = "" {
        willSet (newValue) {
            accountLabel?.text = "to account (\(newValue))"
        }
    }
    var confirm: ((String)->Void)?
    var cancel: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        labelTitle?.text = "Sending \(amount) "
        feeLabel.text = "With a fee of \(fee) "
        addressLabel.text = address
        accountLabel.text = "to account (\(account))"
        let layer = view.layer
        layer.frame = vContent.frame
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 30
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width:0.0, height:40.0);
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
        self.confirm?(tfPassword.text ?? "")
        dismiss(animated: true, completion: nil)
    }
}
