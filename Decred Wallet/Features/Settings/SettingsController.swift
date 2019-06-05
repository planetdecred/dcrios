//
//  SettingsController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import Foundation
import UIKit
import JGProgressHUD

class SettingsController: UITableViewController  {
    @IBOutlet weak var changeStartPINCell: UITableViewCell!
    @IBOutlet weak var peer_cell: UIView!
    @IBOutlet weak var connectPeer_cell: UITableViewCell!
    @IBOutlet weak var server_cell: UITableViewCell!
    @IBOutlet weak var certificate_cell: UITableViewCell!
    @IBOutlet weak var serverAdd_label: UILabel!
    @IBOutlet weak var connect_ip_label: UILabel!
    @IBOutlet weak var certificat_label: UILabel!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
        
        self.spend_uncon_fund.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.incoming_notification_switch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.cellularSyncSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func switchChanged(switchView: UISwitch) {
        var fieldToUpdate: String?
        switch switchView {
        case self.spend_uncon_fund:
            fieldToUpdate = Settings.Keys.SpendUnconfirmed
            
        case self.incoming_notification_switch:
            fieldToUpdate = "pref_notification_switch"
            
        case self.cellularSyncSwitch:
            fieldToUpdate = Settings.Keys.SyncOnCellular
            
        default:
            return
        }
        
        if fieldToUpdate != nil {
            Settings.setValue(switchView.isOn, for: fieldToUpdate!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Settings"
        
        if self.isModal {
            self.addNavigationBackButton()
        } else {
            self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        }
        
        connect_peer_ip?.text = Settings.readOptionalValue(for: Settings.Keys.SPVPeerIP) ?? ""
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? ""
        
        loadDate()
        self.checkStartupSecurity()

        if Settings.networkMode == 0 {
            network_mode_subtitle?.text = "Simplified Payment Verification"
            self.certificate_cell.isUserInteractionEnabled = false
            self.server_cell.isUserInteractionEnabled = false
            self.connectPeer_cell.isUserInteractionEnabled = true
            self.server_ip.textColor = UIColor.lightGray
            self.certificat_label.textColor = UIColor.lightGray
            self.connect_peer_ip.textColor = UIColor.darkText
            self.serverAdd_label.textColor = UIColor.lightGray
            self.connect_ip_label.textColor = UIColor.darkText
        } else {
            network_mode_subtitle?.text = "Remote Full Node"
            self.certificate_cell.isUserInteractionEnabled = true
            self.server_cell.isUserInteractionEnabled = true
            self.connectPeer_cell.isUserInteractionEnabled = false
            self.connect_peer_ip.textColor = UIColor.lightGray
            self.certificat_label.textColor = UIColor.darkText
            self.server_ip.textColor = UIColor.darkText
            self.serverAdd_label.textColor = UIColor.darkText
            self.connect_ip_label.textColor = UIColor.lightGray
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
    
    func loadDate() -> Void {
        version?.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        build?.text = dateformater.string(from: AppDelegate.compileDate as Date)
        spend_uncon_fund?.setOn(Settings.spendUnconfirmed, animated: false)
        connect_peer_ip?.text = Settings.readOptionalValue(for: Settings.Keys.SPVPeerIP) ?? ""
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? ""
        incoming_notification_switch?.setOn(UserDefaults.standard.bool(forKey: "pref_notification_switch"), animated: true)
        
        self.cellularSyncSwitch.isOn = Settings.readValue(for: Settings.Keys.SyncOnCellular)
        
        if Settings.networkMode == 0 {
            network_mode_subtitle?.text = "Simplified Payment Verification (SPV)"
        } else {
            network_mode_subtitle?.text = "Remote Full Node"
        }
        
        switch Settings.currencyConversionOption {
        case .None:
            currency_subtitle?.text = "None"
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 {
            // only show section 1, row 3 (change startup pin/password) if startup pin is on
            return start_Pin.isOn ? 44 : 0
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            // only show section 2, row 2 (connect to peer) if network mode is SPV (0)
            return Settings.networkMode == 0 ? 44 : 0
        }
        if indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3) {
            // only show section 2, rows 3 (server address) and 4 (certificate) if network mode is full node (1)
            return Settings.networkMode == 1 ? 44 : 0
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
                requestPinVC.securityFor = "Spending"
                requestPinVC.showCancelButton = true
                requestPinVC.onUserEnteredPin = { pin in
                    self.deleteWallet(spendingPinOrPassword: pin)
                }
                self.present(requestPinVC, animated: true, completion: nil)
            }
        }
    }
    
    func deleteWallet(spendingPinOrPassword: String) {
        let progressHud = Utils.showProgressHud(withText: "Deleting wallet...")
        DispatchQueue.global(qos: .background).async {
            do {
                try AppDelegate.walletLoader.wallet?.delete(spendingPinOrPassword.utf8Bits)
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    self.navigationMenuViewController()?.invalidateSyncTimer()
                    self.walletDeleted()
                }
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                }
                print("delete wallet error: \(error.localizedDescription)")
                self.showOkAlert(message: "Failed to delete wallet.", title: "Error")
            }
        }
    }
    
    // Clear values stored in UserDefaults and restart the app when wallet is deleted.
    func walletDeleted() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let startScreen = Storyboards.Main.initialViewController()
            appDelegate.setAndDisplayRootViewController(startScreen!)
        }
    }
    
    static func instantiate() -> Self {
        return Storyboards.Settings.instantiateViewController(for: self)
    }
}
