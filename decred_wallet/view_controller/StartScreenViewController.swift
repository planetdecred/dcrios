//
//  StartScreenViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class StartScreenViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var testnetLabel: UILabel!
    
    var timer: Timer?
    let animationDurationSeconds: Double = 5
    
    var onTapAnimation: (() -> Void)?
    var onFinish: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if GlobalConstants.App.IsTestnet {
            testnetLabel.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logo.loadGif(name: "splashLogo")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // load main screen after set interval
        timer = Timer.scheduledTimer(withTimeInterval: self.animationDurationSeconds, repeats: false, block: {_ in
            self.loadMainScreen()
        })
        
        if isWalletCreated() {
            self.label.text = "Opening wallet..."
        }
    }
    
    @IBAction func animatedLogoTap(_ sender: Any) {
        timer?.invalidate()
        onTapAnimation?()
    }
    
    func loadMainScreen() {
        onFinish?()
    }
}
