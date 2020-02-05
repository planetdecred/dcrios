//  ReceiveViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

class ReceiveViewController: UIViewController,UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet private var accountDropdown: DropMenuButton!
    @IBOutlet private var imgWalletAddrQRCode: UIImageView!

    @IBOutlet weak var lblWalletAddress: UILabel!
    @IBOutlet var contentStackView: UIStackView!

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

    var firstTrial = true
    var starttime: Int64 = 0
    var tapGesture = UITapGestureRecognizer()
    var oldAddress = ""
    var wallet = WalletLoader.shared.firstWallet
    var selectedWallet: Wallet?
    var selectedAccount: DcrlibwalletAccount?

//    private var selectedAccount = ""

    override func loadView() {
        super.loadView()
        view.addSubview(syncInProgressLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TAP Gesture
        self.setupExtraUI()
        self.starttime = Int64(NSDate().timeIntervalSince1970)
        setupSyncInProgressLabelConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkSyncStatus()
    }

    func setupExtraUI() {
        self.imgWalletAddrQRCode.addGestureRecognizer(tapToCopyAddressGesture())
        self.lblWalletAddress.addGestureRecognizer(tapToCopyAddressGesture())
        self.selectedAccountView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.showAccountSelectDialog))
        )
    }
    
    func tapToCopyAddressGesture() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(self.copyAddress))
    }
    
    @objc func copyAddress() {
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = self.lblWalletAddress.text!
            
            //Alert
            let alertController = UIAlertController(title: "", message: LocalizedStrings.walletAddrCopied, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: LocalizedStrings.ok, style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func checkSyncStatus() {
        self.menuBtn.isEnabled = false
    
        if let wallet = WalletLoader.shared.wallets.map({ Wallet.init($0) }).first,
            let account = wallet.accounts.first {
            self.updateSelectedAccount(wallet, account)
        } else {
            contentStackView.isHidden = true
            syncInProgressLabel.isHidden = false
            return
        }

        self.updateWalletAddressAndQRCode()
        contentStackView.isHidden = false
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
        self.oldAddress = self.lblWalletAddress.text!
        self.getNextAddress(accountNumber: (self.selectedAccount?.number)!)
    }
    
    private func updateWalletAddressAndQRCode() {
        if let account = self.selectedAccount {
            self.getAddress(accountNumber: account.number)
        } else {
            print("no account")
        }
    }
    
    @objc func getNext(){
        self.getNextAddress(accountNumber: (self.selectedAccount?.number)!)
    }
    
    private func getAddress(accountNumber : Int32) {
        let receiveAddress = self.wallet?.currentAddress(Int32(accountNumber), error: nil)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            this.lblWalletAddress.text = receiveAddress!
            this.imgWalletAddrQRCode.image = this.generateQRCodeFor(
                with: receiveAddress!,
                forImageViewFrame: this.imgWalletAddrQRCode.frame
            )
        }
    }
    
    @objc private func getNextAddress(accountNumber : Int32){
        let receiveAddress = self.wallet?.nextAddress(Int32(accountNumber), error: nil)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            if (this.oldAddress != receiveAddress!) {
                this.lblWalletAddress.text = receiveAddress!
                this.imgWalletAddrQRCode.image = this.generateQRCodeFor(
                    with: receiveAddress!,
                    forImageViewFrame: this.imgWalletAddrQRCode.frame
                )
                return
            }
            else{
                self!.getNext()
            }
        }
    }
    
    func generateQRCodeFor(with addres: String, forImageViewFrame: CGRect) -> UIImage? {
        guard let addrData = addres.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        // Color code and background
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(addrData, forKey: "inputMessage")
        
        /// Foreground color of the output
        let color = CIColor(red: 26/255, green: 29/255, blue: 47/255)
        
        /// Background color of the output
        let backgroundColor = CIColor.clear
        
        colorFilter.setDefaults()
        colorFilter.setValue(filter!.outputImage, forKey: "inputImage")
        colorFilter.setValue(color, forKey: "inputColor0")
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
        //TODO
    }

    func updateSelectedAccount(_ selectedWallet: Wallet, _ selectedAccount: DcrlibwalletAccount) {
        self.selectedWallet = selectedWallet
        self.selectedAccount = selectedAccount
        
        self.walletNameLabel.text = self.selectedWallet?.name
        self.accountNameLabel.text = self.selectedAccount?.name

        let totalBalance = self.selectedAccount?.dcrTotalBalance ?? 0
        let totalBalanceRoundedOff = (Decimal(totalBalance) as NSDecimalNumber).round(8)
        self.totalAccountBalanceLabel.attributedText = Utils.getAttributedString(str: "\(totalBalanceRoundedOff)", siz: 15.0, TexthexColor: UIColor.appColors.darkBlue)
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
