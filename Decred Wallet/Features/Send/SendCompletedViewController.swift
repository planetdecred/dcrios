//  SendCompletedViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import SafariServices

class SendCompletedViewController: UIViewController {
    var transactionHash: String!
    
    @IBOutlet weak var dialogBackground: UIView!
    @IBOutlet weak var hashHeaderLabel: UILabel!
    @IBOutlet private weak var labelTransactionHash: UILabel!
    
    var dialogClosed: ((Bool) -> Void)!
    
    static func showSendCompletedDialog(for txHash: String, dialogClosed: @escaping (Bool) -> Void) {
        let sendCompletedVC = Storyboards.Send.instantiateViewController(for: self)
        sendCompletedVC.transactionHash = txHash
        sendCompletedVC.dialogClosed = dialogClosed
        sendCompletedVC.modalTransitionStyle = .crossDissolve
        sendCompletedVC.modalPresentationStyle = .overCurrentContext
        AppDelegate.shared.window?.rootViewController?.present(sendCompletedVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelTransactionHash.text = transactionHash
        let copyTransactionHashOnTap = UITapGestureRecognizer(target: self, action: #selector(self.copyTxHash))
        self.labelTransactionHash.addGestureRecognizer(copyTransactionHashOnTap)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let layer = view.layer
        layer.frame = self.dialogBackground.frame
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 30
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width:0.0, height:40.0);
    }
    
    @objc func copyTxHash() {
        UIPasteboard.general.string = self.transactionHash
        self.hashHeaderLabel.text = "copyHash".localized
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hashHeaderLabel.text = "\("hash".localized):"
        }
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.dialogClosed(true)
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.dialogClosed(false)
        }
    }
}
