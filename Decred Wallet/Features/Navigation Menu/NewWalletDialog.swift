//
//  NewWalletDialog.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 21/05/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

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
