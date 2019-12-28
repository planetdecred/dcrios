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

private var maxLengths = NSMapTable<UITextField, NSNumber>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)

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

    var maxLength: Int? {
        get {
            return maxLengths.object(forKey: self)?.intValue
        }
        set {
            removeTarget(self, action: #selector(limitLength), for: .editingChanged)
            if let newValue = newValue {
                maxLengths.setObject(NSNumber(value: newValue), forKey: self)
                addTarget(self, action: #selector(limitLength), for: .editingChanged)
            } else {
                maxLengths.removeObject(forKey: self)
            }
        }
    }
    
    @IBInspectable var maxLengthInspectable: Int {
        get {
            return maxLength ?? Int.max
        }
        set {
            maxLength = newValue
        }
    }
    
    @objc private func limitLength(_ textField: UITextField) {
        guard let maxLength = maxLength, let prospectiveText = textField.text, prospectiveText.count > maxLength else {
            return
        }
        let selection = selectedTextRange
        text = String(prospectiveText[..<prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)])
        selectedTextRange = selection
    }
}
