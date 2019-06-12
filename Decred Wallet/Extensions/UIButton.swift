//
//  UIButton.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 24/05/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

extension UIButton {
    enum BorderPosition: String {
        case left
        case right
        case top
        case bottom
    }
    
    
    func addBorders(atPositions borderPositions: [BorderPosition], colorHex: String = "#4e5f70", thickness: CGFloat = 1.7) {
        borderPositions.forEach({ borderPosition in
            self.addBorder(atPosition: borderPosition, colorHex: colorHex, thickness: thickness)
        })
    }
    
    func addBorder(atPosition borderPosition: BorderPosition, colorHex: String = "#4e5f70", thickness: CGFloat = 1.7) {
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.init(hex: colorHex).cgColor
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
}
