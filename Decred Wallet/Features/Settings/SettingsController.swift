//
//  SettingsController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import Foundation
import UIKit
import JGProgressHUD
import Dcrlibwallet

class SettingsController: UITableViewController  {
    @IBOutlet weak var changeStartPINCell: UITableViewCell!
    @IBOutlet weak var connectPeer_cell: UITableViewCell!
    @IBOutlet weak var server_cell: UITableViewCell!
    @IBOutlet weak var certificate_cell: UITableViewCell!
    @IBOutlet weak var network_mode_subtitle: UILabel!
    @IBOutlet weak var network_mode: UITableViewCell!
    @IBOutlet weak var Start_Pin_cell: UITableViewCell!
    
    @IBOutlet weak var cellularSyncSwitch: UISwitch!
    
    @IBOutlet weak var connect_peer_ip: UILabel!
    @IBOutlet weak var build: UILabel!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var server_ip: UILabel!
    
    @IBOutlet weak var spend_uncon_fund: UISwitch!
    @IBOutlet weak var incoming_notification_switch: UISwitch!
    @IBOutlet weak var start_Pin: UISwitch!
    @IBOutlet weak var currency_subtitle: UILabel!
    
    // settings title.
    @IBOutlet weak var changeSpendingPinPassDesc: UILabel!
    @IBOutlet weak var spendingPinPassInfo: UILabel!
    @IBOutlet weak var startupPinPassDesc: UILabel!
    @IBOutlet weak var changeStatupPinPassDesc: UILabel!
    @IBOutlet weak var startupPinPassInfo: UILabel!
    @IBOutlet weak var spendUnconfirmedFundDesc: UILabel!
    @IBOutlet weak var incomingTxNotificationDesc: UILabel!
    @IBOutlet weak var currencyConversionDesc: UILabel!
    @IBOutlet weak var networkModeDesc: UILabel!
    @IBOutlet weak var serverAddDesc: UILabel!
    @IBOutlet weak var connectIpDesc: UILabel!
    @IBOutlet weak var certificatDesc: UILabel!
    @IBOutlet weak var syncOnWifiDesc: UILabel!
    @IBOutlet weak var versionDesc: UILabel!
    @IBOutlet weak var buildDateDesc: UILabel!
    @IBOutlet weak var licenseDesc: UILabel!
    @IBOutlet weak var rescanBlockChainDesc: UILabel!
    @IBOutlet weak var walletLogDesc: UILabel!
    @IBOutlet weak var deleteWalletDesc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spend_uncon_fund.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.incoming_notification_switch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.cellularSyncSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        self.setMenuTitle()
    }
    
    @objc func switchChanged(switchView: UISwitch) {
        var fieldToUpdate: String?
        switch switchView {
        case self.spend_uncon_fund:
            fieldToUpdate = Settings.Keys.SpendUnconfirmed
            
        case self.incoming_notification_switch:
            fieldToUpdate = Settings.Keys.IncomingNotification
            
        case self.cellularSyncSwitch:
            fieldToUpdate = Settings.Keys.SyncOnCellular
            
        default:
            return
        }
        
        if fieldToUpdate != nil {
            Settings.setValue(switchView.isOn, for: fieldToUpdate!)
        }
    }
    
    func setMenuTitle(){
        self.changeSpendingPinPassDesc.text = LocalizedStrings.changeSpendingPinPassDesc
        self.spendingPinPassInfo.text = LocalizedStrings.spendingPinPassInfo
        self.startupPinPassDesc.text = LocalizedStrings.startupPinPassDesc
        self.changeStatupPinPassDesc.text = LocalizedStrings.changeStatupPinPassDesc
        self.startupPinPassInfo.text = LocalizedStrings.startupPinPassInfo
        self.spendUnconfirmedFundDesc.text = LocalizedStrings.spendUnconfirmedFundDesc
        self.incomingTxNotificationDesc.text = LocalizedStrings.incomingTxNotificationDesc
        self.currencyConversionDesc.text = LocalizedStrings.currencyConversionDesc
        self.networkModeDesc.text = LocalizedStrings.networkModeDesc
        self.serverAddDesc.text = LocalizedStrings.serverAddDesc
        self.connectIpDesc.text = LocalizedStrings.connectIpDesc
        self.certificatDesc.text = LocalizedStrings.certificatDesc
        self.syncOnWifiDesc.text = LocalizedStrings.syncOnWifiDesc
        self.versionDesc.text = LocalizedStrings.version
        self.buildDateDesc.text = LocalizedStrings.buildDateDesc
        self.licenseDesc.text = LocalizedStrings.license
        self.rescanBlockChainDesc.text = LocalizedStrings.rescanBlockChainDesc
        self.walletLogDesc.text = LocalizedStrings.walletLogDesc
        self.deleteWalletDesc.text = LocalizedStrings.deleteWalletDesc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = LocalizedStrings.settings
        
        if self.isModal {
            self.addNavigationBackButton()
        } else {
            self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        }
        
        connect_peer_ip?.text = Settings.readOptionalValue(for: Settings.Keys.SPVPeerIP) ?? ""
        server_ip?.text = Settings.readOptionalValue(for: Settings.Keys.RemoteServerIP) ?? ""
        
        loadSettingsData()
        self.checkStartupSecurity()

        if Settings.networkMode == 0 {
            network_mode_subtitle?.text = LocalizedStrings.spv
            self.certificate_cell.isUserInteractionEnabled = false
            self.server_cell.isUserInteractionEnabled = false
            self.connectPeer_cell.isUserInteractionEnabled = true
            self.server_ip.textColor = UIColor.lightGray
            self.certificatDesc.textColor = UIColor.lightGray
            self.connect_peer_ip.textColor = UIColor.darkText
            self.serverAddDesc.textColor = UIColor.lightGray
            self.connectIpDesc.textColor = UIColor.darkText
        } else {
            network_mode_subtitle?.text = LocalizedStrings.remoteFullNode
            self.certificate_cell.isUserInteractionEnabled = true
            self.server_cell.isUserInteractionEnabled = true
            self.connectPeer_cell.isUserInteractionEnabled = false
            self.connect_peer_ip.textColor = UIColor.lightGray
            self.certificatDesc.textColor = UIColor.darkText
            self.server_ip.textColor = UIColor.darkText
            self.serverAddDesc.textColor = UIColor.darkText
            self.connectIpDesc.textColor = UIColor.lightGray
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard let vc = (self.slideMenuController()?.mainViewController as? UINavigationController)?.topViewController else {
                return
            }
            if vc.isKind(of: SettingsController.self) {
                self.slideMenuController()?.removeLeftGestures()
                self.slideMenuController()?.removeRightGestures()
            }
        })
    }
    
    func loadSettingsData() -> Void {
        version?.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        build?.text = dateformater.string(from: AppDelegate.compileDate as Date)
        spend_uncon_fund?.setOn(Settings.spendUnconfirmed, animated: false)
        connect_peer_ip?.text = Settings.readOptionalValue(for: Settings.Keys.SPVPeerIP) ?? ""
        server_ip?.text = Settings.readOptionalValue(for: Settings.Keys.RemoteServerIP) ?? ""
        incoming_notification_switch?.setOn(Settings.incomingNotificationEnabled, animated: true)
        
        self.cellularSyncSwitch.isOn = Settings.readValue(for: Settings.Keys.SyncOnCellular)
        
        if Settings.networkMode == 0 {
            network_mode_subtitle?.text = LocalizedStrings.spv
        } else {
            network_mode_subtitle?.text = LocalizedStrings.remoteFullNode
        }
        
        switch Settings.currencyConversionOption {
        case .None:
            currency_subtitle?.text = LocalizedStrings.none
        case .Bittrex:
            currency_subtitle?.text = "USD (bittrex)"
        }
    }
    
    func checkStartupSecurity() {
        start_Pin?.setOn(StartupPinOrPassword.pinOrPasswordIsSet(), animated: false)
        
        if start_Pin.isOn {
            changeStartPINCell.isUserInteractionEnabled = true
            changeStartPINCell.alpha = 1
        }
        else{
            changeStartPINCell.isUserInteractionEnabled = false
            changeStartPINCell.alpha = 0.4
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionName: String
        switch section {
        case 0:
            sectionName = LocalizedStrings.general.capitalized
        case 1:
            sectionName = LocalizedStrings.connection.capitalized
        case 2:
            sectionName = LocalizedStrings.about.capitalized
        case 3:
            sectionName = LocalizedStrings.debug.capitalized
        default:
            sectionName = ""
        }
        return sectionName
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isWalletOpen = AppDelegate.walletLoader.wallet?.walletOpened() ?? false
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: // change spending pin/password, requires wallet to be opened.
                return isWalletOpen ? 44 : 0
                
            case 1: // enable startup pin/password, requires wallet to be opened.
                return isWalletOpen ? 44 : 0
                
            case 2: // change startup pin/password, requires wallet to be opened and startup pin to have been enabled previously.
                return isWalletOpen && start_Pin.isOn ? 44 : 0
                
            default:
                return 44
            }
        }
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 1: // connect to peer, only show if network mode is SPV (0).
                 return Settings.networkMode == 0 ? 44 : 0
                
            case 2, 3: // server address and certificate options, only show if network mode is full node (1).
                return Settings.networkMode == 1 ? 44 : 0
                
            default:
                return 44
            }
        }
        
        if indexPath.section == 3 {
            switch indexPath.row {
            case 0, 2: // rescan blockchain and delete wallet options, requires wallet to be opened.
                return isWalletOpen ? 44 : 0
                
            default:
                return 44
            }
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: // change spending pin/password
                SpendingPinOrPassword.change(sender: self)
                
            case 1: // enable/disable startup pin/password
                if (start_Pin.isOn) {
                    StartupPinOrPassword.clear(sender: self, completion: self.checkStartupSecurity)
                } else {
                    StartupPinOrPassword.set(sender: self, completion: self.checkStartupSecurity)
                }
                
            case 2: // change startup pin/password
                StartupPinOrPassword.change(sender: self, completion: self.checkStartupSecurity)
                
            default:
                break
            }
        } else if indexPath.section == 3 && indexPath.row == 0 {
            // rescan blockchain
            self.showOkAlert(message: LocalizedStrings.rescanConfirm,
                             title: LocalizedStrings.rescanBlockchain,
                             onPressOk: self.rescanBlocks,
                             addCancelAction: true)
        }
    }
    
    func rescanBlocks() {
        if AppDelegate.walletLoader.wallet!.isSyncing() {
            self.showOkAlert(message: LocalizedStrings.syncPreogressAlert)
            return
        }
        
        do {
            try AppDelegate.walletLoader.wallet?.rescanBlocks()
            self.displayToast(LocalizedStrings.syncToastMsg)
        } catch let error {
            var errorMessage = error.localizedDescription
            if errorMessage == DcrlibwalletErrInvalid {
                errorMessage = LocalizedStrings.scanStartedAlready
            }
            self.showOkAlert(message: errorMessage, title: LocalizedStrings.rescanFailed)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDeleteWalletConfirmationDialog" {
            let deleteWalletDialog = segue.destination as! DeleteWalletConfirmationViewController
            deleteWalletDialog.onDeleteWalletConfirmed = { password in
                if password != nil {
                    self.deleteWallet(spendingPinOrPassword: password!)
                    return
                }
                
                let requestPinVC = RequestPinViewController.instantiate()
                requestPinVC.securityFor = LocalizedStrings.spending
                requestPinVC.showCancelButton = true
                requestPinVC.onUserEnteredPin = { pin in
                    self.deleteWallet(spendingPinOrPassword: pin)
                }
                self.present(requestPinVC, animated: true, completion: nil)
            }
        }
    }
    
    func deleteWallet(spendingPinOrPassword: String) {
        let progressHud = Utils.showProgressHud(withText: LocalizedStrings.deletingWallet)
        DispatchQueue.global(qos: .background).async {
            do {
                try AppDelegate.walletLoader.wallet?.delete(spendingPinOrPassword.utf8Bits)
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    self.walletDeleted()
                }
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                }
                print("delete wallet error: \(error.localizedDescription)")
                self.showOkAlert(message: LocalizedStrings.walletDeletfailed, title: LocalizedStrings.error)
            }
        }
    }
    
    // Clear values stored in UserDefaults and restart the app when wallet is deleted.
    func walletDeleted() {
        Settings.clear()
        
        // Stop calling wallet.bestBlockTimestamp() to update the best block age displayed on nav menu.
        self.navigationMenuViewController()?.stopRefreshingBestBlockAge()
        
        let startScreen = Storyboards.Main.initialViewController()
        AppDelegate.shared.setAndDisplayRootViewController(startScreen!)
    }
    
    static func instantiate() -> Self {
        return Storyboards.Settings.instantiateViewController(for: self)
    }
}
