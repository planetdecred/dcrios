//
//  UIButton.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

extension UIButton {
    enum BorderPosition: String {
        case left
        case right
        case top
        case bottom
    }
    
    func addBorders(atPositions borderPositions: [BorderPosition], color: UIColor = UIColor.appColors.darkGray, thickness: CGFloat = 1.7) {
        borderPositions.forEach({ borderPosition in
            self.addBorder(atPosition: borderPosition, color: color, thickness: thickness)
        })
    }
    
    func addBorder(atPosition borderPosition: BorderPosition, color: UIColor = UIColor.appColors.darkGray, thickness: CGFloat = 1.7) {
        let borderLayer = CALayer()
        borderLayer.backgroundColor = color.cgColor
        borderLayer.name = "\(borderPosition.rawValue) border"
        
        switch borderPosition {
        case .left:
            borderLayer.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.size.height)
        case .right:
            borderLayer.frame = CGRect(x: frame.size.width - thickness, y: 0, width: thickness, height: frame.size.height)
        case .bottom:
            borderLayer.frame = CGRect(x: 0, y: frame.size.height - thickness, width: frame.size.width, height: thickness)
        case .top:
            borderLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: thickness)
        }
        
        self.layer.addSublayer(borderLayer)
        self.setNeedsLayout()
    }
    
    func removeBorders(atPositions borderPositions: BorderPosition...) {
        guard borderPositions.count > 0 else { return }
        
        let namesToRemove = borderPositions.map({ "\($0.rawValue) border" })
        guard let layersToRemove = self.layer.sublayers?.filter({ namesToRemove.contains($0.name ?? "") }) else { return }
        
        if layersToRemove.count > 0 {
            layersToRemove.forEach({ $0.removeFromSuperlayer() })
            self.setNeedsLayout()
        }
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: state)
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocalizedStringKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.getLocalizedString, for: .normal)
        }
    }
}
