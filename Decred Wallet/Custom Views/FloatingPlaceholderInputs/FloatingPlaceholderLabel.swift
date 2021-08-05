//
//  FloatingPlaceholderLabel.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class FloatingPlaceholderLabel: UILabel {
    @IBInspectable var topPadding: CGFloat = 0
    @IBInspectable var bottomPadding: CGFloat = 0
    @IBInspectable var leftPadding: CGFloat = 4
    @IBInspectable var rightPadding: CGFloat = 4

    var topConstraint: NSLayoutConstraint?

    let normalColor: UIColor = UIColor.appColors.text3
    var activeColor: UIColor = UIColor.appColors.primary
    let normalFontSize: CGFloat = 16
    let smallerFontSize: CGFloat = 14

    override var text: String? {
        didSet {
            // set position after the text did set, since the label position
            // calculated in real-time using the height of the label
            self.positionPlaceholder()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }

    public func initView() {
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = self.normalColor
        self.positionPlaceholder()
    }

    private func positionPlaceholder() {
        guard let floatingLabelInput = superview as? FloatingPlaceholderInputProtocol else { return }

        self.font = self.font.withSize(floatingLabelInput.isInputEmpty() ? self.normalFontSize : self.smallerFontSize)
        self.sizeToFit()

        let calculatedTopConstraintValue = floatingLabelInput.isInputEmpty() ? (self.superview!.frame.size.height - self.intrinsicContentSize.height) / 2 : self.intrinsicContentSize.height / -2

        if self.topConstraint == nil {
            self.topConstraint = self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: calculatedTopConstraintValue)
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: 16),
                self.topConstraint!
            ])
        } else {
            self.topConstraint?.constant = calculatedTopConstraintValue
        }
    }

    func moveToFloatingPosition() {
        UIView.animate(withDuration: 0.1) {
            self.textColor = self.activeColor
            self.font = self.font.withSize(self.smallerFontSize)
            self.topConstraint?.constant = self.intrinsicContentSize.height / -2
            self.superview?.layoutIfNeeded()
        }
    }

    func moveToDefaultPosition() {
        UIView.animate(withDuration: 0.1) {
            self.textColor = self.normalColor
            self.font = self.font.withSize(self.normalFontSize)
            self.topConstraint?.constant = (self.superview!.frame.size.height - self.intrinsicContentSize.height) / 2
            self.superview?.layoutIfNeeded()
        }
    }

    func updateTextColor(shouldHighlight: Bool) {
        self.textColor = shouldHighlight ? self.activeColor : self.normalColor
    }

    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        super.drawText(in: rect.inset(by: insets))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftPadding + rightPadding,
         height: size.height + topPadding + bottomPadding)
    }

    public override func sizeToFit() {
        super.sizeThatFits(intrinsicContentSize)
    }
}
