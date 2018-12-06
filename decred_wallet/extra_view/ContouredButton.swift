//
//  ContouredButton.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

@IBDesignable class ContouredButton: UIButton {
    @IBInspectable var borderColor: UIColor?
    @IBInspectable var borderThick: CGFloat = 2
    @IBInspectable var cornerRadius: CGFloat = 5.0
    @IBInspectable var selectedStateColor: UIColor = #colorLiteral(red: 0.3111695647, green: 0.728333056, blue: 0.215497613, alpha: 1)
    @IBInspectable var backgroundFillColor: UIColor = #colorLiteral(red: 0.9623823762, green: 0.9688158631, blue: 0.9719761014, alpha: 1)
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.setStrokeColor((borderColor ?? UIColor.black).cgColor)
        context!.setLineWidth(borderThick)
        context!.setFillColor(isSelected ? selectedStateColor.cgColor :backgroundFillColor.cgColor)
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: borderThick / 2, dy: borderThick / 2), cornerRadius: cornerRadius)
        context?.addPath(path.cgPath)
        context!.drawPath(using: CGPathDrawingMode.fillStroke)
    }
}
