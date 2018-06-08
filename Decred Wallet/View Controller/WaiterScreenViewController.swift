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
}


class WaiterScreenViewController: UIViewController, WaiterScreenProtocol {
    
    var onFinish:(()->Void)?
    var timer: Timer?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var logo: UIImageView!
    var  groupAnimation: CAAnimationGroup?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
       logo.image  =   UIImage.gifImageWithName("loaderAnimation")
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
    
//    func startAnimation() {
//        let logolayer = logo.layer
//
//        let jumpUpAnimation = CABasicAnimation(keyPath:"transform")
//        let jumpUpTransform = CATransform3DMakeTranslation(0.0, -40.0, 0.0)
//        jumpUpAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//        jumpUpAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
//        jumpUpAnimation.toValue = NSValue(caTransform3D: jumpUpTransform)
//        jumpUpAnimation.duration = 0.3
//        jumpUpAnimation.beginTime = 0.0
//
//        let semiRotateAnimation = CABasicAnimation(keyPath: "transform")
//        semiRotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
//        semiRotateAnimation.duration = 0.3
//        semiRotateAnimation.beginTime = 0.3
//        let startingTransform = CATransform3DMakeRotation(-CGFloat(Double.pi ), 0, 0, 1)
//        semiRotateAnimation.fromValue = NSValue(caTransform3D: jumpUpTransform)
//        semiRotateAnimation.toValue = NSValue(caTransform3D: startingTransform)
//
//        let semiRotateAnimation2 = CABasicAnimation(keyPath: "transform")
//        semiRotateAnimation2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
//        semiRotateAnimation2.duration = 0.3
//        semiRotateAnimation2.beginTime = 0.6
//        let endingTransform = CATransform3DMakeRotation(-CGFloat(Double.pi ) * 1.99, 0, 0, 1)
//        semiRotateAnimation2.fromValue = NSValue(caTransform3D: startingTransform)
//        semiRotateAnimation2.toValue = NSValue(caTransform3D: endingTransform)
//
//
//        let fallDownAnimation = CABasicAnimation(keyPath:"transform")
//        let fallDownTransform = CATransform3DMakeTranslation(0.0, 40.0, 0.0)
//        fallDownAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
//        fallDownAnimation.fromValue = NSValue(caTransform3D: endingTransform)
//        fallDownAnimation.toValue = NSValue(caTransform3D: fallDownTransform)
//        fallDownAnimation.duration = 0.2
//        fallDownAnimation.beginTime = 0.8
//
//        groupAnimation = CAAnimationGroup()
//        groupAnimation?.animations = [jumpUpAnimation, semiRotateAnimation,semiRotateAnimation2, fallDownAnimation]
//        groupAnimation?.repeatCount = Float.infinity
//        groupAnimation?.duration = 1
//
//        logolayer.add(groupAnimation!, forKey: "looping")
//    }
    
    func stopAnimation() {
        logo.image = nil
        onFinish!()
    }
}
