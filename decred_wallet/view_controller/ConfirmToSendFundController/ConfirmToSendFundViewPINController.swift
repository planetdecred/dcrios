//  ConfirmToSendFundViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class ConfirmToSendFundViewPINController: UIViewController {
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet weak var lbMinorDigits: UILabel!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var Destaddress: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    
    @IBOutlet weak var contentHeight2: NSLayoutConstraint!
    @IBOutlet weak var contentHeight1: NSLayoutConstraint!
    var confirm: (()->Void)?
    var cancel: (()->Void)?
    
    var amount: String = "" {
        willSet (newValue) {
            labelTitle?.text = "Sending \(newValue)"
        }
    }
    var fee: String = "" {
        willSet (newValue) {
            lbMinorDigits?.text = "with a fee of \(newValue) "
        }
    }
    var address: String = "" {
        willSet (newValue) {
            Destaddress?.text = newValue
        }
    }
    var account: String = "" {
        willSet (newValue) {
            accountName?.text = "to account \'\(newValue)\'"
        }
    }
    var total: String = "" {
        willSet (newValue) {
            totalAmount?.text = newValue
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelTitle?.text = "Sending \(amount) "
        lbMinorDigits.text = "With a fee of \(fee) "
        accountName?.text = "to account \'\(account)\'"
        Destaddress?.text = address
        totalAmount?.text = total
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
        self.confirm?()
        dismiss(animated: true, completion: nil)
    }
}
