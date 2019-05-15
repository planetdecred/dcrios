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
    
    func wrapInNavigationcontroller() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
    
    func navigationMenuViewController() -> NavigationMenuViewController? {
        return self.slideMenuController()?.leftViewController as? NavigationMenuViewController
    }
    
    func setupNavigationBar(withTitle title: String) {
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = title
        
        // setup slidemenucontroller (drawer icon and tap action)
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
        self.slideMenuController()?.addLeftGestures()
        self.slideMenuController()?.addRightGestures()
    }
    
    func removeNavigationBarItem() {
        self.navigationItem.leftBarButtonItem = nil
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
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
    @discardableResult public func backButton() -> UIViewController {
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
    
    func showMessageDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showOkAlert(message: String, title: String? = nil, onPressOk: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            onPressOk?()
//            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
