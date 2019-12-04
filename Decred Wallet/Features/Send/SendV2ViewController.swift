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
    @IBOutlet var transactionFeeDetails: UIStackView!
    @IBOutlet var amountContainerViewHeight: NSLayoutConstraint!
    @IBOutlet var sourceWalletAmount: UILabel!
    @IBOutlet var sourceWalletInfoLabel: UILabel!
    @IBOutlet var receivingWalletInfoLabel: UILabel!
    @IBOutlet var receivingWalletAmount: UILabel!
    @IBOutlet var spendableAmountLabel: UILabel!
    @IBOutlet var destinationAddressTextField: UITextField!
    @IBOutlet var pasteButton: UIButton!
    @IBOutlet var showHideTransactionFeeDetailsButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    var overflowNavBarButton: UIBarButtonItem!
    var infoNavBarButton: UIBarButtonItem!
    var walletAccounts: [WalletAccount]?
    var sourceWallet: WalletAccount?
    var destinationWallet: WalletAccount?
    var destinationAddress: String?
    private lazy var qrImageScanner = QRImageScanner()

    var requiredConfirmations: Int32 {
        return Settings.spendUnconfirmed ? 0 : GlobalConstants.Wallet.defaultRequiredConfirmations
    }

    var insufficientFundsErrorMessage: String {
        if AppDelegate.walletLoader.syncer.connectedPeersCount > 0 {
            return LocalizedStrings.notEnoughFunds
        } else {
            return LocalizedStrings.notEnoughFundsOrNotConnected
        }
    }
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBarButtonItems()
        setUpViews()
        loadAccounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func loadAccounts() {
        let walletAccounts = AppDelegate.walletLoader.wallet!.walletAccounts(confirmations: self.requiredConfirmations)
            .filter({ !$0.isHidden && $0.Number != INT_MAX }) // remove hidden wallets from array
        self.walletAccounts = walletAccounts
        sourceWalletInfoLabel.text = walletAccounts[0].Name
        sourceWallet = walletAccounts[0]
        let spendableAmount = (Decimal(walletAccounts[0].Balance!.dcrSpendable) as NSDecimalNumber).round(8).formattedWithSeparator
        spendableAmountLabel.text = "\(spendableAmount) DCR"
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
        showHideTransactionFeeDetails(showHideTransactionFeeDetailsButton)
        nextButton.setBackgroundColor(UIColor.appColors.lighterGray, for: .disabled)
    }
    
    func checkAddressFromQrCode(textScannedFromQRCode: String?) {
        guard var capturedText = textScannedFromQRCode else {
            self.destinationAddressTextField.text = ""
            return
        }
        
        if capturedText.starts(with: "decred:") {
            capturedText = capturedText.replacingOccurrences(of: "decred:", with: "")
        }
        
        if capturedText.count < 25 {
//            self.invalidAddressFromQrCode(errorMessage: LocalizedStrings.walletAddressShort)
            return
        }
        if capturedText.count > 36 {
//            self.invalidAddressFromQrCode(errorMessage: LocalizedStrings.walletAddressLong)
            return
        }
        
        if BuildConfig.IsTestNet {
            if capturedText.starts(with: "T") {
                self.destinationAddressTextField.text = capturedText
            } else {
//                self.invalidAddressFromQrCode(errorMessage: LocalizedStrings.invalidTesnetAddress)
            }
        } else {
            if capturedText.starts(with: "D") {
                self.destinationAddressTextField.text = capturedText
            } else {
//                self.invalidAddressFromQrCode(errorMessage: LocalizedStrings.invalidMainnetAddress)
            }
        }
    }
    
    @objc func showOverflowMenu() {
    }
    
    @objc func showInfoAlert() {
        
    }

    @IBAction func pasteDestinationAddress(_ sender: UIButton) {
        destinationAddressTextField.text = UIPasteboard.general.string
        destinationAddress = UIPasteboard.general.string
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
    
    @IBAction func showHideTransactionFeeDetails(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        let isHidden = !self.transactionFeeDetails.isHidden
                        let icon = isHidden ? UIImage(named: "ic-expand-more") : UIImage(named: "ic-expand-less")
                        sender.setImage(icon, for: .normal)
                        self.transactionFeeDetails.isHidden = isHidden
                        self.amountContainerViewHeight.constant = isHidden ? (self.amountContainerViewHeight.constant - self.transactionFeeDetails.frame.height) : (self.amountContainerViewHeight.constant + self.transactionFeeDetails.frame.height)
        }, completion: nil)
    }
    
    @IBAction func selectSendingWallet(_ sender: UIButton) {
        guard let wallets = walletAccounts else {return}
        sender.setImage(UIImage(named: "arrorup"), for: .normal)
        let vc = WalletChooserTableViewController(wallets: wallets, selected: sourceWallet)
        vc.didSelectAccount = { (account: WalletAccount?) -> () in
            if let account = account {
                self.sourceWalletInfoLabel.text = account.Name
                let amountInWalletText = (Decimal(account.Balance!.dcrTotal) as NSDecimalNumber).round(8).formattedWithSeparator
                self.sourceWalletAmount.text = "\(amountInWalletText) DCR"
                self.sourceWallet = account
            }
            sender.setImage(UIImage(named: "arrow-1"), for: .normal)
        }
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func selectReceivingWallet(_ sender: UIButton) {
        guard let wallets = walletAccounts else {return}
        sender.setImage(UIImage(named: "arrorup"), for: .normal)
        let vc = WalletChooserTableViewController(wallets: wallets, selected: destinationWallet)
        vc.didSelectAccount = { (account: WalletAccount?) -> () in
            if let account = account {
                self.receivingWalletInfoLabel.text = account.Name
                let amountInWalletText = (Decimal(account.Balance!.dcrTotal) as NSDecimalNumber).round(8).formattedWithSeparator
                self.receivingWalletAmount.text = "\(amountInWalletText) DCR"
                self.destinationWallet = account
            }
            sender.setImage(UIImage(named: "arrow-1"), for: .normal)
        }
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func scan(_ sender: UIButton) {
        self.qrImageScanner.scan(sender: self, onTextScanned: self.checkAddressFromQrCode)
    }
}

extension SendV2ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Address field
        if textField.tag == 0 {
            destinationAddressContainerView.layer.borderColor = UIColor.appColors.decredBlue.cgColor
            destinationAddressLabel.textColor = UIColor.appColors.decredBlue
            pasteButton.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Address field
        if textField.tag == 0 {
            destinationAddressContainerView.layer.borderColor = UIColor.appColors.lightGray.cgColor
            destinationAddressLabel.textColor = UIColor.appColors.lighterGray
            pasteButton.isHidden = true
        }
    }
}
