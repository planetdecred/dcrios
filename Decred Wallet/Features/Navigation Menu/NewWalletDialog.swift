//
//  NewWalletDialog.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class NewWalletDialog: UIViewController {
    @IBOutlet weak var dialogBackground: UIView!
    var onDialogDismissed: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let layer = self.view.layer
        layer.frame = dialogBackground.frame
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.9
        layer.shadowOffset = CGSize(width: 0, height: 20)
    }
    
    @IBAction private func OkAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.onDialogDismissed?()
    }
    
    static func show(onDialogDismissed: @escaping (()->Void)) {
        let newWalletDialog = Storyboards.NavigationMenu.instantiateViewController(for: self)
        newWalletDialog.onDialogDismissed = onDialogDismissed
        newWalletDialog.modalTransitionStyle = .crossDissolve
        newWalletDialog.modalPresentationStyle = .overCurrentContext
        AppDelegate.shared.window?.rootViewController?.present(newWalletDialog, animated: true, completion: nil)
    }
}
