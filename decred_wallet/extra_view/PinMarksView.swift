//
//  PinMarksView.swift
//  
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class PinInputView: UIStackView {
    static let spacingBetweenPinCircles: CGFloat = 10.0
    static let maxNumberOfPinCircles = 5
    
    var maxNumberOfDigits: Int = Int(LONG_LONG_MAX)
    var pin: String = "" {
        didSet {
            self.setNeedsDisplay()
            // self.drawCells(in: self.frame)
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
        self.alignment = .center
        self.drawCells(in: frame)
    }
    
    func drawCells(in frame: CGRect) {
        // clear current views
        self.layer.sublayers?.removeAll()
        if self.arrangedSubviews.count > 0{
            self.removeArrangedSubview(self.arrangedSubviews[0])
        }
        
        if pin.count > PinInputView.maxNumberOfPinCircles {
            self.drawPinLabel()
        } else {
            self.drawPinCircles(in: frame)
        }
    }
    
    func drawPinLabel() {
        let pinDigitsCount = String(pin.count)
        
        let pinLabel = UILabel()
        pinLabel.text = String(pinDigitsCount)
        pinLabel.textAlignment = .center
        pinLabel.textColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1)
        pinLabel.font = pinLabel.font.withSize(25)
        
        self.addArrangedSubview(pinLabel)
    }
    
    func drawPinCircles(in frame: CGRect) {
        let maxWidthPerCircle = frame.width / CGFloat(PinInputView.maxNumberOfPinCircles)
        
        var eachCircleDiameter = frame.height * 0.8
        if eachCircleDiameter > maxWidthPerCircle {
            eachCircleDiameter = maxWidthPerCircle
        }
        
        var nextXPos = CGFloat(0)
        
        for _ in 0..<pin.count {
            self.drawPinCircle(in: frame, xPos: nextXPos, diameter: eachCircleDiameter)
            nextXPos += eachCircleDiameter + PinInputView.spacingBetweenPinCircles
        }
    }
    
    func drawPinCircle(in frame: CGRect, xPos: CGFloat, diameter: CGFloat) {
        let yCenter = frame.height / 2
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: xPos, y: yCenter),
            radius: diameter / 2,
            startAngle: 0.0,
            endAngle: 360.0,
            clockwise: true
        )
        
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath
        circleShape.fillColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1).cgColor
        circleShape.strokeColor = UIColor.white.cgColor
        circleShape.lineWidth = 2
        
        self.layer.addSublayer(circleShape)
    }
}
