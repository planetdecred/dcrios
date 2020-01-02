//
//  ConfirmToSendPasswordEntryViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

protocol ConfirmToSendPasswordEntryDelegate: class {
    func didEnterPassword(_ password: String)
}

class ConfirmToSendPasswordEntryViewController: UIViewController {
    static let instance = Storyboards.Send.instantiateViewController(for: ConfirmToSendPasswordEntryViewController.self)

    @IBOutlet var passwordEntryTextField: UITextField!
    @IBOutlet var confirmToSendButton: UIButton!
    @IBOutlet var spendingPasswordLabel: UILabel!
    @IBOutlet var passwordEntryContainerView: UIView!
    @IBOutlet var containerView: UIView!
    
    var isPresenting: Bool = false
    lazy var containerViewHeight: CGFloat = {
        return containerView.frame.size.height
    }()
    lazy var backDropView: UIView = {
        return view
    }()
    weak var passwordEntryDelegate: ConfirmToSendPasswordEntryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        backDropView.addGestureRecognizer(tapGesture)
        passwordEntryContainerView.layer.borderColor = UIColor.appColors.decredBlue.cgColor
        passwordEntryTextField.addDoneButton()
        confirmToSendButton.setBackgroundColor(UIColor.appColors.lightGray, for: UIControl.State.disabled)
    }

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBAction func confirmPassword(_ sender: UIButton) {
        guard let text = passwordEntryTextField.text else {return}
        passwordEntryDelegate?.didEnterPassword(text)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showHidePassword(_ sender: UIButton) {
        let showPassword = !passwordEntryTextField.isSecureTextEntry
        let icon: UIImage? = showPassword ? UIImage(named: "ic-reveal") : UIImage(named: "ic-conceal")
        sender.setImage(icon, for: .normal)
        passwordEntryTextField.isSecureTextEntry = showPassword
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

extension ConfirmToSendPasswordEntryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !text.isEmpty{
            confirmToSendButton.isEnabled = true
        } else {
            confirmToSendButton.isEnabled = false
        }
        return true
    }
}
