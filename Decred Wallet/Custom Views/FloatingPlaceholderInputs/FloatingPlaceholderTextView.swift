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
    
    @IBInspectable var allowLineBreaks: Bool = true

    var textViewDelegate: FloatingPlaceholderTextViewDelegate?
    
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
    
    func setText(_ text: String) {
        self.textViewDidBeginEditing(self)
        self.text = text
        self.textViewDidEndEditing(self)
        self.textViewDidChange(self)
    }

    public func add(button: UIButton) {
        var trailingAnchor = self.layoutMarginsGuide.trailingAnchor
        var trailingConstant: CGFloat = -12
        
        if let lastButton = self.subviews.last(where: { $0 is UIButton }) {
            trailingAnchor = lastButton.leadingAnchor
            trailingConstant = -16
        }

        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.layoutIfNeeded()
        
        self.textContainerInset.right += button.frame.width + abs(trailingConstant)
    }
    
    public func toggleButtonVisibility(_ button: UIButton) {
        // only proceed if the button exists in this view heiriachy.
        guard self.subviews.first(where: { $0 == button }) != nil else { return }

        button.isHidden = !button.isHidden
        
        if !button.isHidden {
            // button was hidden but now visible
            // re-layout so we can get the accurate button width
            self.layoutIfNeeded()
        }
        
        var textContainerInsetAdjustment = button.frame.size.width
        if self.subviews.filter({ $0 is UIButton }).count == 1 {
            textContainerInsetAdjustment += 12
        } else {
            textContainerInsetAdjustment += 16
        }
        
        if button.isHidden {
            self.textContainerInset.right -= textContainerInsetAdjustment
        } else {
            self.textContainerInset.right += textContainerInsetAdjustment
        }
        
        self.layoutIfNeeded()
    }
    
    func showError() {
        self.borderLayer.activeBorderColor = UIColor.appColors.orange
        self.floatingPlaceholderLabel.activeColor = UIColor.appColors.orange
        self.borderLayer.changeBorderColor(acitve: self.isEditing)
        self.floatingPlaceholderLabel.updateTextColor(shouldHighlight: self.isEditing)
    }

    func hideError() {
        self.borderLayer.activeBorderColor = UIColor.appColors.primary
        self.floatingPlaceholderLabel.activeColor = UIColor.appColors.primary
        self.borderLayer.changeBorderColor(acitve: self.isEditing)
        self.floatingPlaceholderLabel.updateTextColor(shouldHighlight: self.isEditing)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = self.bounds
    }

    override var intrinsicContentSize: CGSize {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        let fixedWidth = self.frame.size.width
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let minHeight = self.floatingPlaceholderLabel.frame.size.height
            + self.textContainerInset.top + self.textContainerInset.bottom
        
        return CGSize(width: max(newSize.width, fixedWidth), height: max(newSize.height, minHeight))
    }
}

@objc protocol FloatingPlaceholderTextViewDelegate {
    @objc optional func textViewDidChange(_ textView: UITextView)
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if !self.allowLineBreaks && text.rangeOfCharacter(from: CharacterSet.newlines) != nil {
            self.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.textViewDelegate?.textViewDidChange?(textView)
    }
}

extension FloatingPlaceholderTextView: FloatingPlaceholderInputProtocol {
    func isInputEmpty() -> Bool {
        return self.text?.isEmpty ?? false
    }
}
