//
//  FloatingPlaceholderTextView.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class FloatingPlaceholderTextView: UITextView {
    let borderLayer = FloatingPlaceholderBorderLayer()
    let floatingPlaceholderLabel = FloatingPlaceholderLabel()
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
        
        self.isScrollEnabled = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        self.layer.addSublayer(borderLayer)
        self.layer.masksToBounds = false
        self.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        self.addSubview(self.floatingPlaceholderLabel)
    }

    public func addButton(button: UIButton) {
        var trailingToView = self.layoutMarginsGuide.trailingAnchor
        var trailingConstant: CGFloat = -14
        if let lastButton = self.subviews.last(where: { $0 is UIButton }) {
            trailingToView = lastButton.leadingAnchor
            trailingConstant = -28
        }

        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingToView, constant: trailingConstant).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        self.layoutIfNeeded()
        self.textContainerInset.right = 14 + (self.frame.size.width -  button.frame.origin.x)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = self.bounds
    }
}

extension FloatingPlaceholderTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isEditing = true
        borderLayer.changeBorderColor(acitve: self.isEditing)
        self.floatingPlaceholderLabel.moveToFloatingPosition()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.isEditing = false
        borderLayer.changeBorderColor(acitve: self.isEditing)
        if self.isInputEmpty() {
            self.floatingPlaceholderLabel.moveToDefaultPosition()
        } else {
            self.floatingPlaceholderLabel.updateTextColor(shouldHighlight: false)
        }
    }
}

extension FloatingPlaceholderTextView: FloatingPlaceholderInputProtocol {
    func isInputEmpty() -> Bool {
        return self.text?.isEmpty ?? false
    }
}
