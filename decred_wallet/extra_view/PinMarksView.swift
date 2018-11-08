//
//  PinMarksView.swift
//  
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit

class PinMarksView: UIView {
    var total = 5
    var entered: Int
    let space:CGFloat = 10.0
    
    override init(frame: CGRect) {
        total = 5
        entered = 1
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        total = 5
        entered = 0
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        drawCells(in: rect, active: false)
        if entered > 0 {
            drawCells(in: rect, active: true)
        }
    }
    
    func drawCells(in rect:CGRect, active:Bool){
        let h = rect.size.height
        let w = rect.size.width / CGFloat(total) - space
        for i in 0...(total - 1) {
            let cellRect = CGRect(x: CGFloat(i) * w + space * CGFloat(i), y: 0, width: w, height: h)
            drawEmptyCell(rect: cellRect)
        }
        
        for i in 0...(entered) {
            let cellRect = CGRect(x: CGFloat(i) * w + space * CGFloat(i), y: 0, width: w, height: h)
            drawActiveCell(rect: cellRect)
        }
    }
    
    func drawEmptyCell(rect: CGRect){
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.size.height / 2), radius: rect.size.width / 2 * 0.8, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func drawActiveCell(rect: CGRect){
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.size.height / 2), radius: rect.size.width / 2 * 0.7, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1).cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        
        self.layer.addSublayer(shapeLayer)
    }

}
