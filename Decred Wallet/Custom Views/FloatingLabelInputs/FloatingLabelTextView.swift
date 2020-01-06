//
//  FloatingLabelTextView.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class FloatingLabelTextView: UITextView {
    let borderLayer = FloatingLabelBorderLayer()
    let floatingPlaceholderLabel = FloatingLabelPlaceholder()
    var isEditing: Bool = false

    @IBInspectable var placeholder: String? {
        didSet {
            self.floatingPlaceholderLabel.text = placeholder
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.initView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }

    private func initView() {
        self.delegate = self

        self.layer.addSublayer(borderLayer)
        self.layer.masksToBounds = false
        self.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        self.addSubview(self.floatingPlaceholderLabel)
        self.floatingPlaceholderLabel.setFontAndTopConstraint()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = self.bounds
    }
}

extension FloatingLabelTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isEditing = true
        borderLayer.setColor(isParentEditing: self.isEditing)
        self.floatingPlaceholderLabel.parentEditingDidBegin()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.isEditing = false
        borderLayer.setColor(isParentEditing: self.isEditing)
        self.floatingPlaceholderLabel.parentEditingDidEnd()
    }
}

extension FloatingLabelTextView: FloatingLabelProtocol {
    func isParentEmpty() -> Bool {
        return self.text?.isEmpty ?? false
    }
}
