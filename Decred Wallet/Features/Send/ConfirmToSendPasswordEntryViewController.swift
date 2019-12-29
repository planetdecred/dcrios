//
//  ConfirmToSendPasswordEntryViewController.swift
//  Decred Wallet
//
//  Created by kayeli dennis on 29/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

class ConfirmToSendPasswordEntryViewController: UIViewController {
    static let instance = Storyboards.Send.instantiateViewController(for: ConfirmToSendPasswordEntryViewController.self)

    @IBOutlet var passwordEntryContainerView: UIView!
    @IBOutlet var containerView: UIView!
    
    var isPresenting: Bool = false
    lazy var containerViewHeight: CGFloat = {
        return containerView.frame.size.height
    }()
    lazy var backDropView: UIView = {
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        backDropView.addGestureRecognizer(tapGesture)
        passwordEntryContainerView.layer.borderColor = UIColor.appColors.decredBlue.cgColor
    }

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction func confirmPassword(_ sender: UIButton) {
    }

    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ConfirmToSendPasswordEntryViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            containerView.frame.origin.y += containerViewHeight
            backDropView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.y -= self.containerViewHeight
                self.backDropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.y += self.containerViewHeight
                self.backDropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
