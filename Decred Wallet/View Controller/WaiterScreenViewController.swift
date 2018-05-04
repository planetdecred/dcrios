//
//  WaiterScreenViewController.swift
//  Decred Wallet
//  Copyright (c) 2018, The Decred developers
//  See LICENSE for details.
//

import UIKit

class WaiterScreenViewController: UIViewController {

    var onFinish:(()->Void)?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    fileprivate func startAnimate(){
        let logolayer = logo.layer
        let jumpAnimation = CAAnimation()
        //jumpAnimation.
        //logolayer.add(<#T##anim: CAAnimation##CAAnimation#>, forKey: <#T##String?#>)
    }
    
    fileprivate func stopAnimate(){
        
    }
    
    
}
