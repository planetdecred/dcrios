//
//  NoWifiSyncConfirmationDialog.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 06/04/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

class NoWifiSyncConfirmationDialog: UIViewController {
    @IBOutlet weak var dialogContent: UIView!
    
    var Yes: (()->Void)?
    var No: (()->Void)?
    var Always: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let layer = view.layer
        layer.frame = dialogContent.frame
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 30
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width:0.0, height:40.0);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func NoAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.No?()
    }
    
    @IBAction private func YesAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.Yes?()
    }
    @IBAction private func AlwaysAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.Always?()
    }
}
