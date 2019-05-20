//
//  PinMarksView.swift
//  
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class PinInputView: UIView {
    static let spacingBetweenPinCircles: CGFloat = 10.0
    static let circleBorderSizeFactor: CGFloat = 0.15
    static let maxNumberOfPinCircles = 5
    
    var maxNumberOfDigits: Int = Int(LONG_MAX)
    
    var pin: String = "" {
        didSet {
            self.subviews.forEach{ $0.removeFromSuperview() }
            self.setNeedsDisplay()
        }
    }
    
    func append(digit: Int) -> String {
        if (self.pin.count < self.maxNumberOfDigits) {
            self.pin += "\(digit)"
        }
        return self.pin
    }
    
    func backspace() -> String {
        self.pin = String(self.pin.dropLast())
        return self.pin
    }
    
    func clear() {
        self.pin = ""
    }
    
    override func draw(_ frame: CGRect) {
        self.layer.sublayers?.removeAll()
        self.drawCells(in: frame)
    }
    
    func drawCells(in frame: CGRect) {
        if pin.count > PinInputView.maxNumberOfPinCircles {
            self.drawPinLabel(in: frame)
        } else {
            self.drawPinCircles(in: frame)
        }
    }
    
    func drawPinLabel(in frame: CGRect) {
        // Set the label bounds to resolve any ambiguity. Using UILabel() without proper bounds causes the app to crash.
        let pinLabel = UILabel(frame: frame)
        
        pinLabel.text = String(pin.count)
        pinLabel.textAlignment = .center
        pinLabel.textColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1)
        pinLabel.font = pinLabel.font.withSize(25)
        
        self.addSubview(pinLabel)
    }
    
    func drawPinCircles(in frame: CGRect) {
        let maxWidthPerCircle = frame.width / CGFloat(PinInputView.maxNumberOfPinCircles)
        
        var eachCircleDiameter = frame.height * 0.8
        if eachCircleDiameter > maxWidthPerCircle {
            eachCircleDiameter = maxWidthPerCircle
        }
        
        // calculate x pos for first pin circle
        let totalPinCircleWidths = CGFloat(self.pin.count) * eachCircleDiameter
        let totalSpaceBetweenPins = CGFloat(self.pin.count - 1) * PinInputView.spacingBetweenPinCircles
        let totalPinCircleWidthPlusSpacing = totalPinCircleWidths + totalSpaceBetweenPins
        var nextXPos = (frame.width - totalPinCircleWidthPlusSpacing) / 2
        
        for _ in 0..<pin.count {
            self.drawPinCircle(in: frame, xPos: nextXPos, diameter: eachCircleDiameter)
            nextXPos += eachCircleDiameter + PinInputView.spacingBetweenPinCircles
        }
    }
    
    func drawPinCircle(in frame: CGRect, xPos: CGFloat, diameter: CGFloat) {
        let radius = diameter / 2
        let arcCenter = CGPoint(
            x: xPos + radius,
            y: frame.height / 2
        )
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 0.0, endAngle: 360.0, clockwise: true)
        
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath
        circleShape.fillColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1).cgColor
        circleShape.strokeColor = UIColor.white.cgColor
        circleShape.lineWidth = diameter * PinInputView.circleBorderSizeFactor
        
        self.layer.addSublayer(circleShape)
    }
}
