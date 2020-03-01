//
//  TextFieldDoneButton.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

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
