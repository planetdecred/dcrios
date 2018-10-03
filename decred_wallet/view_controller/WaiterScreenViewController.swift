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
//    private lazy var doubleTap: UITapGestureRecognizer = {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: <#T##Any?#>, action: <#T##Selector?#>)
//    }()
    
    var onFinish:(()->Void)?
    var timer: Timer?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var logo: UIImageView!
    var  groupAnimation: CAAnimationGroup?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       //logo.image = UIImage.gifImageWithName("decred_logo")
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
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func goToSeetings(_ sender: Any) {
        timer?.invalidate()
        onTapAnimation?()
    }
    
    func stopAnimation() {
        logo.image = nil
        onFinish?()
    }
}
