//
//  UIViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit
extension UIViewController {
    func setNavigationBarItem() {
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
       // self.addRightBarButtonWithImage(UIImage(named: "ic_notifications_black_24dp")!)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
        self.slideMenuController()?.addLeftGestures()
        self.slideMenuController()?.addRightGestures()
    }
    
    func removeNavigationBarItem() {
        self.navigationItem.leftBarButtonItem = nil
       // self.navigationItem.rightBarButtonItem = nil
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
    }
    
    /// Creates custom back butotn on ViewController. Hides default back button and createa a UIBarButtonItem instance on controller and sets to leftBartButtonItem property.
    ///
    /// - Parameter imageName: Name of the image to show. if nil is supplied "picture_done" is assumed, specific to Imaginamos
    @discardableResult public func backButton() -> UIViewController {
        let backArrowImage = #imageLiteral(resourceName: "left-arrow")
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backArrowImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.navigateToBackScreen))
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
        if presentingViewController != nil {
            return true
        }
        
        if presentingViewController?.presentedViewController == self {
            return true
        }
        
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}
