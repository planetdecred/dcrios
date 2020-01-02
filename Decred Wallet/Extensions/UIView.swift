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
}

/// MARK: TODO remove this later coz it is already implemented
class ErrorBanner: UIView {
    private var parent:UIViewController?
    
    init(parent: UIViewController) {
        super.init(frame: .zero)
        self.parent = parent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(text:String) {
        guard let parent = self.parent else { return }
        if self.superview == parent.view { return }
        
        parent.view.addSubview(self)
        let guide = parent.view.safeAreaLayoutGuide
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor,constant: 8).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor,constant: -8).isActive = true
        self.topAnchor.constraint(equalTo: guide.topAnchor,constant: 84).isActive = true
        
        self.backgroundColor = UIColor.appColors.decredOrange
        self.layer.cornerRadius = 7;
        self.layer.shadowColor = UIColor.appColors.shadowColor.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.24
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        let errorLabel = UILabel()
        self.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10).isActive = true
        errorLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 5).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -5).isActive = true
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.textAlignment = .center
        errorLabel.textColor = .white
        errorLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        errorLabel.text = text
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss))
        swipeUpGesture.direction = .up
        self.addGestureRecognizer(swipeUpGesture)
        
        self.perform(#selector(self.dismiss), with: nil, afterDelay: 5)
    }
    
    @objc func dismiss() {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(dismiss),
                                               object: nil)
        if let parent = self.parent,
            self.superview == parent.view {
            self.removeFromSuperview()
        }
    }
}
