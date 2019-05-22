//
//  Button.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 30/04/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

@IBDesignable
class Button: UIButton {
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            self.setNeedsLayout()
        }
    }
    
    func border(at: String, colorHex: String? = "#333333", thickness: CGFloat? = 1.7){
        let border = CALayer()
        border.backgroundColor = UIColor.init(hex: colorHex!).cgColor
        border.name = at
        switch at{
        case "left":
            border.frame = CGRect(x: 0, y: 0, width: thickness!, height: frame.size.height)
        case "right":
            border.frame = CGRect(x: frame.size.width - thickness!, y: 0, width: thickness!, height: frame.size.height)
        case "bottom":
            border.frame = CGRect(x: 0, y: frame.size.height - thickness!, width: frame.size.width, height: thickness!)
        case "top":
            border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: thickness!)
        default:
            break
        }
        layer.addSublayer(border)
        self.setNeedsLayout()
    }
    
    func removeBorders(){
        if let layers = layer.sublayers {
            for currentLayer in layers{
                if currentLayer.name == "bottom" || currentLayer.name == "left" || currentLayer.name == "right" || currentLayer.name == "top"{
                    currentLayer.removeFromSuperlayer()
                }
            }
            self.setNeedsLayout()
        }
    }
    
    
}
