//  TextFieldDoneButton.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import Foundation
import UIKit

extension UITextView {
    
    /// Adds a done button on textview to hide the keyboard. Useful when showing number pad.
    @discardableResult func addDoneButton() -> UITextView {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        
        let flexBarButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        let doneBarButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(resignFirstResponder)
        )
        
        keyboardToolbar.items = [
            flexBarButton,
            doneBarButton
        ]
        inputAccessoryView = keyboardToolbar
        
        return self
    }
}

extension UITextField {
    
    /// Adds a done button on textview to hide the keyboard. Useful when showing number pad.
    @discardableResult func addDoneButton() -> UITextField {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        
        let flexBarButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        let doneBarButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(resignFirstResponder)
        )
        
        keyboardToolbar.items = [
            flexBarButton,
            doneBarButton
        ]
        inputAccessoryView = keyboardToolbar
        
        return self
    }
}
