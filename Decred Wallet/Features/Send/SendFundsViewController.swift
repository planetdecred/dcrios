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
    
    @IBOutlet weak var sourceAccountSection: UIView!
    @IBOutlet weak var sourceWalletNameLabel: UILabel!
    @IBOutlet weak var sourceAccountNameLabel: UILabel!
    @IBOutlet weak var sourceAccountBalanceLabel: UILabel!
    
    var sourceWallet: DcrlibwalletWallet? {
        didSet {
            self.sourceWalletNameLabel.text = self.sourceWallet?.name ?? ""
        }
    }
    
    var sourceAccount: DcrlibwalletAccount? {
        didSet {
            self.sourceAccountNameLabel.text = self.sourceAccount?.name ?? ""
            self.sourceAccountBalanceLabel.attributedText = Utils.amountAsAttributedString(amount: self.sourceAccount?.dcrTotalBalance ?? 0, smallerTextSize: 15.0)
            
            let spendableAmount = (Decimal(self.sourceAccount?.balance?.dcrSpendable ?? 0) as NSDecimalNumber).round(8).formattedWithSeparator
            self.spendableAmountLabel.text = "Spendable: \(spendableAmount) DCR" // todo localize spendable
        }
    }
    
    @IBOutlet weak var toAddressSection: UIView!
    @IBOutlet weak var destinationAddressTextField: FloatingPlaceholderTextField!
    @IBOutlet weak var invalidDestinationAddressLabel: Label!
    
    @IBOutlet weak var toSelfAccountSection: UIView!
    @IBOutlet weak var destinationWalletNameLabel: UILabel!
    @IBOutlet weak var destinationAccountNameLabel: UILabel!
    @IBOutlet weak var destinationAccountBalanceLabel: UILabel!
    
    var destinationWallet: DcrlibwalletWallet? {
        didSet {
            self.destinationWalletNameLabel.text = self.destinationWallet?.name ?? ""
        }
    }
    
    var destinationAccount: DcrlibwalletAccount? {
        didSet {
            self.destinationAccountNameLabel.text = self.destinationAccount?.name ?? ""
            self.destinationAccountBalanceLabel.attributedText = Utils.amountAsAttributedString(amount: self.destinationAccount!.dcrTotalBalance, smallerTextSize: 15.0)
        }
    }
    
    @IBOutlet var amountLayer: UIView!
    @IBOutlet var notEnoughFundsLabel: UILabel!
    @IBOutlet var amountContainerView: UIView!
    @IBOutlet var transactionFeeDetails: UIStackView!
    @IBOutlet var amountContainerViewHeight: NSLayoutConstraint!
    @IBOutlet var spendableAmountLabel: UILabel!
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
        if WalletLoader.shared.multiWallet.connectedPeers() > 0 {
            return LocalizedStrings.notEnoughFunds
        } else {
            return LocalizedStrings.notEnoughFundsOrNotConnected
        }
    }
    
    var shouldEnableSendButton: Bool {
        if !toSelfAccountSection.isHidden {
            guard destinationWallet != nil else { return false }
        } else {
            guard let address = destinationAddress, !address.isEmpty else { return false }
        }
        return isValidAmount
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
        
        guard let sourceAccount = self.sourceAccount else { return false }
        
        if sendAmountDcr > sourceAccount.balance!.dcrSpendable {
            self.notEnoughFundsLabel.text = self.insufficientFundsErrorMessage
            return false
        }
        
        return true
    }
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.registerObserverForKeyboardNotification()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerObserverForKeyboardNotification()
    }
    
    deinit {
        self.unregisterObserverForKeyboardNotification()
    }
    
    func registerObserverForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func unregisterObserverForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object:nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object:nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefaultWalletAndAccountForSourceAndDestination()
        
        self.sourceAccountSection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showSourceAccountSelectorDialog(_:))))
        self.toSelfAccountSection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showDestinationAccountSelectorDialog(_:))))
        
        self.toSelfAccountSection.isHidden = true
        self.invalidDestinationAddressLabel.isHidden = true
        
        amountContainerView.layer.borderColor = UIColor.appColors.darkGray.cgColor
        showHideTransactionFeeDetails(showHideTransactionFeeDetailsButton)

        self.setUpBarButtonItems()
        self.sendingAmountTextField.addDoneButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchExchangeRate(nil)
    }
    
    func setDefaultWalletAndAccountForSourceAndDestination() {
        // set first wallet as source and destination wallet
        // and first non-imported account as source and destination account
        self.sourceWallet = WalletLoader.shared.wallets.first
        self.sourceAccount = self.sourceWallet?.accounts(confirmations: 0)
            .filter({ $0.totalBalance > 0 || $0.name != "imported" })
            .first
        
        self.destinationWallet = self.sourceWallet
        self.destinationAccount = self.sourceAccount
    }
    
    @objc func showSourceAccountSelectorDialog(_ sender: Any) {
        AccountSelectorDialog
            .show(sender: self,
                  title: "Sending account", // todo localize
                  selectedWallet: self.sourceWallet,
                  selectedAccount: self.sourceAccount) { selectedWalletID, selectedAccount in
                    
                    guard let selectedWallet = WalletLoader.shared.multiWallet.wallet(withID: selectedWalletID) else { return }
                    self.sourceWallet = selectedWallet
                    self.sourceAccount = selectedAccount
        }
    }
    
    @objc func showDestinationAccountSelectorDialog(_ sender: Any) {
        AccountSelectorDialog
            .show(sender: self,
                  title: LocalizedStrings.receivingAccount,
                  selectedWallet: self.destinationWallet,
                  selectedAccount: self.destinationAccount) { selectedWalletID, selectedAccount in
                    
                    guard let selectedWallet = WalletLoader.shared.multiWallet.wallet(withID: selectedWalletID) else { return }
                    self.destinationWallet = selectedWallet
                    self.destinationAccount = selectedAccount
        }
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
        let titleBarButtonItem = UIBarButtonItem(title: "Send DCR", style: .plain, target: self, action: nil)
        
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationItem.rightBarButtonItems = [overflowNavBarButton, infoNavBarButton]
        navigationItem.leftBarButtonItems = [cancelBarButtonItem, titleBarButtonItem]
    }
    
    @IBAction func proceedToConfirmSend(_ sender: Any) {
        self.prepareTxSummary(isSendAttempt: false) { sendAmountDcr, _, txFeeAndSize in
            guard let sourceAccountBalance = self.sourceAccount?.balance?.dcrSpendable else { return }
            
            let textFeeSize = txFeeAndSize.fee?.dcrValue ?? 0.0
            let balanceAfterSending = Decimal(sourceAccountBalance - sendAmountDcr - textFeeSize) as NSDecimalNumber
            let balanceAfterSendingText = "\(balanceAfterSending.round(8).formattedWithSeparator) DCR"
            let totalCost = Decimal(sendAmountDcr + textFeeSize) as NSDecimalNumber
            let totalCostText = "\(totalCost) DCR"
            let transactionFeeText = estimatedFee(for: txFeeAndSize.fee?.dcrValue ?? 0.0)
            
            let details = SendingDetails(amount: sendAmountDcr,
                                              destinationAddress: self.destinationAddress,
                                              destinationWallet: self.destinationAccount,
                                              sourceWallet: self.sourceAccount,
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
            // we only update the first time we did a fetch for the exchange rate
            if rateConversionContainerViewHeightConstraint.constant == CGFloat(integerLiteral: 100) {
                rateConversionContainerViewHeightConstraint.constant = (rateConversionContainerViewHeightConstraint.constant - (exchangeRateIconHeight * 2))
                amountContainerViewHeight.constant = (amountContainerViewHeight.constant - (exchangeRateIconHeight * 2))
            }
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
        
        if !isSendAttempt && validDestinationAddress == nil, let account = sourceAccount {
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
            guard let destinationAccount = self.destinationAccount else { return nil }
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
            guard let sourceAccountBalance = self.sourceAccount?.balance!.dcrSpendable else {return}
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
            guard let sourceAccount = sourceAccount else {return}
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
        let dcrAmountString = self.sendingAmountTextField.text ?? ""

        guard let dcrAmount = Double(dcrAmountString), let exchangeRate = self.exchangeRate else {
            self.exchangeRateLabel.text = ""
            return
        }

        let usdAmount = NSDecimalNumber(value: dcrAmount).multiplying(by: exchangeRate)
        self.exchangeRateLabel.text = "\(usdAmount.round(8)) USD"
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
        guard let sourceAccount = sourceAccount else {return}
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
        self.setDefaultWalletAndAccountForSourceAndDestination()
        self.destinationAddressTextField.text = ""
        self.invalidDestinationAddressLabel.isHidden = true
        self.exchangeRateLabel.text = "0 USD"
        self.exchangeRateLabel.textColor = UIColor.appColors.thinGray
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

    @IBAction func retryExchangeRateFetch(_ sender: UIButton) {
        fetchExchangeRate(sender)
    }

    @IBAction func scan(_ sender: UIButton) {
        self.qrImageScanner.scan(sender: self, onTextScanned: self.checkAddressFromQrCode)
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
