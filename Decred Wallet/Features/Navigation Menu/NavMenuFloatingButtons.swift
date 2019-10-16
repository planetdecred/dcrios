//
//  NavMenuFloatingButtons.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class NavMenuFloatingButtons: UIView {
    
    let sendButton = UIButton(type: .custom)
    let receiveButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.layer.backgroundColor = UIColor.appColors.decredBlue.cgColor
        self.layer.cornerRadius = 24
        
        self.createButtons()
    }
    
    private func createButtons() {
        self.sendButton.setImage(UIImage(named: "nav_menu/ic_send"), for: .normal)
        self.sendButton.setTitle(LocalizedStrings.send.localizedCapitalized, for: .normal)
        self.sendButton.set(fontSize: 17, name: "Source Sans Pro")
        self.sendButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 24)
        self.sendButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.clipsToBounds = true
        self.sendButton.addTarget(self, action: #selector(self.sendTapped), for: .touchUpInside)

        self.receiveButton.setImage(UIImage(named: "nav_menu/ic_receive"), for: .normal)
        self.receiveButton.setTitle(LocalizedStrings.receive.localizedCapitalized, for: .normal)
        self.receiveButton.set(fontSize: 17, name: "Source Sans Pro")
        self.receiveButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 22)
        self.receiveButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.receiveButton.translatesAutoresizingMaskIntoConstraints = false
        self.receiveButton.clipsToBounds = true
        self.receiveButton.addTarget(self, action: #selector(self.receiveTapped), for: .touchUpInside)
        
        let separator = UIView(frame: CGRect.zero)
        separator.layer.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.7).cgColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.clipsToBounds = true
        
        self.addSubview(self.sendButton)
        self.addSubview(self.receiveButton)
        self.addSubview(separator)
        
        let constraints = [
            self.heightAnchor.constraint(equalToConstant: 48),
            
            self.sendButton.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.sendButton.widthAnchor.constraint(equalToConstant: 120),
            self.sendButton.topAnchor.constraint(equalTo: self.topAnchor),
            self.sendButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            
            self.receiveButton.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.receiveButton.widthAnchor.constraint(equalToConstant: 120),
            self.receiveButton.topAnchor.constraint(equalTo: self.topAnchor),
            self.receiveButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            
            separator.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0.5),
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.25),
            separator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        self.layoutIfNeeded()
        
    }
    
    @objc func sendTapped(_ sender: UIButton) {
        let sendVC = SendViewController.instance
        sendVC.modalPresentationStyle = .overFullScreen
        self.window?.rootViewController?.present(sendVC, animated: true)
    }
    
    @objc func receiveTapped(_ sender: UIButton) {
        let receiveVC = Storyboards.Main.instantiateViewController(for: ReceiveViewController.self).wrapInNavigationcontroller()
        receiveVC.modalPresentationStyle = .overFullScreen
        self.window?.rootViewController?.present(receiveVC, animated: true)
    }
}
