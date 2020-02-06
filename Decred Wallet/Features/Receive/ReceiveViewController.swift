//  ReceiveViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

class ReceiveViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet private var imgWalletAddrQRCode: UIImageView!

    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var containerRoundedView: RoundedView!

    @IBOutlet weak var selectedAccountView: UIView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var totalAccountBalanceLabel: UILabel!

    private lazy var syncInProgressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = LocalizedStrings.secureMenuSyncInfo
        return label
    }()

    var tapGesture = UITapGestureRecognizer()
    var oldAddress = ""

    var selectedWallet: Wallet?
    var selectedAccount: DcrlibwalletAccount?

    override func loadView() {
        super.loadView()
        view.addSubview(syncInProgressLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TAP Gesture
        self.setupExtraUI()
        setupSyncInProgressLabelConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkSyncStatus()
    }

    func setupExtraUI() {
        self.imgWalletAddrQRCode.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyAddress)))
        self.walletAddressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.copyAddress)))
        self.selectedAccountView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showAccountSelectDialog)))
    }

    @objc func copyAddress() {
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = self.walletAddressLabel.text!
            Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.walletAddrCopied)
        }
    }

    private func checkSyncStatus() {
        self.menuBtn.isEnabled = false
    
        if let wallet = WalletLoader.shared.wallets.map({ Wallet.init($0) }).first,
            (!wallet.isRestored || wallet.hasDiscoveredAccounts),
            let account = wallet.accounts.first {
            self.updateSelectedAccount(wallet, account)
        } else {
            containerRoundedView.isHidden = true
            syncInProgressLabel.isHidden = false
            return
        }

        containerRoundedView.isHidden = false
        syncInProgressLabel.isHidden = true
        self.menuBtn.isEnabled = true
    }

    private func setupSyncInProgressLabelConstraints() {
        /// This will position the label at the center of the view
        syncInProgressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        syncInProgressLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        syncInProgressLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    }

    private func generateNewAddress() {
        self.oldAddress = self.walletAddressLabel.text!
        self.getNextAddress()
    }

    private func updateWalletAddressAndQRCode(receiveAddress: String) {
        DispatchQueue.main.async {
            self.walletAddressLabel.text = receiveAddress
            self.imgWalletAddrQRCode.image = self.generateQRCodeFor(
                with: receiveAddress,
                forImageViewFrame: self.imgWalletAddrQRCode.frame
            )
        }
    }

    @objc private func getNextAddress() {
        if let wallet = self.selectedWallet,
            let account = self.selectedAccount {
                let receiveAddress = wallet.nextAddress(account.number)
                if self.oldAddress != receiveAddress {
                    self.updateWalletAddressAndQRCode(receiveAddress: receiveAddress)
                } else if receiveAddress != "" {
                    self.getNextAddress()
                }
        }
    }

    private func generateQRCodeFor(with addres: String, forImageViewFrame: CGRect) -> UIImage? {
        guard let addrData = addres.data(using: String.Encoding.utf8) else {
            return nil
        }

        // Color code and background
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(addrData, forKey: "inputMessage")

        let foregroundColor = CIColor.black
        let backgroundColor = CIColor.clear

        colorFilter.setDefaults()
        colorFilter.setValue(filter!.outputImage, forKey: "inputImage")
        colorFilter.setValue(foregroundColor, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")

        if let imgQR = colorFilter.outputImage {
            var tempFrame: CGRect? = forImageViewFrame
            if tempFrame == nil {
                tempFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
            }

            guard let frame = tempFrame else { return nil }
            let smallerSide = frame.size.width < frame.size.height ? frame.size.width : frame.size.height
            let scale = smallerSide/imgQR.extent.size.width
            let transformedImage = imgQR.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            let imageQRCode = UIImage(ciImage: transformedImage)

            return imageQRCode
        }
        return nil
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismissView()
    }

    @objc func showAccountSelectDialog(_ sender: Any) {
        AccountSelectDialog.show(sender: self,
                                 title: LocalizedStrings.receivingAccount,
                                 selectedWallet: selectedWallet,
                                 selectedAccount: self.selectedAccount,
                                 callback: self.updateSelectedAccount)
    }

    @IBAction func showInfo(_ sender: Any) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: LocalizedStrings.receiveDCR,
                                                    message: LocalizedStrings.receiveInfo,
                                                    preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt,
                                                    style: UIAlertAction.Style.default,
                                                    handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func updateSelectedAccount(_ selectedWallet: Wallet, _ selectedAccount: DcrlibwalletAccount) {
        self.selectedWallet = selectedWallet
        self.selectedAccount = selectedAccount

        self.walletNameLabel.text = selectedWallet.name
        self.accountNameLabel.text = selectedAccount.name

        let totalBalanceRoundedOff = (Decimal(selectedAccount.dcrTotalBalance) as NSDecimalNumber).round(8)
        self.totalAccountBalanceLabel.attributedText = Utils.getAttributedString(str: "\(totalBalanceRoundedOff)", siz: 15.0, TexthexColor: UIColor.appColors.darkBlue)
        self.updateWalletAddressAndQRCode(receiveAddress: selectedWallet.currentAddress(selectedAccount.number))
    }

    @IBAction func showMenu(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)

        let generateNewAddressAction = UIAlertAction(title: LocalizedStrings.genNewAddr, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.generateNewAddress()
        })

        alertController.addAction(cancelAction)
        alertController.addAction(generateNewAddressAction)

        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func onShare(_ sender: Any) {
        var img: UIImage = self.imgWalletAddrQRCode.image!

        if img.cgImage == nil {
            guard let ciImage = img.ciImage, let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {return}
            img = UIImage(cgImage: cgImage)
        }

        let activityController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
}
