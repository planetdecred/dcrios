//
//  SendViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SendFundsViewController: UIViewController {
    static let instance = Storyboards.Send.instantiateViewController(for: SendFundsViewController.self).wrapInNavigationcontroller()

    @IBOutlet var amountLayer: UIView!
    @IBOutlet var fromLayer: UIView!
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
    @IBOutlet var rateConversionContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var balanceAfterSend: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var exchangeRateLabel: UILabel!
    @IBOutlet var exchangeRateIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet var exchangeRateSeparatorView: UIView!
    @IBOutlet var exchangeRateLabelContainerView: NSLayoutConstraint!
    @IBOutlet var totalCostLabel: UILabel!
    
    @IBOutlet var transactionSizeLabel: UILabel!
    @IBOutlet var feeRateLabel: UILabel!
    @IBOutlet var processingTimeLabel: UILabel!
    
    var overflowNavBarButton: UIBarButtonItem!
    var infoNavBarButton: UIBarButtonItem!
    var walletAccounts: [DcrlibwalletAccount]?
    var sourceWallet: DcrlibwalletAccount?
    var destinationWallet: DcrlibwalletAccount?
    var exchangeRate: NSDecimalNumber?
    var destinationAddress: String?
    var sendMax: Bool = false
    var sendFundsDelegate: SendFundsDelegate?
    private lazy var qrImageScanner = QRImageScanner()
    let exchangeRateIconHeight: CGFloat = 20
    lazy var errorView: ErrorBanner = {
        let view = ErrorBanner(parent: self)
        return view
    }()

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
        let sourceAccountBalance = source.balance!.dcrSpendable
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
        fetchExchangeRate(nil)
    }

    deinit {
        unregisterObserverForKeyboardNotification()
    }
    
    private func loadAccounts() {
        let walletAccounts = AppDelegate.walletLoader.wallet!.walletAccounts(confirmations: self.requiredConfirmations)
            .filter({ !$0.isHidden && $0.number != INT_MAX }) // remove hidden wallets from array
        self.walletAccounts = walletAccounts
        sourceWalletInfoLabel.text = walletAccounts[0].name
        sourceWallet = walletAccounts[0]
        let spendableAmount = (Decimal(walletAccounts[0].balance!.dcrSpendable) as NSDecimalNumber).round(8).formattedWithSeparator
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

    @IBAction func proceedToConfirmSend(_ sender: Any) {
        let vc = ConfirmToSendViewController.instance
        self.prepareTxSummary(isSendAttempt: false) { sendAmountDcr, _, txFeeAndSize in
            guard let sourceAccountBalance = self.sourceWallet?.balance!.dcrSpendable else {return}
            let textFeeSize = txFeeAndSize.fee?.dcrValue ?? 0.0
            let balanceAfterSending = Decimal(sourceAccountBalance - sendAmountDcr - textFeeSize) as NSDecimalNumber
            let balanceAfterSendingText = "\(balanceAfterSending.round(8).formattedWithSeparator) DCR"
            let totalCost = Decimal(sendAmountDcr + textFeeSize) as NSDecimalNumber
            let totalCostText = "\(totalCost) DCR"
            let transactionFeeText = estimatedFee(for: txFeeAndSize.fee?.dcrValue ?? 0.0)
            let details = SendingDetails(amount: sendAmountDcr,
                                              destinationAddress: self.destinationAddress,
                                              destinationWallet: self.destinationWallet,
                                              sourceWallet: sourceWallet,
                                              transactionFee: transactionFeeText,
                                              balanceAfterSend: balanceAfterSendingText,
                                              totalCost: totalCostText,
                                              sendMax: self.sendMax)
            vc.sendingDetails = details
            vc.modalPresentationStyle = .custom
            present(vc, animated: true, completion: nil)
        }
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
            rateConversionContainerViewHeightConstraint.constant = (rateConversionContainerViewHeightConstraint.constant - (exchangeRateIconHeight * 2))
            amountContainerViewHeight.constant = (amountContainerViewHeight.constant - (exchangeRateIconHeight * 2))
            break
            
        case .Bittrex:
            ExchangeRates.Bittrex.fetch(callback: self.displayExchangeRate)
        }
    }
    
    func displayExchangeRate(_ exchangeRate: NSDecimalNumber?) {
        self.exchangeRate = exchangeRate
        guard let exchangeRate = exchangeRate, let dcrAmount = Double(sendingAmountTextField.text ?? "") else {
            let exchangeRateSeparatorViewWasPreviouslyHidden = exchangeRateSeparatorView.isHidden
            exchangeRateLabel.text = "Exchange rate not fetched"
            exchangeRateLabel.textColor = .red
            retryFechExchangeRateButton.isHidden = false
            exchangeRateSeparatorView.isHidden = false
            if exchangeRateSeparatorViewWasPreviouslyHidden {
                exchangeRateIconHeightConstraint.constant = exchangeRateIconHeight
                exchangeRateLabelContainerView.constant = exchangeRateIconHeight
                rateConversionContainerViewHeightConstraint.constant = (rateConversionContainerViewHeightConstraint.constant + (exchangeRateIconHeight * 2))
                amountContainerViewHeight.constant = (amountContainerViewHeight.constant + (exchangeRateIconHeight * 2))
            }
            return
        }
        exchangeRateLabel.textColor = UIColor.appColors.lightGray
        let usdAmount = NSDecimalNumber(value: dcrAmount).multiplying(by: exchangeRate)
        self.exchangeRateLabel.text = "\(usdAmount.round(8)) USD"
    }
    
    func clearTxSummary() {
        feeRateLabel.text = "0.00 DCR"
        transactionSizeLabel.text = "0 bytes"
        processingTimeLabel.text = "≈ -- blocks"
    }
    
    func getDestinationAddress(isSendAttempt: Bool) -> String? {
        // Display destination address error only if this a send attempt.
        let validDestinationAddress = self.getValidDestinationAddress(displayErrorOnUI: isSendAttempt)
        
        if !isSendAttempt && validDestinationAddress == nil, let account = sourceWallet {
            // Generate temporary address from wallet.
            return self.generateAddress(from: account)
        }
        
        return validDestinationAddress
    }
    func generateAddress(from account: DcrlibwalletAccount) -> String? {
        var generateAddressError: NSError?
        let destinationAddress = AppDelegate.walletLoader.wallet!.currentAddress(account.number, error: &generateAddressError)
        if generateAddressError != nil {
            print("send page -> generate address for destination account error: \(generateAddressError!.localizedDescription)")
            return nil
        }
        return destinationAddress
    }
    func getValidDestinationAddress(displayErrorOnUI: Bool) -> String? {
        if !toSelfLayer.isHidden {
            // Sending to account, generate an address to use.
            guard let destinationAccount = destinationWallet else {return nil}
            return self.generateAddress(from: destinationAccount)
        }
        
        // Sending to address, ensure that destinationAddressTextField.text is not nil and it's not empty string either.
        guard let destinationAddress = self.destinationAddressTextField.text, !destinationAddress.isEmpty else {
            if displayErrorOnUI {
                self.invalidAddressLabel.text = LocalizedStrings.emptyDestAddr
            }
            return nil
        }
        
        // Also ensure that destinationAddressTextField.text is a valid address.
        guard AppDelegate.walletLoader.wallet!.isAddressValid(destinationAddress) else {
            if displayErrorOnUI {
                self.invalidAddressLabel.text = LocalizedStrings.invalidDestAddr
            }
            return nil
        }
        
        return destinationAddress
    }
    
    func displayTransactionSummary() {
        self.prepareTxSummary(isSendAttempt: false) { sendAmountDcr, _, txFeeAndSize in
            guard let sourceAccountBalance = self.sourceWallet?.balance!.dcrSpendable else {return}
            let balanceAfterSending = Decimal(sourceAccountBalance - sendAmountDcr - txFeeAndSize.fee!.dcrValue) as NSDecimalNumber
            let totalCost = Decimal(sendAmountDcr + txFeeAndSize.fee!.dcrValue) as NSDecimalNumber
            
            self.displayEstimatedFee(dcrFee: txFeeAndSize.fee!.dcrValue)
            self.transactionSizeLabel.text = "\(txFeeAndSize.estimatedSignedSize) bytes"
            self.balanceAfterSend.text = "\(balanceAfterSending.round(8).formattedWithSeparator) DCR"
            self.totalCostLabel.text = "\(totalCost) DCR"
        }
    }

    func displayEstimatedFee(dcrFee: Double) {
        feeRateLabel.text = estimatedFee(for: dcrFee)
    }
    
    func estimatedFee(for amount: Double)-> String {
        guard let txFee = Decimal(amount) as NSDecimalNumber? else {
            return "0.00 DCR"
        }
        
        if self.exchangeRate == nil {
            return "\(txFee.formattedWithSeparator) DCR"
        } else {
            let usdFee = exchangeRate!.multiplying(by: txFee).formattedWithSeparator
            return "\(txFee.formattedWithSeparator) DCR\n(\(usdFee) USD)"
        }
    }

    func prepareTxSummary(isSendAttempt: Bool, completion: (Double, String, DcrlibwalletTxFeeAndSize) -> Void) {
        guard let dcrAmountString = self.sendingAmountTextField.text, !dcrAmountString.isEmpty,
            let sendAmountDcr = Double(dcrAmountString), sendAmountDcr > 0 else {
                self.clearTxSummary()
                if isSendAttempt {
                    self.notEnoughFundsLabel.text = LocalizedStrings.amountCantBeZero
                } else {
                    // disable send button
                    self.toggleSendButtonState(false)
                }
                return
        }
        
        // Send amount must be less than or equal to max amount.
        guard sendAmountDcr <= DcrlibwalletMaxAmountDcr else {
            // clear tx summary and disable send button
            self.clearTxSummary()
            self.toggleSendButtonState(false)
            return
        }
        
        guard let destinationAddress = self.getDestinationAddress(isSendAttempt: isSendAttempt) else {
            if !isSendAttempt {
                // clear tx summary and disable send button
                self.clearTxSummary()
                self.toggleSendButtonState(false)
            }
            return
        }
        
        do {
            guard let sourceAccount = sourceWallet else {return}
            let sendAmountAtom = DcrlibwalletAmountAtom(sendAmountDcr)
            let sourceAccountNumber = sourceAccount.number
            
            let newTx = AppDelegate.walletLoader.wallet!.newUnsignedTx(sourceAccountNumber,
                                                                       requiredConfirmations: self.requiredConfirmations)
            newTx?.addSendDestination(destinationAddress,
                                      atomAmount: sendAmountAtom,
                                      sendMax: self.sendMax)
            
            let txFeeAndSize = try newTx?.estimateFeeAndSize()
            completion(sendAmountDcr, destinationAddress, txFeeAndSize!)
        } catch let error {
            // there's an error somewhere, clear tx summary and disable send button
            self.clearTxSummary()
            self.toggleSendButtonState(false)
            if error.localizedDescription == "insufficient_balance" {
                self.notEnoughFundsLabel.text = self.insufficientFundsErrorMessage
                self.notEnoughFundsLabel.textColor = .red
            } else {
                print("get tx fee/size error: \(error.localizedDescription)")
                if isSendAttempt {
                    self.showSendError(LocalizedStrings.unexpectedError)
                }
            }
        }
    }
    func showSendError(_ errorMessage: String) {
        errorView.show(text: errorMessage)
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
    
    @objc func dcrAmountTextFieldChanged(sendMax: Bool = false) {
        defer {
            self.toggleSendButtonState(shouldEnableSendButton)
            self.displayTransactionSummary()
        }

        self.sendMax = sendMax
        let dcrAmountString = self.sendingAmountTextField.text ?? ""

        guard let dcrAmount = Double(dcrAmountString), let exchangeRate = self.exchangeRate else {
            self.exchangeRateLabel.text = ""
            return
        }

        let usdAmount = NSDecimalNumber(value: dcrAmount).multiplying(by: exchangeRate)
        self.exchangeRateLabel.text = "\(usdAmount.round(8)) USD"
    }
    
    private func setUpViews() {
        destinationAddressContainerView.layer.borderColor = UIColor.appColors.lighterGray.cgColor
        amountContainerView.layer.borderColor = UIColor.appColors.lighterGray.cgColor
        showHideTransactionFeeDetails(showHideTransactionFeeDetailsButton)
        nextButton.setBackgroundColor(UIColor.appColors.lighterGray, for: .disabled)

        // shadows
        fromLayer.layer.shadowRadius = 16.0
        fromLayer.layer.shadowColor = UIColor(red: 0.04, green: 0.08, blue: 0.25, alpha: 1.0).cgColor
        fromLayer.layer.shadowOffset = .zero
        fromLayer.layer.shadowOpacity = 0.06

        toSelfLayer.layer.shadowRadius = 16.0
        toSelfLayer.layer.shadowColor = UIColor(red: 0.04, green: 0.08, blue: 0.25, alpha: 1.0).cgColor
        toSelfLayer.layer.shadowOffset = .zero
        toSelfLayer.layer.shadowOpacity = 0.06

        toOthersLayer.layer.shadowRadius = 16.0
        toOthersLayer.layer.shadowColor = UIColor(red: 0.04, green: 0.08, blue: 0.25, alpha: 1.0).cgColor
        toOthersLayer.layer.shadowOffset = .zero
        toOthersLayer.layer.shadowOpacity = 0.06

        amountLayer.layer.shadowRadius = 16.0
        amountLayer.layer.shadowColor = UIColor(red: 0.04, green: 0.08, blue: 0.25, alpha: 1.0).cgColor
        amountLayer.layer.shadowOffset = .zero
        amountLayer.layer.shadowOpacity = 0.06
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
            errorView.show(text: LocalizedStrings.walletAddressShort)
            return
        }
        if capturedText.count > 36 {
            errorView.show(text: LocalizedStrings.walletAddressLong)
            return
        }
        
        if BuildConfig.IsTestNet {
            if capturedText.starts(with: "T") {
                self.destinationAddressTextField.text = capturedText
            } else {
                errorView.show(text: LocalizedStrings.invalidTesnetAddress)
            }
        } else {
            if capturedText.starts(with: "D") {
                self.destinationAddressTextField.text = capturedText
            } else {
                errorView.show(text: LocalizedStrings.invalidMainnetAddress)
            }
        }
    }
    
    func toggleSendButtonState(_ enabled: Bool) {
        nextButton.isEnabled = enabled
    }
    
    func calculateAndDisplayMaxSendableAmount() {
        guard let sourceAccount = sourceWallet else {return}
        sendMax = true
        if sourceAccount.balance?.spendable == 0 {
            // nothing to send
            self.notEnoughFundsLabel.text = self.insufficientFundsErrorMessage
            return
        }
        
        let destinationAddress = self.getDestinationAddress(isSendAttempt: false)
        let wallet = AppDelegate.walletLoader.wallet!
        
        do {
            let newTx = wallet.newUnsignedTx(sourceAccount.number, requiredConfirmations: self.requiredConfirmations)
            newTx?.addSendDestination(destinationAddress, atomAmount: 0, sendMax: sendMax)
            let maxSendableAmount = try newTx?.estimateMaxSendAmount()
            
            let maxSendableAmountDecimal = Decimal(maxSendableAmount!.dcrValue) as NSDecimalNumber
            self.sendingAmountTextField.text = "\(maxSendableAmountDecimal.round(8))"
            self.dcrAmountTextFieldChanged(sendMax: true)
        } catch let error {
            print("get send max amount error: \(error.localizedDescription)")
            self.notEnoughFundsLabel.text = LocalizedStrings.errorGettingMaxSpendable
        }
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
        exchangeRateLabel.textColor = UIColor.appColors.thinGray
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

    @IBAction func sendMaxTap(_ sender: UIButton) {
        self.calculateAndDisplayMaxSendableAmount()
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
        vc.didSelectAccount = { (account: DcrlibwalletAccount?) -> () in
            if let account = account {
                self.sourceWalletInfoLabel.text = account.name
                let amountInWalletText = (Decimal(account.balance!.dcrTotal) as NSDecimalNumber).round(8).formattedWithSeparator
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
        vc.didSelectAccount = { (account: DcrlibwalletAccount?) -> () in
            if let account = account {
                self.receivingWalletInfoLabel.text = account.name
                let amountInWalletText = (Decimal(account.balance!.dcrTotal) as NSDecimalNumber).round(8).formattedWithSeparator
                self.receivingWalletAmount.text = "\(amountInWalletText) DCR"
                self.destinationWallet = account
            }
            sender.setImage(UIImage(named: "arrow-1"), for: .normal)
            self.toggleSendButtonState(self.shouldEnableSendButton)
        }
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }

    @IBAction func retryExchangeRateFetch(_ sender: UIButton) {
        fetchExchangeRate(sender)
    }

    @IBAction func scan(_ sender: UIButton) {
        self.qrImageScanner.scan(sender: self, onTextScanned: self.checkAddressFromQrCode)
    }
}

extension SendFundsViewController: UITextFieldDelegate {

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

extension SendFundsViewController: SendFundsDelegate {
    func successfullySentFunds() {
        sendFundsDelegate?.successfullySentFunds()
        dismiss(animated: true, completion: nil)
    }
}
