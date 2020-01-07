//  ReceiveViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

class ReceiveViewController: UIViewController,UIDocumentInteractionControllerDelegate {
    
    //var receiveAccountTableView: AccountTableView?
    
    @IBOutlet weak var selectedAccountNameLbl: UILabel!
    @IBOutlet weak var selectedAccountWalletNameLbl: UILabel!
    @IBOutlet weak var selectedAccountTotalBalanceLbl: UILabel!
    @IBOutlet weak var generatedReceiveAddrLbl: UILabel!
    @IBOutlet weak var accountSelectionDropdownBtn: UIButton!
    @IBOutlet weak var generatedReceiveAddrQRCodeImg: UIImageView!
    
    private var moreNavBarBtnItem: UIBarButtonItem?
    private lazy var syncInProgressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = LocalizedStrings.secureMenuSyncInfo
        return label
    }()
    
    private lazy var receiveAccountTableView: AccountTableView = {
        let receiveAccountTableView = AccountTableView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        UIApplication.shared.keyWindow?.addSubview(receiveAccountTableView)
        
        receiveAccountTableView.onAccountSelected = {
            [weak self] (selectedAccount:DcrlibwalletAccount,walletName:String) in

            guard let this = self else { return }

            this.myacc = selectedAccount

            this.selectedAccountNameLbl.text = this.myacc?.name
            this.selectedAccountWalletNameLbl.text = walletName

            let total = "\(this.myacc?.balance?.total ?? 0)"
            this.selectedAccountTotalBalanceLbl.attributedText = Utils.getAttributedString(str: "\(total)", siz: 14.0, TexthexColor: UIColor.appColors.darkBlue)

            this.getAddress(accountNumber: (this.myacc!.number))
        }
        receiveAccountTableView.hide = {
            [weak self] () in
            guard let this = self else { return }
            this.accountSelectionDropdownBtn.isSelected = !this.accountSelectionDropdownBtn.isSelected
        }
        return receiveAccountTableView
    }()

    var firstTrial = true
    var myacc: DcrlibwalletAccount?
    var tapGesture = UITapGestureRecognizer()
    var oldAddress = ""
    var wallet = AppDelegate.walletLoader.wallet

    private var selectedAccount = ""

    override func loadView() {
        super.loadView()
        view.addSubview(syncInProgressLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSyncInProgressLabelConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = LocalizedStrings.receiveDCR
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_close")?.withRenderingMode(.alwaysOriginal),
                                                                style: .done, target: self,
                                                                action: #selector(navigateToBackScreen))
        checkSyncStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.leftBarButtonItem = nil
    }
    
    @objc func accountSelectionDropdownBtnClick() {
        self.accountSelectionDropdownBtn.isSelected = !self.accountSelectionDropdownBtn.isSelected
                
        self.receiveAccountTableView.showView()
    }
    
    func setupExtraUI() {
        self.accountSelectionDropdownBtn.addTarget(self, action: #selector(accountSelectionDropdownBtnClick), for: .touchUpInside)
        self.selectedAccountTotalBalanceLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(accountSelectionDropdownBtnClick)))
        self.generatedReceiveAddrQRCodeImg.addGestureRecognizer(tapToCopyAddressGesture())
        self.generatedReceiveAddrLbl.addGestureRecognizer(tapToCopyAddressGesture())
    }
    
    func tapToCopyAddressGesture() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(self.copyAddress))
    }
    
    @objc func copyAddress() {
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = self.generatedReceiveAddrLbl.text!

            //Alert
            let alertController = UIAlertController(title: "", message: LocalizedStrings.walletAddrCopied, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: LocalizedStrings.ok, style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func showMenu(sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)
        
        let generateNewAddressAction = UIAlertAction(title: LocalizedStrings.genNewAddr, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.generateNewAddress()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(generateNewAddressAction)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = moreNavBarBtnItem
        }

        self.present(alertController, animated: true, completion: nil)
    }

    private func checkSyncStatus() {
        let isSynced = AppDelegate.walletLoader.isSynced
        let isNewWalletSetup: Bool = Settings.readValue(for: Settings.Keys.NewWalletSetUp)
        let initialSyncCompleted: Bool = Settings.readOptionalValue(for: Settings.Keys.InitialSyncCompleted) ?? false
        if isSynced || isNewWalletSetup || initialSyncCompleted {
            
            self.setupExtraUI()
            
            self.showFirstWalletAddressAndQRCode()
            self.showDefaultWalletAccount()
            syncInProgressLabel.isHidden = true

            let infoBtn = UIButton(type: .custom)
            infoBtn.setImage(UIImage(named: "ic_info"), for: .normal)
            infoBtn.addTarget(self, action: #selector(tips), for: .touchUpInside)
            infoBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            let infoNavBarBtnItem: UIBarButtonItem = UIBarButtonItem(customView: infoBtn)

            let moreBtn = UIButton(type: .custom)
            moreBtn.setImage(UIImage(named: "ic_more"), for: .normal)
            moreBtn.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
            moreBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            moreNavBarBtnItem = UIBarButtonItem(customView: moreBtn)
            self.navigationItem.rightBarButtonItems = [moreNavBarBtnItem!, infoNavBarBtnItem]
        } else {
            syncInProgressLabel.isHidden = false
        }
    }

    private func setupSyncInProgressLabelConstraints() {
        /// This will position the label at the center of the view
        syncInProgressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        syncInProgressLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        syncInProgressLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    }

    private func generateNewAddress() {
        self.oldAddress = self.generatedReceiveAddrLbl.text!
        self.getNextAddress(accountNumber: (self.myacc?.number)!)
    }
    
    private func showFirstWalletAddressAndQRCode() {
        
        if let acc = AppDelegate.walletLoader.wallet?.walletAccounts(confirmations: 0) {
            let accNames: [String] = (acc.map({ $0.name }))
            self.myacc = acc.first
            
            if let firstWalletAddress = accNames.first {
                self.selectedAccount = firstWalletAddress
                self.generatedReceiveAddrLbl.text = self.selectedAccount

                let total = "\(self.myacc?.balance?.total ?? 0)"
                self.selectedAccountTotalBalanceLbl.attributedText = Utils.getAttributedString(str: "\(total)", siz: 14.0, TexthexColor: UIColor.init(hex: "0A1440"))
                
                self.getAddress(accountNumber: self.myacc!.number)
            }
        } else {
            print("no account")
        }
    }
    
    private func showDefaultWalletAccount() {
        
        if let acc = AppDelegate.walletLoader.wallet?.walletAccounts(confirmations: 0) {
           if let defaultAccount = acc.filter({ $0.isDefault}).first {
               
                self.selectedAccountNameLbl.text = defaultAccount.name

                let total = "\(defaultAccount.balance?.total ?? 0)"
            self.selectedAccountTotalBalanceLbl.attributedText = Utils.getAttributedString(str: "\(total)", siz: 14.0, TexthexColor: UIColor.appColors.darkBlue)
            
                self.myacc = defaultAccount
                self.getAddress(accountNumber: (self.myacc!.number))
            }
        }
    }
    
    @objc func tips(){
        let alertController = UIAlertController(title: LocalizedStrings.receiveDCR, message: LocalizedStrings.receiveTip, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt, style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
        
    @objc func getNext(){
        self.getNextAddress(accountNumber: (self.myacc?.number)!)
    }
    
    @IBAction func shareImgOnTap(_ sender: UIButton) {
        var img: UIImage = self.generatedReceiveAddrQRCodeImg.image!
        
        if img.cgImage == nil {
            guard let ciImage = img.ciImage, let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {return}
            img = UIImage(cgImage: cgImage)
        }
        
        let activityController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        
        if let popoverPresentationController = activityController.popoverPresentationController {
            popoverPresentationController.barButtonItem = moreNavBarBtnItem
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
        
    private func getAddress(accountNumber : Int32) {
        let receiveAddress = self.wallet?.currentAddress(Int32(accountNumber), error: nil)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            this.generatedReceiveAddrLbl.text = receiveAddress!
            this.generatedReceiveAddrQRCodeImg.image = this.generateQRCodeFor(
                with: receiveAddress!,
                forImageViewFrame: this.generatedReceiveAddrQRCodeImg.frame
            )
        }
    }
    
    @objc private func getNextAddress(accountNumber : Int32){
        let receiveAddress = self.wallet?.nextAddress(Int32(accountNumber), error: nil)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            if (this.oldAddress != receiveAddress!) {
                this.generatedReceiveAddrLbl.text = receiveAddress!
                this.generatedReceiveAddrQRCodeImg.image = this.generateQRCodeFor(
                    with: receiveAddress!,
                    forImageViewFrame: this.generatedReceiveAddrQRCodeImg.frame
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
}
