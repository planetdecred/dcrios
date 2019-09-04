//
//  FloatingTextInput.swift
//  Decred Wallet
//
//  Created by Sprinthub on 03/09/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

class FloatingTextInput: UITextField {
    
    
    var border = CALayer()
    var floatingLabel: UILabel!
    
    @IBInspectable
    var placeHolderText: String?
    
    @IBInspectable
    var floatingLabelColor: UIColor = UIColor.appColors.decredBlue {
        didSet {
            self.floatingLabel.textColor = floatingLabelColor
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var floatingLabelBackground: UIColor = UIColor.white.withAlphaComponent(1) {
        didSet {
            self.floatingLabel.backgroundColor = floatingLabelBackground
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var floatingLabelFont: UIFont = UIFont(name: "Source Sans Pro", size: 14)! {
        didSet {
            self.floatingLabel.font = floatingLabelFont
        }
    }
    
    var floatingLabelHeight: CGFloat = 14
    var button = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        floatingLabel = UILabel(frame: CGRect.zero)
        placeHolderText = (placeHolderText != nil) ? placeHolderText : placeholder
        layer.borderWidth = 0.8
        borderStyle = .roundedRect;
        
        self.addTarget(self, action: #selector(self.addFloatingLabel), for: .editingDidBegin)
        self.addTarget(self, action: #selector(self.removeFloatingLabel), for: .editingDidEnd)
        
    }
    
    // Add a floating label here
    @objc func addFloatingLabel(){
        if self.text == "" {
            floatingLabel.textColor = floatingLabelColor
            floatingLabel.font = floatingLabelFont
            floatingLabel.text = placeHolderText
            floatingLabel.isOpaque = true
            floatingLabel.sizeToFit()
            
            let constraints = [
                floatingLabel.heightAnchor.constraint(equalToConstant: floatingLabelHeight),
                floatingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                floatingLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: floatingLabelHeight/2),
            ]
            
            UIView.animate(withDuration: 4.0) {
                self.layer.borderColor = UIColor.appColors.decredBlue.cgColor
                self.addSubview(self.floatingLabel)
                NSLayoutConstraint.activate(constraints)
            }
            self.placeholder = ""
        }
        
        bringSubviewToFront(subviews.last!)
        self.setNeedsDisplay()
        
    }
    
    //Remove floating label
    @objc func removeFloatingLabel(){
        if self.text == "" {
            UIView.animate(withDuration: 0.13) {
                self.subviews.forEach{ $0.removeFromSuperview() }
                self.setNeedsDisplay()
            }
            self.placeholder = placeHolderText
        }
        layer.borderColor = UIColor.appColors.darkGray.cgColor
    }
    
    func addViewPasswordButton(){
        button.setImage(UIImage(named: "icon-eye"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
//        button.frame = CGRect(x: CGFloat(self.frame.size.width - 22), y: CGFloat(16), width: CGFloat(22), height: CGFloat(16))
        rightView = button
        rightViewMode = .always
        
        let buttonConstraints = [
            button.heightAnchor.constraint(equalToConstant: (self.frame.size.height-button.frame.size.height)/2),
            button.topAnchor.constraint(equalTo: self.topAnchor, constant: 17),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 16)
        ]
        NSLayoutConstraint.activate(buttonConstraints)
        button.addTarget(self, action: #selector(self.toggleSecureInput), for: .touchUpInside)
    }
    
    
    @objc func toggleSecureInput(){
        isSecureTextEntry.toggle()
    }
}
