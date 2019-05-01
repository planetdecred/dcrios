//
//  WaiterScreenViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

protocol WaiterScreenProtocol {
    func set(label:String)
    func set(duration:Double)
    func stopAnimation()
    var onFinish:(()->Void)?{get set}
    var onTapAnimation:(()->Void)?{get set}
}


class WaiterScreenViewController: UIViewController, WaiterScreenProtocol {
    
    var onTapAnimation: (() -> Void)?
    var onFinish:(()->Void)?
    
    var timer: Timer?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var testnetLabel: UILabel!
    
    var  groupAnimation: CAAnimationGroup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isTestnet = Bool(infoForKey(GlobalConstants.Strings.IS_TESTNET)!)!
        if(isTestnet) {
            testnetLabel.isHidden = false
            testnetLabel.text = "testnet"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        logo.loadGif(name: "splashLogo")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        set(duration: 5)
        
        if isWalletCreated(){
            set(label: "Opening wallet...")
        }
        
    }
    
    func set(label: String) {
        self.label.text = label
    }
    
    func set(duration: Double) {
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: {_ in
            self.stopAnimation()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToSeetings(_ sender: Any) {
        timer?.invalidate()
        onTapAnimation?()
    }
    
    func stopAnimation() {
        onFinish?()
    }
}
