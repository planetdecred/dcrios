//
//  LoadingView.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
//

import Foundation
import UIKit

@IBDesignable
class LoadingView: UIView {
    private var image: UIImage?
    @IBInspectable var icon: UIImage = UIImage(named: "btn_spinner")! {
        didSet {
            self.image = icon
            self.setupView()
        }
    }
    func setupView() {
        let loaderIcon = UIImageView()
        loaderIcon.translatesAutoresizingMaskIntoConstraints = false
        loaderIcon.image = self.image!
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        self.addSubview(loaderIcon)
        loaderIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        loaderIcon.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        loaderIcon.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        loaderIcon.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.backgroundColor = .clear
        loaderIcon.layer.removeAllAnimations()

        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        loaderIcon.layer.add(rotation, forKey: "rotationAnimation")
    }
}
