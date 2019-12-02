//
//  SendViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SendV2ViewController: UIViewController {
    static let instance = Storyboards.Send.instantiateViewController(for: SendV2ViewController.self).wrapInNavigationcontroller()

    @IBOutlet var toSelfLayer: UIView!
    @IBOutlet var toOthersLayer: UIView!
    @IBOutlet var destinationAddressLabel: UILabel!
    @IBOutlet var destinationAddressContainerView: UIView!
    @IBOutlet var destinationAdressTextField: UITextField!
    @IBOutlet var invalidAddressLabel: UILabel!
    @IBOutlet var notEnoughFundsLabel: UILabel!
    @IBOutlet var amountContainerView: UIView!
    
    var overflowNavBarButton: UIBarButtonItem!
    var infoNavBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBarButtonItems()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUpBarButtonItems() {
        let infoNavButton = UIButton(type: .custom)
        infoNavButton.setImage(UIImage(named: "ic-info"), for: .normal)
        infoNavButton.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
        infoNavButton.addTarget(self, action: #selector(self.showInfoAlert), for: .touchUpInside)
        self.infoNavBarButton = UIBarButtonItem(customView: infoNavButton)
        
        self.overflowNavBarButton = UIBarButtonItem(image: UIImage(named: "ic-more-horizontal"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(self.showOverflowMenu))
        
        let cancelBarButtonItem = UIBarButtonItem(image: UIImage(named: "cancel"),
                                                  style: .done, target: self,
                                                  action: #selector(navigateToBackScreen))
        let titleBarButtonItem = UIBarButtonItem(title: LocalizedStrings.send, style: .plain, target: self, action: nil)
        
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.rightBarButtonItems = [overflowNavBarButton, infoNavBarButton]
        navigationItem.leftBarButtonItems = [cancelBarButtonItem, titleBarButtonItem]
    }
    
    private func setUpViews() {
        destinationAddressContainerView.layer.borderColor = UIColor.appColors.lighterGray.cgColor
        amountContainerView.layer.borderColor = UIColor.appColors.lighterGray.cgColor
    }
    
    @objc func showOverflowMenu() {
    }
    
    @objc func showInfoAlert() {
        
    }

    @IBAction func sendToSelf(_ sender: Any) {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { 
                        self.toOthersLayer.isHidden = true
                        self.toSelfLayer.isHidden = false
        }, completion: nil)
    }

    @IBAction func sendToOthers(_ sender: Any) {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        self.toSelfLayer.isHidden = true
                        self.toOthersLayer.isHidden = false
        }, completion: nil)
    }
}

extension SendV2ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Address field
        if textField.tag == 0 {
            destinationAddressContainerView.layer.borderColor = UIColor.appColors.decredBlue.cgColor
            destinationAddressLabel.textColor = UIColor.appColors.decredBlue
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Address field
        if textField.tag == 0 {
            destinationAddressContainerView.layer.borderColor = UIColor.appColors.lightGray.cgColor
            destinationAddressLabel.textColor = UIColor.appColors.lighterGray
        }
    }
}
