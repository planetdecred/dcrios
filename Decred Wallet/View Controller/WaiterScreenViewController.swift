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
    var  groupAnimation: CAAnimationGroup?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startAnimate()
    }
    
    fileprivate func startAnimate(){
        let logolayer = logo.layer
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transformAnimation.duration = 0.5
        
        var startingTransform = CATransform3DMakeRotation(-CGFloat(Double.pi ), 0, 0, 1)
        //startingTransform = CATransform3DScale(startingTransform, 0.25, 0.25, 1)
        
        startingTransform = CATransform3DTranslate(startingTransform, 0, -10, 0)
        transformAnimation.fromValue = NSValue(caTransform3D: startingTransform)
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)

        
        let jumpUpAnimation = CABasicAnimation(keyPath:"transform")
        let jumpUpTransform = CATransform3DMakeTranslation(0.0, -20.0, 0.0)
        jumpUpAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        jumpUpAnimation.fromValue = NSValue(caTransform3D: jumpUpTransform)
        jumpUpAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        jumpUpAnimation.duration = 0.3

        
        groupAnimation = CAAnimationGroup()
        groupAnimation?.animations = [jumpUpAnimation, transformAnimation]
        groupAnimation?.repeatCount = Float.infinity
        groupAnimation?.duration = 1
        
        logolayer.add(groupAnimation!, forKey: "looping")
    }
    
    fileprivate func stopAnimate(){
        groupAnimation?.repeatCount = 0
    }
    
    
}
