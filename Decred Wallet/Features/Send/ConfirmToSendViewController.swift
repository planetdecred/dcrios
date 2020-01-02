//
//  ConfirmToSendViewCotroller.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

protocol SendFundsDelegate: class {
    func successfullySentFunds()
}

class ConfirmToSendViewController: UIViewController {
    static let instance = Storyboards.Send.instantiateViewController(for: ConfirmToSendViewController.self)

    @IBOutlet var sendButton: UIButton!
    @IBOutlet var tableView: UITableView!
    lazy var backdropView: UIView = {
        return self.view
    }()
    var isPresenting = false
    lazy var tableViewHeight: CGFloat = {
        return self.tableView.frame.size.height
    }()
    var sendingDetails: SendingDetails?
    var requiredConfirmations: Int32 {
        return Settings.spendUnconfirmed ? 0 : GlobalConstants.Wallet.defaultRequiredConfirmations
    }
    lazy var errorView: ErrorBanner = {
        let view = ErrorBanner(parent: self)
        return view
    }()
    weak var sendFundsDelegate: SendFundsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCellNib(SimpleInfoTableViewCell.self)
        tableView.registerCellNib(ModalNavBarCell.self)
        tableView.registerCellNib(SendingInfoTableViewCell.self)
        tableView.registerCellNib(WarningInfoTableViewCell.self)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        backdropView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBAction func send(_ sender: UIButton) {
        let vc = ConfirmToSendPasswordEntryViewController.instance
        vc.modalPresentationStyle = .custom
        vc.passwordEntryDelegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension ConfirmToSendViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0 {
            if let unWrappedCell = tableView.dequeueReusableCell(withIdentifier: "ModalNavBarCell", for: indexPath) as? ModalNavBarCell {
                unWrappedCell.configure(with: "Confirm to send") {
                    self.dismiss(animated: true, completion: nil)
                }
                cell = unWrappedCell
            }
        } else if indexPath.row == 1 {
            if let sendingInfoCell = tableView.dequeueReusableCell(withIdentifier: "SendingInfoTableViewCell", for: indexPath) as? SendingInfoTableViewCell,
                let details = sendingDetails {
                sendingInfoCell.configureWith(details)
                cell = sendingInfoCell
            }
        } else if indexPath.row == 2 {
            let simpleInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SimpleInfoTableViewCell", for: indexPath) as? SimpleInfoTableViewCell
            simpleInfoTableViewCell?.configureWith(title: "Transaction fee", and: sendingDetails?.transactionFee)
            cell = simpleInfoTableViewCell
        } else if indexPath.row == 3 {
            let simpleInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SimpleInfoTableViewCell", for: indexPath) as? SimpleInfoTableViewCell
            simpleInfoTableViewCell?.configureWith(title: "Total cost", and: sendingDetails?.totalCost)
            cell = simpleInfoTableViewCell
        }
        else if indexPath.row == 4 {
            let simpleInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SimpleInfoTableViewCell", for: indexPath) as? SimpleInfoTableViewCell
            simpleInfoTableViewCell?.configureWith(title: "Balance after send", and: sendingDetails?.balanceAfterSend)
            cell = simpleInfoTableViewCell
        } else if indexPath.row == 5 {
            cell = tableView.dequeueReusableCell(withIdentifier: "WarningInfoTableViewCell", for: indexPath) as? WarningInfoTableViewCell
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 180 : 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
}

extension ConfirmToSendViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            tableView.frame.origin.y += tableViewHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.tableView.frame.origin.y -= self.tableViewHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.tableView.frame.origin.y += self.tableViewHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}

extension ConfirmToSendViewController: ConfirmToSendPasswordEntryDelegate {
    func didEnterPassword(_ password: String) {
        toggleSendButtonState(isSending: true, hasFinishedSending: false)
        do {
            guard let sourceAccount = sendingDetails?.sourceWallet,
                let details = sendingDetails else {return}
            let sendAmountAtom = DcrlibwalletAmountAtom(details.amount)
            let sourceAccountNumber = sourceAccount.Number
            let destinationAddress = details.destinationWallet == nil ? details.destinationAddress : self.generateAddress(from: details.destinationWallet!)
            
            let newTx = AppDelegate.walletLoader.wallet!.newUnsignedTx(sourceAccountNumber,
                                                                       requiredConfirmations: self.requiredConfirmations)
            newTx?.addSendDestination(destinationAddress,
                                      atomAmount: sendAmountAtom,
                                      sendMax: details.sendMax)
            
            let _ = try newTx?.broadcast(password.utf8Bits)
            DispatchQueue.main.async {
                self.sendFundsDelegate?.successfullySentFunds()
                self.dismiss(animated: true, completion: nil)
            }
        } catch let error {
            toggleSendButtonState(isSending: false, hasFinishedSending: false)
            if error.localizedDescription == DcrlibwalletErrInvalidPassphrase {
                errorView.show(text: "Invalid password!")
                return
            }
            errorView.show(text: "Failed to send. Please try again.")
        }
    }
    
    func generateAddress(from account: WalletAccount) -> String? {
        var generateAddressError: NSError?
        let destinationAddress = AppDelegate.walletLoader.wallet!.currentAddress(account.Number, error: &generateAddressError)
        if generateAddressError != nil {
            print("send page -> generate address for destination account error: \(generateAddressError!.localizedDescription)")
            return nil
        }
        return destinationAddress
    }
    
    private func toggleSendButtonState(isSending: Bool, hasFinishedSending: Bool) {
        if isSending {
            sendButton.setImage(UIImage(named: "ic-loader"), for: .normal)
            sendButton.setTitleColor(UIColor.appColors.darkGray, for: .normal)
            sendButton.tintColor = UIColor.appColors.darkGray
            sendButton.setBackgroundColor(UIColor.white, for: .normal)
            sendButton.setTitle("Processing...", for: .normal)
        } else if hasFinishedSending {
            sendButton.setImage(UIImage(named: "ic-checkmark-confirmed"), for: .normal)
            sendButton.setTitleColor(UIColor.appColors.green, for: .normal)
            sendButton.setBackgroundColor(UIColor.white, for: .normal)
            sendButton.setTitle("Success", for: .normal)
        } else {
            sendButton.setImage(nil, for: .normal)
            sendButton.setTitleColor(UIColor.white, for: .normal)
            sendButton.setBackgroundColor(UIColor.blue, for: .normal)
            guard let details = sendingDetails else {return}
            sendButton.setTitle("Send \(details.amount) DCR", for: .normal)
        }
    }
}
