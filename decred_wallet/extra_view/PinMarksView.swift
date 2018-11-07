//
//  PinMarksView.swift
//  
//
//  Created by Philipp Maluta on 11/7/18.
//

import UIKit

class PinMarksView: UIView {
    
    var entered: Int
    let space = 3.0
    
    override init(frame: CGRect) {
        total = 5
        entered = 0
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        total = 5
        entered = 0
        super.init(coder: aDecoder)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        drawEmptyCells(in: rect)
    }
    
    func  drawEmptyCells(in rect:CGRect){
        let h = rect.size.height
        let w = h
        for i in 0...total {
            let cellRect = CGRect(x: CGFloat(i) * w + CGFloat(space), y: 0, width: w, height: h)
            drawEmptyCell(rect: cellRect)
        }
    }
    
    func drawActiveCells(in rect:CGRect){
        
    }
    
    func drawEmptyCell(rect: CGRect){
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.size.width / 2, y: rect.size.height / 2), radius: rect.size.width, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        
        self.layer.addSublayer(shapeLayer)
    }
    

}
