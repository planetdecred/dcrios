//
//  UIViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

extension UIViewController {
    // Not using static so that individual VCs can override to provide custom storyboardID value.
    // By default, this returns the name of VC class as the storyboard ID.
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func instantiate(from storyboard: Storyboard) -> Self {
        return storyboard.instantiateViewController(for: self)
    }
    
    func wrapInNavigationcontroller() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
    
    func hideKeyboardOnTapAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    /// Creates custom back butotn on ViewController. Hides default back button and createa a UIBarButtonItem instance on controller and sets to leftBartButtonItem property.
    ///
    /// - Parameter imageName: Name of the image to show. if nil is supplied "picture_done" is assumed, specific to Imaginamos
    @discardableResult public func addNavigationBackButton() -> UIViewController {
        let backArrowImage = #imageLiteral(resourceName: "left-arrow")
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backArrowImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.navigateToBackScreen))
        return self
    }
    
    /// Go back to previsous screen. If pushed if pops else dismisses.
    @objc public func navigateToBackScreen() {
        if self.isModal {
            dismiss(animated: true, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    /// Checks if controller was pushed or presented
    /// Inspired by this answer
    /// http://stackoverflow.com/a/27301207/1568609
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    func dismissView() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showMessageDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedStrings.ok, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showOkAlert(message: String, title: String? = nil, okText: String? = "OK", onPressOk: (() -> Void)? = nil, addCancelAction: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: okText, style: .default) { _ in
            onPressOk?()
        }
        alert.addAction(okAction)
        
        if addCancelAction {
            alert.addAction(UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil))
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func displayToast(_ message : String) {
        guard let window = AppDelegate.shared.window else {
            return
        }
        
        if let toast = window.subviews.first(where: { $0 is UILabel && $0.tag == -1001 }) {
            toast.removeFromSuperview()
        }
        
        let toastView = UILabel()
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastView.textColor = UIColor.white
        toastView.textAlignment = .center
        toastView.font = UIFont(name: "SourceSansPro", size: 14)
        toastView.layer.cornerRadius = 25
        toastView.text = message
        toastView.numberOfLines = 0
        toastView.alpha = 0
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.tag = -1001
        
        window.addSubview(toastView)
        
        let horizontalCenterContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .centerX, relatedBy: .equal, toItem: window, attribute: .centerX, multiplier: 1, constant: 0)
        
        let widthContraint: NSLayoutConstraint = NSLayoutConstraint(item: toastView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: (self.view.frame.size.width-25) )
        
        let verticalContraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=200)-[toastView(==50)]-20-|", options: [.alignAllCenterX, .alignAllCenterY], metrics: nil, views: ["toastView": toastView])
        
        NSLayoutConstraint.activate([horizontalCenterContraint, widthContraint])
        NSLayoutConstraint.activate(verticalContraint)
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { toastView.alpha = 1 },
                       completion: nil
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: .curveEaseIn,
                           animations: { toastView.alpha = 0 },
                           completion: { _ in toastView.removeFromSuperview() }
            )
        })
    }
}
