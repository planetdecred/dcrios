//
//  FloatingLabelTextInput.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class FloatingLabelTextInput: UITextField {
    var border = CALayer()
    var floatingLabel: UILabel!
    var floatingLabelHeight: CGFloat = 14
    var button = UIButton(type: .custom)
    
    @IBInspectable
    var _placeholder: String?
    
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.floatingLabel = UILabel(frame: CGRect.zero)
        self._placeholder = (self._placeholder != nil) ? self._placeholder : placeholder
        layer.borderWidth = 0.8
        borderStyle = .roundedRect;
        
        self.addTarget(self, action: #selector(self.addFloatingLabel), for: .editingDidBegin)
        self.addTarget(self, action: #selector(self.removeFloatingLabel), for: .editingDidEnd)
    }
    
    // Add a floating label to the view on becoming first responder
    @objc func addFloatingLabel() {
        if self.text == "" {
            self.floatingLabel.textColor = floatingLabelColor
            self.floatingLabel.font = floatingLabelFont
            self.floatingLabel.text = self._placeholder
            self.floatingLabel.layer.backgroundColor = UIColor.white.cgColor
            self.floatingLabel.translatesAutoresizingMaskIntoConstraints = false
            self.floatingLabel.clipsToBounds = true
            self.floatingLabel.frame = CGRect(x: 0, y: 0, width: floatingLabel.frame.width+4, height: floatingLabel.frame.height+2)
            self.floatingLabel.textAlignment = .center
            
            let constraints = [
                self.floatingLabel.heightAnchor.constraint(equalToConstant: floatingLabelHeight),
                self.floatingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                self.floatingLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -42),
            ]
            
            UIView.animate(withDuration: 4.0) {
                self.layer.borderColor = UIColor.appColors.decredBlue.cgColor
                self.addSubview(self.floatingLabel)
                NSLayoutConstraint.activate(constraints)
            }
            self.placeholder = ""
        }
        // Floating label may be stuck behind text input. we bring it forward as it was the last item added to the view heirachy
        self.bringSubviewToFront(subviews.last!)
        self.setNeedsDisplay()
    }
    
    @objc func removeFloatingLabel() {
        if self.text == "" {
            UIView.animate(withDuration: 0.13) {
                self.subviews.forEach{ $0.removeFromSuperview() }
                self.setNeedsDisplay()
            }
            self.placeholder = self._placeholder
        }
        layer.borderColor = UIColor.appColors.darkGray.cgColor
    }
    
    func addViewPasswordButton() {
        self.button.setImage(UIImage(named: "icon-eye"), for: .normal)
        self.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        self.button.frame = CGRect(x: CGFloat(self.frame.size.width - 22), y: CGFloat(16), width: CGFloat(22), height: CGFloat(16))
        rightView = button
        rightViewMode = .always
        self.button.addTarget(self, action: #selector(self.enablePasswordVisibilityToggle), for: .touchUpInside)
    }
    
    @objc func enablePasswordVisibilityToggle() {
        isSecureTextEntry.toggle()
        if isSecureTextEntry{
            self.button.setImage(UIImage(named: "icon-eye"), for: .normal)
        }else{
            self.button.setImage(UIImage(named: "ic_conceal_24px"), for: .normal)
        }
    }
}
