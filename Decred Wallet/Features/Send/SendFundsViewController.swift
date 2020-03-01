//
//  SendFundsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SendFundsViewController: UIViewController {
    static let instance = SendFundsViewController.instantiate(from: .Send).wrapInNavigationcontroller()
    
    @IBOutlet weak var sourceAccountView: WalletAccountView!
    
    @IBOutlet weak var toAddressSection: UIView!
    @IBOutlet weak var destinationAddressTextField: FloatingPlaceholderTextView!
    lazy var scanQRCodeForAddressButton: UIButton = {
        let scanQRCodeForAddressButton = UIButton(frame: .zero)
        scanQRCodeForAddressButton.setImage(UIImage(named: "ic_scan"), for: .normal)
        scanQRCodeForAddressButton.addTarget(self, action: #selector(self.scanQrCodeTapped), for: .touchUpInside)
        return scanQRCodeForAddressButton
    }()
    lazy var pasteAddressFromClipboardButton: UIButton = {
        let pasteAddressFromClipboardButton = UIButton(frame: .zero)
        pasteAddressFromClipboardButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        pasteAddressFromClipboardButton.layer.cornerRadius = 4
        pasteAddressFromClipboardButton.set(fontSize: 14, name: "SourceSansPro-Regular")
        pasteAddressFromClipboardButton.setTitle("Paste", for: .normal)
        pasteAddressFromClipboardButton.setTitleColor(UIColor.appColors.lightBlue, for: .normal)
        pasteAddressFromClipboardButton.backgroundColor = UIColor.appColors.lightGray
        pasteAddressFromClipboardButton.addTarget(self, action: #selector(self.pasteAddressTapped), for: .touchUpInside)
        return pasteAddressFromClipboardButton
    }()
    @IBOutlet weak var invalidDestinationAddressLabel: Label!
    
    @IBOutlet weak var toSelfAccountSection: UIView!
    @IBOutlet weak var destinationAccountView: WalletAccountView!
    
    @IBOutlet var sourceAccountSpendableBalanceLabel: UILabel!
    @IBOutlet var amountContainerView: UIView!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var usdAmountSeparatorView: UIView!
    @IBOutlet var usdAmountSection: UIView!
    @IBOutlet var usdAmountLabel: UILabel!
    @IBOutlet var retryFetchExchangeRateButton: UIButton!
    @IBOutlet var notEnoughFundsLabel: UILabel!
    
    @IBOutlet var transactionFeeSection: UIView!
    @IBOutlet var transactionFeeLabel: UILabel!
    @IBOutlet var transactionFeeDetailsToggleImageView: UIImageView!
    
    @IBOutlet var transactionFeeDetailsSection: UIView!
    @IBOutlet var processingTimeLabel: UILabel!
    @IBOutlet var feeRateLabel: UILabel!
    @IBOutlet var transactionSizeLabel: UILabel!
    
    @IBOutlet var sendingSummarySection: UIView!
    @IBOutlet var totalCostLabel: UILabel!
    @IBOutlet var balanceAfterSendingLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
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

    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeKeyboardShowHide(delegate: self)
        self.setupViews()
        self.resetFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        let currencyConversionDisabled = Settings.currencyConversionOption == .None
        self.usdAmountSeparatorView.isHidden = currencyConversionDisabled
        self.usdAmountSection.isHidden = currencyConversionDisabled
        
        self.fetchExchangeRate()
        self.showOrHidePasteAddressButton()
    }
    
    func setupViews() {
        self.sourceAccountView.onAccountSelectionChanged = { _, newSourceAccount in
            let spendableAmount = (Decimal(newSourceAccount.balance!.dcrSpendable) as NSDecimalNumber).round(8).formattedWithSeparator
            self.sourceAccountSpendableBalanceLabel.text = "Spendable: \(spendableAmount) DCR" // todo localize spendable
        }
        
        self.destinationAddressTextField.add(button: self.scanQRCodeForAddressButton)
        self.destinationAddressTextField.add(button: self.pasteAddressFromClipboardButton)
        self.destinationAddressTextField.textViewDelegate = self
        
        self.toSelfAccountSection.isHidden = true
        
        self.amountTextField.addDoneButton() // todo review this!
        
        self.transactionFeeSection.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.toggleTransactionFeeDetailsVisibility))
        )
        self.transactionFeeDetailsSection.isHidden = true
    }

    @objc func toggleTransactionFeeDetailsVisibility() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.transactionFeeDetailsSection.isHidden.toggle()
            
            let rotationAngle = self.transactionFeeDetailsSection.isHidden ? 0.0 : CGFloat(Double.pi)
            self.transactionFeeDetailsToggleImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        })
    }
    
    @objc func resetFields() {
        self.sourceAccountView.selectFirstWalletAccount()
        
        // Clearing the destination address textfield will trigger the set textview delegate
        // which will hide the error label and show the paste button if a valid address is in clipboard.
        self.destinationAddressTextField.setText("")
        
        self.destinationAccountView.selectFirstWalletAccount()
        
        // Clearing the primary amount textfield should set the usd amount to 0,
        // hide the address error label, update the transaction fee details and sending summary fields.
        self.amountTextField.text = ""
        self.usdAmountLabel.text = "0 USD"
        self.notEnoughFundsLabel.text = " "
        self.transactionFeeLabel.text = "- DCR"
        self.processingTimeLabel.text = "-"
        self.feeRateLabel.text = "-"
        self.transactionSizeLabel.text = "-"
        self.totalCostLabel.text = "- DCR"
        let spendableAmount = (Decimal(self.sourceAccountView.selectedAccount?.balance!.dcrSpendable ?? 0) as NSDecimalNumber).round(8).formattedWithSeparator
        self.balanceAfterSendingLabel.text = "\(spendableAmount) DCR"
    }
    
    private func fetchExchangeRate() {
        self.retryFetchExchangeRateButton.isHidden = true
        if self.exchangeRate == nil {
            self.usdAmountLabel.text = "- USD"
        }
        
        switch Settings.currencyConversionOption {
        case .None:
            self.exchangeRate = nil
            break
            
        case .Bittrex:
            ExchangeRates.Bittrex.fetch(callback: self.displayExchangeRate)
        }
    }
    
    func displayExchangeRate(_ newExchangeRate: NSDecimalNumber?) {
        guard let exchangeRate = newExchangeRate else {
            // only show error if an exchange rate has never been fetched previously
            if self.exchangeRate == nil {
                self.retryFetchExchangeRateButton.isHidden = true
                self.usdAmountLabel.text = "Exchange rate not fetched"
                self.usdAmountLabel.textColor = UIColor.appColors.orange
            }
            return
        }
        
        self.exchangeRate = exchangeRate
        
        self.retryFetchExchangeRateButton.isHidden = true
        if let dcrAmount = Double(self.amountTextField.text ?? "") {
            let usdAmount = NSDecimalNumber(value: dcrAmount).multiplying(by: exchangeRate)
            self.usdAmountLabel.text = "\(usdAmount.round(8)) USD"
        } else {
            self.usdAmountLabel.text = "- USD"
        }
        self.usdAmountLabel.textColor = UIColor.appColors.darkGray
    }
    
    func showOrHidePasteAddressButton() {
        let shouldShowPasteButton = self.destinationAddressTextField.isInputEmpty()
            && self.sourceAccountView.selectedWallet?.isAddressValid(UIPasteboard.general.string) ?? false

        if self.pasteAddressFromClipboardButton.isHidden == shouldShowPasteButton {
            // if ishidden = true and shouldShow = true, then toggle visibility
            // if ishidden = false and shouldShow = false, then toggle visibility
            self.destinationAddressTextField.toggleButtonVisibility(self.pasteAddressFromClipboardButton)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func infoMenuButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Send DCR", message: "Input or scan the destination wallet address and the amount in DCR to send funds", preferredStyle: .alert)
        let gotItAction = UIAlertAction(title: "Got it", style: .cancel, handler: nil)
        alertController.addAction(gotItAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func overflowMenuButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)
        let clearFieldsAction = UIAlertAction(title: "Clear all fields", style: .default) { action in
            self.resetFields()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(clearFieldsAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendToSelfTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.toAddressSection.isHidden = true
            self.toSelfAccountSection.isHidden = false
        })
    }

    @IBAction func sendToOthersTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.toSelfAccountSection.isHidden = true
            self.toAddressSection.isHidden = false
        })
    }
    
    @objc func scanQrCodeTapped(_ sender: UIButton) {
        self.qrImageScanner.scan(sender: self, onTextScanned: self.checkAddressFromQrCode)
    }
    
    @objc func pasteAddressTapped(_ sender: UIButton) {
        guard let textFromClipboard = UIPasteboard.general.string else { return }
        self.destinationAddressTextField.setText(textFromClipboard)
        destinationAddress = textFromClipboard
    }
    
    @IBAction func proceedToConfirmSend(_ sender: Any) {
        self.prepareTxSummary(isSendAttempt: false) { sendAmountDcr, _, txFeeAndSize in
            guard let sourceAccountBalance = self.sourceAccountView.selectedAccount?.balance?.dcrSpendable else { return }
            
            let textFeeSize = txFeeAndSize.fee?.dcrValue ?? 0.0
            let balanceAfterSending = Decimal(sourceAccountBalance - sendAmountDcr - textFeeSize) as NSDecimalNumber
            let balanceAfterSendingText = "\(balanceAfterSending.round(8).formattedWithSeparator) DCR"
            let totalCost = Decimal(sendAmountDcr + textFeeSize) as NSDecimalNumber
            let totalCostText = "\(totalCost) DCR"
            let transactionFeeText = estimatedFee(for: txFeeAndSize.fee?.dcrValue ?? 0.0)
            
            let details = SendingDetails(amount: sendAmountDcr,
                                              destinationAddress: self.destinationAddress,
                                              destinationWallet: self.destinationAccountView.selectedAccount,
                                              sourceWallet: self.sourceAccountView.selectedAccount,
                                              transactionFee: transactionFeeText,
                                              balanceAfterSend: balanceAfterSendingText,
                                              totalCost: totalCostText,
                                              sendMax: self.sendMax)

            let vc = ConfirmToSendViewController.instance
            vc.sendingDetails = details
            vc.modalPresentationStyle = .custom
            present(vc, animated: true, completion: nil)
        }
    }
    
    func clearTxSummary() {
        feeRateLabel.text = "0.00 DCR"
        transactionSizeLabel.text = "0 bytes"
        processingTimeLabel.text = "≈ -- blocks"
    }
    
    func getDestinationAddress(isSendAttempt: Bool) -> String? {
        // Display destination address error only if this a send attempt.
        let validDestinationAddress = self.getValidDestinationAddress(displayErrorOnUI: isSendAttempt)
        
        if !isSendAttempt && validDestinationAddress == nil, let account = self.sourceAccountView.selectedAccount {
            // Generate temporary address from wallet.
            return self.generateAddress(from: account)
        }
        
        return validDestinationAddress
    }
    
    func generateAddress(from account: DcrlibwalletAccount) -> String? {
        var generateAddressError: NSError?
        let destinationAddress = WalletLoader.shared.firstWallet!.currentAddress(account.number, error: &generateAddressError)
        if generateAddressError != nil {
            print("send page -> generate address for destination account error: \(generateAddressError!.localizedDescription)")
            return nil
        }
        return destinationAddress
    }
    
    func getValidDestinationAddress(displayErrorOnUI: Bool) -> String? {
        if !toSelfAccountSection.isHidden {
            // Sending to account, generate an address to use.
            guard let destinationAccount = self.destinationAccountView.selectedAccount else { return nil }
            return self.generateAddress(from: destinationAccount)
        }
        
        // Sending to address, ensure that destinationAddressTextField.text is not nil and it's not empty string either.
        guard let destinationAddress = self.destinationAddressTextField.text, !destinationAddress.isEmpty else {
            if displayErrorOnUI {
                self.destinationAddressTextField.showError()
                self.invalidDestinationAddressLabel.text = LocalizedStrings.emptyDestAddr
            }
            return nil
        }
        
        // Also ensure that destinationAddressTextField.text is a valid address.
        guard WalletLoader.shared.firstWallet!.isAddressValid(destinationAddress) else {
            if displayErrorOnUI {
                self.invalidDestinationAddressLabel.text = LocalizedStrings.invalidDestAddr
            }
            return nil
        }
        
        return destinationAddress
    }
    
    func displayTransactionSummary() {
        self.prepareTxSummary(isSendAttempt: false) { sendAmountDcr, _, txFeeAndSize in
            guard let sourceAccountBalance = self.sourceAccountView.selectedAccount?.balance!.dcrSpendable else {return}
            let balanceAfterSending = Decimal(sourceAccountBalance - sendAmountDcr - txFeeAndSize.fee!.dcrValue) as NSDecimalNumber
            let totalCost = Decimal(sendAmountDcr + txFeeAndSize.fee!.dcrValue) as NSDecimalNumber
            
            self.displayEstimatedFee(dcrFee: txFeeAndSize.fee!.dcrValue)
            self.transactionSizeLabel.text = "\(txFeeAndSize.estimatedSignedSize) bytes"
            self.balanceAfterSendingLabel.text = "\(balanceAfterSending.round(8).formattedWithSeparator) DCR"
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
        guard let dcrAmountString = self.amountTextField.text, !dcrAmountString.isEmpty,
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
            guard let sourceAccount = self.sourceAccountView.selectedAccount else {return}
            let sendAmountAtom = DcrlibwalletAmountAtom(sendAmountDcr)
            let sourceAccountNumber = sourceAccount.number
            
            let newTx = WalletLoader.shared.firstWallet!.newUnsignedTx(sourceAccountNumber,
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

    @objc func dcrAmountTextFieldChanged(sendMax: Bool = false) {
        defer {
            self.toggleSendButtonState(shouldEnableSendButton)
            self.displayTransactionSummary()
        }

        self.sendMax = sendMax
        let dcrAmountString = self.amountTextField.text ?? ""

        guard let dcrAmount = Double(dcrAmountString), let exchangeRate = self.exchangeRate else {
            self.usdAmountLabel.text = "- USD"
            return
        }

        let usdAmount = NSDecimalNumber(value: dcrAmount).multiplying(by: exchangeRate)
        self.usdAmountLabel.text = "\(usdAmount.round(8)) USD"
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
        guard let sourceAccount = self.sourceAccountView.selectedAccount else {return}
        sendMax = true
        if sourceAccount.balance?.spendable == 0 {
            // nothing to send
            self.notEnoughFundsLabel.text = self.insufficientFundsErrorMessage
            return
        }
        
        let destinationAddress = self.getDestinationAddress(isSendAttempt: false)
        let wallet = WalletLoader.shared.firstWallet!
        
        do {
            let newTx = wallet.newUnsignedTx(sourceAccount.number, requiredConfirmations: self.requiredConfirmations)
            newTx?.addSendDestination(destinationAddress, atomAmount: 0, sendMax: sendMax)
            let maxSendableAmount = try newTx?.estimateMaxSendAmount()
            
            let maxSendableAmountDecimal = Decimal(maxSendableAmount!.dcrValue) as NSDecimalNumber
            self.amountTextField.text = "\(maxSendableAmountDecimal.round(8))"
            self.dcrAmountTextFieldChanged(sendMax: true)
        } catch let error {
            print("get send max amount error: \(error.localizedDescription)")
            self.notEnoughFundsLabel.text = LocalizedStrings.errorGettingMaxSpendable
        }
    }

    @IBAction func sendMaxTap(_ sender: UIButton) {
        self.calculateAndDisplayMaxSendableAmount()
    }

    @IBAction func retryExchangeRateFetch(_ sender: UIButton) {
        self.fetchExchangeRate()
    }
}

// delegate for destination address text view.
extension SendFundsViewController: FloatingPlaceholderTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.showOrHidePasteAddressButton()
        
        let destinationAddress = self.destinationAddressTextField.text ?? ""
        let addressValid = self.sourceAccountView.selectedWallet?.isAddressValid(destinationAddress) ?? false
        self.invalidDestinationAddressLabel.isHidden = destinationAddress.isEmpty || addressValid
    }
}

// comment
extension SendFundsViewController {
    var requiredConfirmations: Int32 {
        return Settings.spendUnconfirmed ? 0 : GlobalConstants.Wallet.defaultRequiredConfirmations
    }

    var insufficientFundsErrorMessage: String {
        if WalletLoader.shared.multiWallet.connectedPeers() > 0 {
            return LocalizedStrings.notEnoughFunds
        } else {
            return LocalizedStrings.notEnoughFundsOrNotConnected
        }
    }
    
    var shouldEnableSendButton: Bool {
        if !toSelfAccountSection.isHidden {
            guard destinationAccountView.selectedAccount != nil else { return false }
        } else {
            guard let address = destinationAddress, !address.isEmpty else { return false }
        }
        return isValidAmount
    }
    
    var isValidAmount: Bool {
        self.notEnoughFundsLabel.text = ""
        guard let dcrAmountString = self.amountTextField.text, dcrAmountString != "" else { return false }
        
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
        
        guard let sourceAccount = self.sourceAccountView.selectedAccount else { return false }
        
        if sendAmountDcr > sourceAccount.balance!.dcrSpendable {
            self.notEnoughFundsLabel.text = self.insufficientFundsErrorMessage
            return false
        }
        
        return true
    }
}

// needs a comment
extension SendFundsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let floatingPlaceholderTextfield = textField as? FloatingPlaceholderTextField {
            floatingPlaceholderTextfield.hideError() // todo also hide error label
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.calculateAndDisplayMaxSendableAmount()
        // Address field
        if textField.tag == 0 {
            self.toggleSendButtonState(self.shouldEnableSendButton)
        } else if textField.tag == 1 {
            if self.exchangeRate != nil {
                displayExchangeRate(self.exchangeRate)
            }
            dcrAmountTextFieldChanged()
            toggleSendButtonState(self.shouldEnableSendButton)
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

extension SendFundsViewController: KeyboardVisibilityDelegate {
    @objc func onKeyboardWillShowOrHide(_ notification: Notification) {
        guard let window = self.view.window?.frame,
            let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        
        let keyboardHeight = window.size.height - keyboardFrame.origin.y
        let sendingSummarySectionHeight = self.sendingSummarySection.frame.size.height
        let scrollViewBottomConstraintValue = max(keyboardHeight - sendingSummarySectionHeight, 8)
        
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else {
                self.scrollViewBottomConstraint.constant = scrollViewBottomConstraintValue
                return
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.scrollViewBottomConstraint.constant = scrollViewBottomConstraintValue
        })
    }
}
