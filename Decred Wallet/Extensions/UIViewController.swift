//
//  UIViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
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
    
    /// Creates a custom back button on ViewController. Hides default back button and create a UIBarButtonItem instance on controller and sets to leftBartButtonItem property.
    ///
    @discardableResult public func addNavigationBackButton() -> UIViewController {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "left-arrow"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.navigateToBackScreen))
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
    
    func listenForKeyboardVisibilityChanges(delegate keyboardVisibilityDelegate: KeyboardVisibilityDelegate) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardVisibilityDelegate.onKeyboardWillShowOrHide),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardVisibilityDelegate.onKeyboardWillShowOrHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func hideKeyboardOnTapAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func dismissViewOnTapAround() {
        // Use a DirectTapGestureRecognizer to prevent subview taps from triggering the dismissView action.
        self.view.addGestureRecognizer(DirectTapGestureRecognizer(target: self, action: #selector(self.dismissView)))
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
    
    @objc func dismissView() {
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
    
    func deviceRemainingFreeSpaceInBytes () -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
            guard
                let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
                let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
            else {
                return nil
            }
            return freeSize.int64Value
    }
    
    func checkStorageSpace() {
        if let storage = self.deviceRemainingFreeSpaceInBytes() {
            let currentTime = Date().timeIntervalSince1970
            let estimatedBlocksSinceGenesis = (Int(currentTime) - BuildConfig.GenesisTimestamp) / BuildConfig.TargetTimePerBlock
            let estimatedHeadersSize = estimatedBlocksSinceGenesis/1000
            if estimatedHeadersSize > storage {
                //warning low storage for user
                let alertController = UIAlertController(title: LocalizedStrings.lowStorageSpace, message: String(format: LocalizedStrings.lowStorageMessage, estimatedHeadersSize, storage), preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt, style: UIAlertAction.Style.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

// DirectTapGestureRecognizer disregards touch events not recieved directly from the `target` view.
// Prevents invoking the tap callback for indirect touches such as from subviews.
class DirectTapGestureRecognizer: UITapGestureRecognizer, UIGestureRecognizerDelegate {
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.delegate = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}

@objc protocol KeyboardVisibilityDelegate {
    @objc func onKeyboardWillShowOrHide(_ notification: Notification)
}
