//  SendCompletedViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class SendCompletedViewController: UIViewController {
    @IBOutlet private weak var labelTransactionHash: UILabel!
    var transactionHash: String?
    
    @IBOutlet weak var vContent: UIView!
    var openDetails: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layer = view.layer
        
        layer.frame = vContent.frame
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 30
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width:0.0, height:40.0);
        labelTransactionHash.text = transactionHash
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
