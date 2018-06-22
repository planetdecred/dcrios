//
//  WaiterScreenViewController.swift
//  Decred Wallet
//  Copyright (c) 2018, The Decred developers
//  See LICENSE for details.
//

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
    var  groupAnimation: CAAnimationGroup?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       logo.image = UIImage.gifImageWithName("loaderAnimation")
       set(duration: 4)
    }
    
    func set(label: String) {
        self.label.text = label
    }
    
    func set(duration: Double) {
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: {_ in
            self.stopAnimation()
        })
    }
    
    @IBAction func goToSeetings(_ sender: Any) {
        timer?.invalidate()
        onTapAnimation!()
    }
    
    
    func stopAnimation() {
        logo.image = nil
        onFinish!()
    }
}
