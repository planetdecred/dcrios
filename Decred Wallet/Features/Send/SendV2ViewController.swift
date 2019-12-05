//
//  SendViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

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
    @IBOutlet var sendingAmountTextField: UITextField!
    @IBOutlet var retryFechExchangeRateButton: UIButton!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var exchangeRateLabel: UILabel!
    @IBOutlet var exchangeRateIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var exchangeRateSeparatorView: UIView!
    @IBOutlet var exchangeRateLabelContainerView: NSLayoutConstraint!
    
    var overflowNavBarButton: UIBarButtonItem!
    var infoNavBarButton: UIBarButtonItem!
    var walletAccounts: [WalletAccount]?
    var sourceWallet: WalletAccount?
    var destinationWallet: WalletAccount?
    var exchangeRate: NSDecimalNumber?
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
    var shouldEnableSendButton: Bool {
        if !toSelfLayer.isHidden {
            guard destinationWallet != nil else {return false}
            return isValidAmount
        } else {
            guard let address = destinationAddress, !address.isEmpty else {return false}
            return isValidAmount
        }
    }
    var isValidAmount: Bool {
        self.notEnoughFundsLabel.text = ""
        guard let dcrAmountString = self.sendingAmountTextField.text, dcrAmountString != "" else { return false }
        
        if dcrAmountString.components(separatedBy: ".").count > 2 {
            // more than 1 decimal place
            self.notEnoughFundsLabel.text = LocalizedStrings.invalidAmount
            return false
        }
        
        let decimalPointIndex = dcrAmountString.firstIndex(of: ".")
        if decimalPointIndex != nil && dcrAmountString[decimalPointIndex!...].count > 9 {
            self.notEnoughFundsLabel.text = LocalizedStrings.amount8Decimal
            return false
        }
        
        guard let sendAmountDcr = Double(dcrAmountString), sendAmountDcr > 0 else {
            self.notEnoughFundsLabel.text = LocalizedStrings.invalidAmount
            return false
        }
        
        if sendAmountDcr > DcrlibwalletMaxAmountDcr {
            self.notEnoughFundsLabel.text = LocalizedStrings.amountMaximumAllowed
            return false
        }
        
        guard let source = sourceWallet else {return false}
        let sourceAccountBalance = source.Balance!.dcrSpendable
        if sendAmountDcr > sourceAccountBalance {
            self.notEnoughFundsLabel.text = self.insufficientFundsErrorMessage
            return false
        }
        
        return true
    }
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBarButtonItems()
        setUpViews()
        loadAccounts()
        sendingAmountTextField.addDoneButton()
        registerObserverForKeyboardNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit {
        unregisterObserverForKeyboardNotification()
    }
    
    private func loadAccounts() {
        let walletAccounts = AppDelegate.walletLoader.wallet!.walletAccounts(confirmations: self.requiredConfirmations)
            .filter({ !$0.isHidden && $0.Number != INT_MAX }) // remove hidden wallets from array
        self.walletAccounts = walletAccounts
        sourceWalletInfoLabel.text = walletAccounts[0].Name
        sourceWallet = walletAccounts[0]
        let spendableAmount = (Decimal(walletAccounts[0].Balance!.dcrSpendable) as NSDecimalNumber).round(8).formattedWithSeparator
        spendableAmountLabel.text = "Spendable: \(spendableAmount) DCR"
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

    private func fetchExchangeRate(_ sender: Any?) {
        self.retryFechExchangeRateButton.isHidden = true
        if self.exchangeRate == nil {
            self.exchangeRateLabel.text = "O USD"
        }
        
        switch Settings.currencyConversionOption {
        case .None:
            self.exchangeRate = nil
            exchangeRateLabel.text = ""
            exchangeRateIconHeightConstraint.constant = 0
            exchangeRateSeparatorView.isHidden = true
            exchangeRateLabelContainerView.constant = 0
            break
            
        case .Bittrex:
            ExchangeRates.Bittrex.fetch(callback: self.displayExchangeRate)
        }
    }
    
    func displayExchangeRate(_ exchangeRate: NSDecimalNumber?) {
        self.exchangeRate = exchangeRate
        
        guard let exchangeRate = exchangeRate, let dcrAmount = Double(sendingAmountTextField.text ?? "") else {
            self.exchangeRateLabel.text = "Exchange rate not fetched"
            self.exchangeRateLabel.textColor = .red
            return
        }
        exchangeRateLabel.textColor = UIColor.appColors.lightGray
        let usdAmount = NSDecimalNumber(value: dcrAmount).multiplying(by: exchangeRate)
        self.exchangeRateLabel.text = "\(usdAmount.round(8)) USD"
    }
    
    func registerObserverForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterObserverForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object:nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object:nil)
    }

    @objc func keyboardWillChange(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let keyboardViewEndFrame = view.convert(keyboardSize, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset
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
    
    func toggleSendButtonState(_ enabled: Bool) {
        nextButton.isEnabled = enabled
    }
    
    @objc func showOverflowMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)
        let clearFieldsAction = UIAlertAction(title: "Clear all fields", style: .default) { action in
            self.clearFields()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(clearFieldsAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func clearFields() {
        destinationWallet = nil
        receivingWalletAmount.text = "Select account"
        receivingWalletInfoLabel.text = ""
        destinationAdressTextField.text = ""
        invalidAddressLabel.text = ""
        exchangeRateLabel.text = "0 USD"
    }
    
    @objc func showInfoAlert() {
        let alertController = UIAlertController(title: "Send DCR", message: "Input or scan the destination wallet address and the amount in DCR to send funds", preferredStyle: .alert)
        let gotItAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        alertController.addAction(gotItAction)
        present(alertController, animated: true, completion: nil)
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
            self.toggleSendButtonState(self.shouldEnableSendButton)
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
            self.toggleSendButtonState(self.shouldEnableSendButton)
        } else if textField.tag == 1{
            displayExchangeRate(self.exchangeRate)
            self.toggleSendButtonState(self.shouldEnableSendButton)
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
