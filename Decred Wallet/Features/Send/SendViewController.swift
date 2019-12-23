//
//  SendViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SendViewController: UIViewController {
    static let instance = Storyboards.Send.instantiateViewController(for: SendViewController.self).wrapInNavigationcontroller()
    
    @IBOutlet weak var sourceAccountDropdown: DropMenuButton!
    
    @IBOutlet weak var addressRecipientView: UIStackView!
    @IBOutlet weak var destinationAccountView: UIStackView!
    @IBOutlet weak var destinationAccountDropdown: DropMenuButton!
    @IBOutlet weak var destinationAddressTextField: UITextField!
    @IBOutlet weak var pasteAddressButton: Button!
    @IBOutlet weak var scanQrCodeButton: UIButton!
    @IBOutlet weak var destinationErrorLabel: UILabel!
    
    @IBOutlet weak var dcrAmountTextField: UITextField!
    @IBOutlet weak var usdAmountTextField: UITextField!
    @IBOutlet weak var sendAmountErrorLabel: UILabel!
    
    @IBOutlet weak var estimatedFeeLabel: UILabel!
    @IBOutlet weak var estimatedTxSizeLabel: UILabel!
    @IBOutlet weak var balanceAfterSendingLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var exchangeRateErrorLabel: UILabel!
    
    @IBOutlet weak var sendErrorLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    // Good practice: create an instance of QRImageScanner lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode.
    private lazy var qrImageScanner = QRImageScanner()
    
    var overflowNavBarButton: UIBarButtonItem!
    
    var walletAccounts: [DcrlibwalletAccount]!
    var exchangeRate: NSDecimalNumber?
    var sendMaxAmount: Bool = false
    
    var requiredConfirmations: Int32 {
        return Settings.spendUnconfirmed ? 0 : GlobalConstants.Wallet.defaultRequiredConfirmations
    }
    
    var isValidDestination: Bool {
        if self.addressRecipientView.isHidden {
            return self.destinationAccountDropdown.selectedItemIndex >= 0
        }
        let destinationAddress = self.destinationAddressTextField.text ?? ""
        return AppDelegate.walletLoader.wallet!.isAddressValid(destinationAddress)
    }
    
    var isValidAmount: Bool {
        self.sendAmountErrorLabel.text = ""
        guard let dcrAmountString = self.dcrAmountTextField.text, dcrAmountString != "" else { return false }
        
        if dcrAmountString.components(separatedBy: ".").count > 2 ||
            (usdAmountTextField.text ?? "").components(separatedBy: ".").count > 2 {
            // more than 1 decimal place
            self.sendAmountErrorLabel.text = LocalizedStrings.invalidAmount
            return false
        }
        
        let decimalPointIndex = dcrAmountString.firstIndex(of: ".")
        if decimalPointIndex != nil && dcrAmountString[decimalPointIndex!...].count > 9 {
            self.sendAmountErrorLabel.text = LocalizedStrings.amount8Decimal
            return false
        }
        
        guard let sendAmountDcr = Double(dcrAmountString), sendAmountDcr > 0 else {
            self.sendAmountErrorLabel.text = LocalizedStrings.invalidAmount
            return false
        }
        
        if sendAmountDcr > DcrlibwalletMaxAmountDcr {
            self.sendAmountErrorLabel.text = LocalizedStrings.amountMaximumAllowed
            return false
        }
        
        let sourceAccountBalance = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex].balance!.dcrSpendable
        if sendAmountDcr > sourceAccountBalance {
            self.sendAmountErrorLabel.text = self.insufficientFundsErrorMessage
            return false
        }
        
        return true
    }
    
    var insufficientFundsErrorMessage: String {
        if AppDelegate.walletLoader.syncer.connectedPeersCount > 0 {
            return LocalizedStrings.notEnoughFunds
        } else {
            return LocalizedStrings.notEnoughFundsOrNotConnected
        }
    }
    
    override func viewDidLoad() {
        self.destinationAddressTextField.addTarget(self, action: #selector(self.addressTextFieldChanged), for: .editingChanged)
        self.dcrAmountTextField.addTarget(self, action: #selector(self.dcrAmountTextFieldChanged), for: .editingChanged)
        self.usdAmountTextField.addTarget(self, action: #selector(self.usdAmountTextFieldChanged), for: .editingChanged)
        
        self.destinationAddressTextField.placeholder = LocalizedStrings.destAddr
        
        self.hideKeyboardOnTapAround()
        self.resetViews()
    }
    
    func resetViews() {
        self.destinationAddressTextField.text = ""
        self.checkClipboardForValidAddress()
        self.scanQrCodeButton.isHidden = false
        self.destinationErrorLabel.text = ""
        
        self.dcrAmountTextField.text = ""
        self.usdAmountTextField.text = ""
        self.sendAmountErrorLabel.text = ""
        
        self.clearTxSummary()
        
        self.sendErrorLabel.isHidden = true
        self.toggleSendButtonState(addressValid: false, amountValid: false)
    
        let overflowMenuButton = UIButton(type: .custom)
        overflowMenuButton.setImage(UIImage(named: "right-menu"), for: .normal)
        overflowMenuButton.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
        overflowMenuButton.addTarget(self, action: #selector(self.showOverflowMenu), for: .touchUpInside)
        self.overflowNavBarButton = UIBarButtonItem(customView: overflowMenuButton)
    }
    
    @IBAction func fetchExchangeRate(_ sender: Any?) {
        self.exchangeRateErrorLabel.isHidden = true
        if self.exchangeRate == nil {
            self.usdAmountTextField.superview?.isHidden = true
            self.exchangeRateLabel.superview?.isHidden = true
        }
        
        switch Settings.currencyConversionOption {
        case .None:
            self.exchangeRate = nil
            self.usdAmountTextField.superview?.isHidden = true
            self.exchangeRateLabel.superview?.isHidden = true
            break
            
        case .Bittrex:
            ExchangeRates.Bittrex.fetch(callback: self.displayExchangeRate)
        }
    }
    
    func displayExchangeRate(_ exchangeRate: NSDecimalNumber?) {
        self.exchangeRate = exchangeRate
        let currencyConversionOption = Settings.currencyConversionOption.rawValue
        
        guard let exchangeRate = exchangeRate else {
            self.usdAmountTextField.superview?.isHidden = true
            self.exchangeRateLabel.superview?.isHidden = true
            self.exchangeRateErrorLabel.text = "\(currencyConversionOption.withFirstLetterCapital) \(LocalizedStrings.rateUnavailableTap)"
            self.exchangeRateErrorLabel.isHidden = false
            return
        }
        
        self.exchangeRateLabel.text = exchangeRate.round(2).stringValue + " USD/DCR (\(currencyConversionOption))"
        self.exchangeRateLabel.superview?.isHidden = false
        self.usdAmountTextField.superview?.isHidden = false // show usd amount field AFTER fetching exchange rate
        self.dcrAmountTextFieldChanged(sendMax: self.sendMaxAmount) // trigger dcr amount field changed to update usd amount field
    }
    
    @objc func showOverflowMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let alternateSendOption = self.destinationAccountView.isHidden ? LocalizedStrings.sendToAccount : LocalizedStrings.sendToAddress
        let alternateSendAction = UIAlertAction(title: alternateSendOption, style: .default) { _ in
            self.toggleDestinationAddressAccount()
        }
        alertController.addAction(alternateSendAction)
        
        let resetAction = UIAlertAction(title: LocalizedStrings.clearFields, style: .default) { _ in
            self.resetViews()
        }
        alertController.addAction(resetAction)
        
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // iPads show alert controller as pop ups which requires an anchor point to display.
        // Anchor the pop up to the overflow button on the nav bar.
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = self.overflowNavBarButton
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupAccountDropdowns() {
        let walletAccounts = AppDelegate.walletLoader.wallet!.walletAccounts(confirmations: self.requiredConfirmations)
            .filter({ !$0.isHidden && $0.number != INT_MAX }) // remove hidden wallets from array
        self.walletAccounts = walletAccounts
        
        // convert accounts array to string array where each account is represented in the format: Account Name [#,###.###]
        let accountDropdownItems = walletAccounts.map({ (account) -> String in
            let spendableBalance = Decimal(account.balance!.dcrSpendable) as NSDecimalNumber
            return "\(account.name) [\(spendableBalance.round(8).formattedWithSeparator)]"
        })
        self.sourceAccountDropdown.initMenu(accountDropdownItems) { selectedAccountIndex, _ in
            if self.sendMaxAmount {
                self.calculateAndDisplayMaxSendableAmount()
            }
            self.displayTransactionSummary()
        }
        self.destinationAccountDropdown.initMenu(accountDropdownItems)
        
        // select default account or first account, if there's no selection already
        var defaultAccountIndex = 0
        for (index, account) in walletAccounts.enumerated() {
            if account.isDefault {
                defaultAccountIndex = index
                break
            }
        }
        
        let currentSourceAccountIndex = self.sourceAccountDropdown.selectedItemIndex
        if currentSourceAccountIndex >= 0 && currentSourceAccountIndex < walletAccounts.count {
            self.sourceAccountDropdown.setSelectedItemIndex(currentSourceAccountIndex)
        } else {
            self.sourceAccountDropdown.setSelectedItemIndex(defaultAccountIndex)
        }
        
        let currentDestinationAccountIndex = self.destinationAccountDropdown.selectedItemIndex
        if currentDestinationAccountIndex >= 0 && currentDestinationAccountIndex < walletAccounts.count {
            self.destinationAccountDropdown.setSelectedItemIndex(currentDestinationAccountIndex)
        } else {
            self.destinationAccountDropdown.setSelectedItemIndex(defaultAccountIndex)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = LocalizedStrings.send
        self.navigationItem.rightBarButtonItems = [self.overflowNavBarButton]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "left-arrow"),
                                                                style: .done, target: self,
                                                                action: #selector(navigateToBackScreen))
        
        self.checkClipboardForValidAddress()
        self.setupAccountDropdowns()
        self.fetchExchangeRate(nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.sourceAccountDropdown.isDropDownOpen {
            self.sourceAccountDropdown.hideDropDown()
        }
        if self.destinationAccountDropdown.isDropDownOpen {
            self.destinationAccountDropdown.hideDropDown()
        }
        self.navigationItem.leftBarButtonItem = nil
    }
    
    @IBAction func pasteAddressButtonTapped(_ sender: Any) {
        self.destinationAddressTextField.text = UIPasteboard.general.string
        self.addressTextFieldChanged()
    }
    
    @IBAction func scanQrCodeTapped(_ sender: Any) {
        self.qrImageScanner.scan(sender: self, onTextScanned: self.checkAddressFromQrCode)
    }
    
    @IBAction func sendMaxTap(_ sender: Any) {
        self.calculateAndDisplayMaxSendableAmount()
    }
    
    func calculateAndDisplayMaxSendableAmount() {
        let sourceAccount = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex]
        if sourceAccount.balance?.spendable == 0 {
            // nothing to send
            self.sendAmountErrorLabel.text = self.insufficientFundsErrorMessage
            return
        }
        
        let destinationAddress = self.getDestinationAddress(isSendAttempt: false)
        let wallet = AppDelegate.walletLoader.wallet!
        
        do {
            let newTx = wallet.newUnsignedTx(sourceAccount.number, requiredConfirmations: self.requiredConfirmations)
            newTx?.addSendDestination(destinationAddress, atomAmount: 0, sendMax: true)
            let maxSendableAmount = try newTx?.estimateMaxSendAmount()
            
            let maxSendableAmountDecimal = Decimal(maxSendableAmount!.dcrValue) as NSDecimalNumber
            self.dcrAmountTextField.text = "\(maxSendableAmountDecimal.round(8))"
            self.dcrAmountTextFieldChanged(sendMax: true)
        } catch let error {
            print("get send max amount error: \(error.localizedDescription)")
            self.sendAmountErrorLabel.text = LocalizedStrings.errorGettingMaxSpendable
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        self.attemptSend()
    }
    
    func attemptSend() {
        guard AppDelegate.walletLoader.isSynced else {
            self.showSendError(LocalizedStrings.pleaseWaitNetworkSync)
            return
        }
        guard AppDelegate.walletLoader.syncer.connectedPeersCount > 0 else {
            self.showSendError(LocalizedStrings.notConnected)
            return
        }
        
        self.prepareTxSummary(isSendAttempt: true) { sendAmountDcr, destinationAddress, txFeeAndSize in
            var sendAmount = ConfirmToSendFundViewController.Amount(dcrValue: NSDecimalNumber(value: sendAmountDcr), usdValue: nil)
            var fee = ConfirmToSendFundViewController.Amount(dcrValue: NSDecimalNumber(value: txFeeAndSize.fee!.dcrValue), usdValue: nil)
            if self.exchangeRate != nil {
                sendAmount.usdValue = sendAmount.dcrValue.multiplying(by: self.exchangeRate!)
                fee.usdValue = fee.dcrValue.multiplying(by: self.exchangeRate!)
            }
            
            var destinationAccount: String?
            if !self.destinationAccountView.isHidden {
                destinationAccount = self.walletAccounts[self.destinationAccountDropdown.selectedItemIndex].name
            }
            
            let requestSendConfirmation = ConfirmToSendFundViewController.requestConfirmation
            requestSendConfirmation(sendAmount, fee, destinationAddress, destinationAccount) {
                (spendingPassword: String?) in
                // Send tx confirmation page may return a password if the spending security type is password.
                // If the password returned is nil, prompt user for spending pin, otherwise proceed to send with the provided password.
                if spendingPassword != nil {
                    self.finalizeSending(destinationAddress: destinationAddress, pinOrPassword: spendingPassword!)
                    return
                }
                
                let requestPinVC = RequestPinViewController.instantiate()
                requestPinVC.securityFor = LocalizedStrings.spending
                requestPinVC.showCancelButton = true
                requestPinVC.prompt = LocalizedStrings.confirmToSend
                requestPinVC.onUserEnteredCode = {(code:String, securityRequestVC:RequestBaseViewController?) in
                    securityRequestVC?.dismissView()
                    self.finalizeSending(destinationAddress: destinationAddress, pinOrPassword: code)
                }
                self.present(requestPinVC, animated: true, completion: nil)
            }
        }
    }
    
    func prepareTxSummary(isSendAttempt: Bool, completion: (Double, String, DcrlibwalletTxFeeAndSize) -> Void) {
        guard let dcrAmountString = self.dcrAmountTextField.text, dcrAmountString != "",
            let sendAmountDcr = Double(dcrAmountString), sendAmountDcr > 0 else {
                self.clearTxSummary()
                if isSendAttempt {
                    self.sendAmountErrorLabel.text = LocalizedStrings.amountCantBeZero
                } else {
                    // disable send button
                    self.toggleSendButtonState(addressValid: false, amountValid: false)
                }
                return
        }
        
        // Send amount must be less than or equal to max amount.
        guard sendAmountDcr <= DcrlibwalletMaxAmountDcr else {
            // clear tx summary and disable send button
            self.clearTxSummary()
            self.toggleSendButtonState(addressValid: false, amountValid: false)
            return
        }
        
        guard let destinationAddress = self.getDestinationAddress(isSendAttempt: isSendAttempt) else {
            if !isSendAttempt {
                // clear tx summary and disable send button
                self.clearTxSummary()
                self.toggleSendButtonState(addressValid: false, amountValid: false)
            }
            return
        }
        
        do {
            let sendAmountAtom = DcrlibwalletAmountAtom(sendAmountDcr)
            let sourceAccountNumber = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex].number
            
            let newTx = AppDelegate.walletLoader.wallet!.newUnsignedTx(sourceAccountNumber,
                                                                       requiredConfirmations: self.requiredConfirmations)
            newTx?.addSendDestination(destinationAddress,
                                      atomAmount: sendAmountAtom,
                                      sendMax: self.sendMaxAmount)
            
            let txFeeAndSize = try newTx?.estimateFeeAndSize()
            completion(sendAmountDcr, destinationAddress, txFeeAndSize!)
        } catch let error {
            // there's an error somewhere, clear tx summary and disable send button
            self.clearTxSummary()
            self.toggleSendButtonState(addressValid: false, amountValid: false)
            
            if error.localizedDescription == "insufficient_balance" {
                self.sendAmountErrorLabel.text = self.insufficientFundsErrorMessage
            } else {
                print("get tx fee/size error: \(error.localizedDescription)")
                if isSendAttempt {
                    self.showSendError(LocalizedStrings.unexpectedError)
                }
            }
        }
    }
    
    func finalizeSending(destinationAddress: String, pinOrPassword: String) {
        let sourceAccountNumber = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex].number

        let sendAmountDcr = Double(self.dcrAmountTextField.text!)
        let sendAmountAtom = DcrlibwalletAmountAtom(sendAmountDcr!)
        
        let progressHud = Utils.showProgressHud(withText: LocalizedStrings.sendingTransaction)
        DispatchQueue.global(qos: .userInitiated).async {[unowned self] in
            do {
                let newTx = AppDelegate.walletLoader.wallet!.newUnsignedTx(sourceAccountNumber,
                                                                           requiredConfirmations: self.requiredConfirmations)
                newTx?.addSendDestination(destinationAddress,
                                          atomAmount: sendAmountAtom,
                                          sendMax: self.sendMaxAmount)
                
                let hash = try newTx?.broadcast(pinOrPassword.utf8Bits)
                
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    self.transactionSucceeded(hash!.hexEncodedString())
                }
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    
                    if error.localizedDescription != DcrlibwalletErrInvalidPassphrase {
                        self.showOkAlert(message: error.localizedDescription, title: LocalizedStrings.error)
                        return
                    }
                    
                    let securityType = SpendingPinOrPassword.currentSecurityType()!.lowercased()
                    let errorMessage = String(format: LocalizedStrings.incorrectSecurityInfo, securityType)
                    self.showOkAlert(message: errorMessage, title: LocalizedStrings.failedTransaction, okText: LocalizedStrings.retry, onPressOk: self.attemptSend, addCancelAction: true)
                }
            }
        }
    }
    
    private func transactionSucceeded(_ txHash: String) {
        self.resetViews()
        
        SendCompletedViewController.showSendCompletedDialog(for: txHash) { showTxDetails in
            if showTxDetails {
                let txDetailsVC = Storyboards.TransactionDetails.instantiateViewController(for: TransactionDetailsViewController.self)
                txDetailsVC.transactionHash = txHash
                self.present(txDetailsVC, animated: true)
            }
        }
    }
    
    func showSendError(_ errorMessage: String) {
        self.sendErrorLabel.text = errorMessage
        self.sendErrorLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.sendErrorLabel.isHidden = true
        }
    }
    
    func toggleSendButtonState(addressValid: Bool, amountValid: Bool) {
        if addressValid && amountValid {
            self.sendButton.backgroundColor = UIColor(hex: "#007AFF") // todo declare color constants
            self.sendButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.sendButton.backgroundColor = UIColor(hex: "#E6EAED")
            self.sendButton.setTitleColor(UIColor(hex: "#000000", alpha: 0.61), for: .normal)
        }
    }
}

/**
 Destination address/account related code.
 */
extension SendViewController {
    func toggleDestinationAddressAccount() {
        if self.destinationAccountView.isHidden {
            // switch to destination account view
            self.destinationAccountView.isHidden = false
            self.addressRecipientView.isHidden = true
            self.destinationErrorLabel.text = ""
            self.toggleSendButtonState(addressValid: true, amountValid: self.isValidAmount)
        } else {
            // switch to destination address view
            self.destinationAccountView.isHidden = true
            self.addressRecipientView.isHidden = false
            // Trigger address text field change event to validate any previously entered address; and toggle send button state.
            self.addressTextFieldChanged()
        }
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
            self.invalidAddressFromQrCode(errorMessage: LocalizedStrings.walletAddressShort)
            return
        }
        if capturedText.count > 36 {
            self.invalidAddressFromQrCode(errorMessage: LocalizedStrings.walletAddressLong)
            return
        }
        
        if BuildConfig.IsTestNet {
            if capturedText.starts(with: "T") {
                self.destinationAddressTextField.text = capturedText
            } else {
                self.invalidAddressFromQrCode(errorMessage: LocalizedStrings.invalidTesnetAddress)
            }
        } else {
            if capturedText.starts(with: "D") {
                self.destinationAddressTextField.text = capturedText
            } else {
                self.invalidAddressFromQrCode(errorMessage: LocalizedStrings.invalidMainnetAddress)
            }
        }
    }
    
    func invalidAddressFromQrCode(errorMessage: String) {
        self.destinationAddressTextField.text = ""
        AppDelegate.shared.showOkAlert(message: errorMessage)
    }
    
    @objc func addressTextFieldChanged() {
        let destinationAddress = self.destinationAddressTextField.text ?? ""
        let addressValid = AppDelegate.walletLoader.wallet!.isAddressValid(destinationAddress)
        
        self.toggleSendButtonState(addressValid: addressValid, amountValid: self.isValidAmount)
        self.scanQrCodeButton.isHidden = destinationAddress != ""
        self.checkClipboardForValidAddress()
        
        if destinationAddress == "" || addressValid {
            self.destinationErrorLabel.text = ""
        } else {
            self.destinationErrorLabel.text = LocalizedStrings.invalidDestAddr
        }
    }
    
    func checkClipboardForValidAddress() {
        let canShowPasteButton = (self.destinationAddressTextField.text ?? "") == "" &&
            AppDelegate.walletLoader.wallet!.isAddressValid(UIPasteboard.general.string)
        self.pasteAddressButton.isHidden = !canShowPasteButton
    }
    
    func getDestinationAddress(isSendAttempt: Bool) -> String? {
        // Display destination address error only if this a send attempt.
        let validDestinationAddress = self.getValidDestinationAddress(displayErrorOnUI: isSendAttempt)
        
        if !isSendAttempt && validDestinationAddress == nil {
            // Generate temporary address from wallet.
            let sourceAccount = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex]
            return self.generateAddress(from: sourceAccount)
        }
        
        return validDestinationAddress
    }
    
    func getValidDestinationAddress(displayErrorOnUI: Bool) -> String? {
        if self.addressRecipientView.isHidden {
            // Sending to account, generate an address to use.
            let destinationAccount = self.walletAccounts[self.destinationAccountDropdown.selectedItemIndex]
            return self.generateAddress(from: destinationAccount)
        }
        
        // Sending to address, ensure that destinationAddressTextField.text is not nil and it's not empty string either.
        guard let destinationAddress = self.destinationAddressTextField.text, destinationAddress != "" else {
            if displayErrorOnUI {
                self.destinationErrorLabel.text = LocalizedStrings.emptyDestAddr
            }
            return nil
        }
        
        // Also ensure that destinationAddressTextField.text is a valid address.
        guard AppDelegate.walletLoader.wallet!.isAddressValid(destinationAddress) else {
            if displayErrorOnUI {
                self.destinationErrorLabel.text = LocalizedStrings.invalidDestAddr
            }
            return nil
        }
        
        return destinationAddress
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
}

/**
 Send amount (dcr/usd) related code.
 */
extension SendViewController {
    // Default value for sendMax is meant for use when this function is triggered as a result of user editing the dcr amount field.
    // If manually triggering dcr amount field change, a sendMax value is required/important
    // to ensure that a previously true value does not become false even though user did not edit the field directly.
    @objc func dcrAmountTextFieldChanged(sendMax: Bool = false) {
        defer {
            self.toggleSendButtonState(addressValid: self.isValidDestination, amountValid: self.isValidAmount)
            self.displayTransactionSummary()
        }
        
        self.sendMaxAmount = sendMax
        let dcrAmountString = self.dcrAmountTextField.text ?? ""
        
        guard let dcrAmount = Double(dcrAmountString), let exchangeRate = self.exchangeRate else {
            self.updateAmountField(self.usdAmountTextField, "", #selector(self.usdAmountTextFieldChanged))
            return
        }
        
        let usdAmount = NSDecimalNumber(value: dcrAmount).multiplying(by: exchangeRate)
        self.updateAmountField(self.usdAmountTextField, "\(usdAmount.round(8))", #selector(self.usdAmountTextFieldChanged))
    }
    
    @objc func usdAmountTextFieldChanged() {
        defer {
            self.toggleSendButtonState(addressValid: self.isValidDestination, amountValid: self.isValidAmount)
            self.displayTransactionSummary()
        }
        
        self.sendMaxAmount = false
        let usdAmountString = self.usdAmountTextField.text ?? ""
        
        guard let usdAmount = Double(usdAmountString), let exchangeRate = self.exchangeRate else {
            self.updateAmountField(self.dcrAmountTextField, "", #selector(self.dcrAmountTextFieldChanged))
            return
        }
        
        let dcrAmount = NSDecimalNumber(value: usdAmount).dividing(by: exchangeRate)
        self.updateAmountField(self.dcrAmountTextField, "\(dcrAmount.round(8))", #selector(self.dcrAmountTextFieldChanged))
    }
    
    func updateAmountField(_ textField: UITextField, _ amountString: String, _ textFieldChangeAction: Selector) {
        textField.removeTarget(self, action: nil, for: .editingChanged)
        textField.text = amountString
        textField.addTarget(self, action: textFieldChangeAction, for: .editingChanged)
    }
    
    func displayTransactionSummary() {
        self.prepareTxSummary(isSendAttempt: false) { sendAmountDcr, _, txFeeAndSize in
            let sourceAccountBalance = self.walletAccounts[self.sourceAccountDropdown.selectedItemIndex].balance!.dcrSpendable
            let balanceAfterSending = Decimal(sourceAccountBalance - sendAmountDcr - txFeeAndSize.fee!.dcrValue) as NSDecimalNumber
            
            self.displayEstimatedFee(dcrFee: txFeeAndSize.fee!.dcrValue)
            self.estimatedTxSizeLabel.text = "\(txFeeAndSize.estimatedSignedSize) bytes"
            self.balanceAfterSendingLabel.text = "\(balanceAfterSending.round(8).formattedWithSeparator) DCR"
        }
    }
    
    func displayEstimatedFee(dcrFee: Double) {
        guard let txFee = Decimal(dcrFee) as NSDecimalNumber? else {
            self.estimatedFeeLabel.text = "0.00 DCR"
        }
        
        if self.exchangeRate == nil {
            self.estimatedFeeLabel.text = "\(txFee.formattedWithSeparator) DCR"
        } else {
            let usdFee = exchangeRate!.multiplying(by: txFee).formattedWithSeparator
            self.estimatedFeeLabel.text = "\(txFee.formattedWithSeparator) DCR\n(\(usdFee) USD)"
        }
    }
    
    func clearTxSummary() {
        self.estimatedFeeLabel.text = "0.00 DCR"
        self.estimatedTxSizeLabel.text = "0 bytes"
        self.balanceAfterSendingLabel.text = "0.00 DCR"
    }
}
