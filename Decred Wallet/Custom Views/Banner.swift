//
//  Banner.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

enum BannerType: String {
    case success
    case error
}

class Banner: UIView {
    public func show(parentVC: UIViewController?, type: BannerType, text: String) {
        guard let `parentVC` = parentVC else { return }
        
        parentVC.view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(greaterThanOrEqualTo: parentVC.view.leadingAnchor, constant: 8).isActive = true
        self.trailingAnchor.constraint(lessThanOrEqualTo: parentVC.view.trailingAnchor, constant: -8).isActive = true
        self.topAnchor.constraint(equalTo: parentVC.view.safeAreaLayoutGuide.topAnchor, constant: 84).isActive = true
        self.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor).isActive = true
        
        self.backgroundColor = (type == .error) ? UIColor.appColors.decredOrange : UIColor.appColors.decredGreen
        self.layer.cornerRadius = 7;
        self.layer.shadowColor = UIColor.appColors.darkBlue.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.24
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        let infoLabel = UILabel()
        self.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        infoLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.textAlignment = .center
        infoLabel.textColor = .white
        infoLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        infoLabel.text = text
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss))
        swipeUpGesture.direction = .up
        self.addGestureRecognizer(swipeUpGesture)
        
        self.perform(#selector(self.dismiss), with: nil, afterDelay: 5)
    }
    
    @objc func dismiss() {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(dismiss),
                                               object: nil)
        self.removeFromSuperview()
    }
}
