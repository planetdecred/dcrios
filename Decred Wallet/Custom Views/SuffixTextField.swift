//
//  SuffixTextField.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SuffixTextField: UITextField {

    @IBInspectable var suffixText: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    override var text: String? {
        didSet {
            selectedTextRange = maxTextRange
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            selectedTextRange = maxTextRange
        }
    }

    @objc private func textChanged() {
        if let currentText = text, let placeholder = suffixText {
            if currentText == placeholder {
                self.text = nil
            } else if !currentText.hasSuffix(placeholder) {
                self.text = currentText + placeholder
            }
        }
    }

    private var maxCursorPosition: UITextPosition? {
        guard let suffix = suffixText, !suffix.isEmpty else { return nil }
        guard let text = text, !text.isEmpty else { return nil }
        return position(from: beginningOfDocument, offset: (text as NSString).range(of: suffix, options: .backwards).location)
    }

    private var maxTextRange: UITextRange? {
        guard let maxCursorPosition = maxCursorPosition else { return nil }
        return textRange(from: maxCursorPosition, to: maxCursorPosition)
    }

    func reloadText() {
        textChanged()
    }

    override var selectedTextRange: UITextRange? {
        get { return super.selectedTextRange }
        set {
            guard let newRange = newValue,
                let maxCursorPosition = maxCursorPosition else {
                    super.selectedTextRange = newValue
                    return
            }

            if compare(maxCursorPosition, to: newRange.start) == .orderedAscending {
                super.selectedTextRange = textRange(from: maxCursorPosition, to: maxCursorPosition)
            } else if compare(maxCursorPosition, to: newRange.end) == .orderedAscending {
                super.selectedTextRange = textRange(from: newRange.start, to: maxCursorPosition)
            } else {
                super.selectedTextRange = newValue
            }
        }
    }

}
