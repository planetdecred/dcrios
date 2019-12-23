//
//  Button.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

@IBDesignable
class Button: UIButton {
    private let loaderIcon: UIImageView = UIImageView()
    private let loaderLabel: UILabel = UILabel()
    private var loaderView: UIView?
    private var originalButtonText: String?
    private var originalButtonBackground: UIColor?
    
    @IBInspectable var loaderTextStringKey: String = "" {
        didSet {
            loaderLabel.text = NSLocalizedString(loaderTextStringKey, comment: "")
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
           setupView()
        }
    }
    
    @IBInspectable var enabledBackgroundColor : UIColor? {
        didSet {
            setupView()
        }
    }

    @IBInspectable var disabledBackgroundColor : UIColor? {
        didSet {
            setupView()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            setupView()
        }
    }
    
    fileprivate func setupView() {
        if isEnabled && enabledBackgroundColor != nil {
            self.backgroundColor = enabledBackgroundColor
        } else if !isEnabled && disabledBackgroundColor != nil {
            self.backgroundColor = disabledBackgroundColor
        }
        
        self.layer.borderColor = self.borderColor.cgColor
        self.layer.borderWidth = self.borderWidth
        self.layer.cornerRadius = cornerRadius
        self.setNeedsDisplay()
    }
    
    public func startLoading() {
        if loaderView == nil {
            loaderView = UIView()
            self.addSubview(loaderView!)
            loaderView!.isHidden = true
            loaderView!.translatesAutoresizingMaskIntoConstraints = false
            loaderView!.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            loaderView!.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

            loaderView!.addSubview(loaderIcon)
            loaderIcon.translatesAutoresizingMaskIntoConstraints = false
            loaderIcon.image = UIImage(named: "btn_spinner")
            loaderIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
            loaderIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true

            loaderIcon.leadingAnchor.constraint(equalTo: loaderView!.leadingAnchor).isActive = true
            loaderIcon.topAnchor.constraint(equalTo: loaderView!.topAnchor).isActive = true
            loaderIcon.bottomAnchor.constraint(equalTo: loaderView!.bottomAnchor).isActive = true

            loaderView!.addSubview(loaderLabel)
            loaderLabel.translatesAutoresizingMaskIntoConstraints = false
            loaderLabel.font = UIFont(name: "SourceSansPro-Regular", size: 18)
            loaderLabel.textColor = UIColor.appColors.grayishBlue
            loaderLabel.leadingAnchor.constraint(equalTo: loaderIcon.trailingAnchor, constant: 10).isActive = true
            loaderLabel.trailingAnchor.constraint(equalTo: loaderView!.trailingAnchor).isActive = true
            loaderLabel.centerYAnchor.constraint(equalTo: loaderIcon.centerYAnchor).isActive = true
        }
        
        DispatchQueue.main.async {
            self.originalButtonBackground = self.backgroundColor
            self.originalButtonText = self.titleLabel?.text ?? ""
            self.backgroundColor = .clear
            self.setTitle("", for: .normal)
            self.loaderView!.isHidden = false
            self.loaderIcon.layer.removeAllAnimations()
            
            let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = NSNumber(value: Double.pi * 2)
            rotation.duration = 1
            rotation.isCumulative = true
            rotation.repeatCount = Float.greatestFiniteMagnitude
            self.loaderIcon.layer.add(rotation, forKey: "rotationAnimation")
        }
    }
    
    public func stopLoading() {
        DispatchQueue.main.async {
            self.setTitle(self.originalButtonText, for: .normal)
            self.backgroundColor = self.originalButtonBackground
            self.loaderIcon.layer.removeAllAnimations()
            self.loaderView?.isHidden = true
        }
    }
}
