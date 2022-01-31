///
//  UIColor.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

extension UIView {
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String.className(viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }
    
    /// Shows horizontal border by adding a sublayer at specified position on UIView.
    ///
    /// - Parameters:
    ///   - borderColor: Color to set for the border. If ignored White is used by default
    ///   - yPosition: Y Axis position where the border will be shown.
    ///   - borderHeight: Height of the border.
    @discardableResult public func horizontalBorder(borderColor: UIColor = UIColor.white, yPosition: CGFloat = 0, borderHeight: CGFloat = 1.0) -> UIView {
        let lowerBorder = CALayer()
        lowerBorder.backgroundColor = borderColor.cgColor
        lowerBorder.frame = CGRect(x: 0, y: yPosition, width: frame.width, height: borderHeight)
        layer.addSublayer(lowerBorder)
        clipsToBounds = true
        return self
    }
    
    func setRoundCorners(corners: UIRectCorner, radius: CGFloat) {
       let path = UIBezierPath(roundedRect: bounds,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
       let mask = CAShapeLayer()
       mask.path = path.cgPath
       layer.mask = mask
   }
    
    func dropShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat, spread: CGFloat) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        
        if spread == 0 {
            self.layer.shadowPath = nil
        } else {
            let shadowRect = self.bounds.insetBy(dx: -spread, dy: -spread)
            self.layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: self.layer.cornerRadius).cgPath
        }
    }
    
    func secureView() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let field = UITextField()
            field.isSecureTextEntry = true
            self.addSubview(field)
            field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.layer.superlayer?.addSublayer(field.layer)
            field.layer.sublayers?.first?.addSublayer(self.layer)
        }
    }
}
