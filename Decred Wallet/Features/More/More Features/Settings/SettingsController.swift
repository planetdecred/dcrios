//
//  SettingsController.swift
//  Decred Wallet

// Copyright (c) 2018-2020 The Decred developers
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
    @IBOutlet weak var server_ip: UILabel!
    
    @IBOutlet weak var spend_uncon_fund: UISwitch!
    @IBOutlet weak var incoming_notification_switch: UISwitch!
    @IBOutlet weak var start_Pin: UISwitch!
    @IBOutlet weak var currency_subtitle: UILabel!
    @IBOutlet weak var certificateLabel: UILabel!
    @IBOutlet weak var serverAddressLabel: UILabel!
    @IBOutlet weak var connectIpDesc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spend_uncon_fund.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.incoming_notification_switch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.cellularSyncSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 56, right: 0)
    }
    
    @objc func switchChanged(switchView: UISwitch) {
        var fieldToUpdate: String?
        switch switchView {
        case self.spend_uncon_fund:
            fieldToUpdate = DcrlibwalletSpendUnconfirmedConfigKey
            
        case self.incoming_notification_switch:
            // should be set per wallet, rather than once for all wallets
            break
            
        case self.cellularSyncSwitch:
            fieldToUpdate = DcrlibwalletSyncOnCellularConfigKey
            
        default:
            return
        }
        
        if fieldToUpdate != nil {
            Settings.setBoolValue(switchView.isOn, for: fieldToUpdate!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.offWhite
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "ic_close"),
                                          style: .done,
                                          target: self,
                                          action: #selector(self.dismissView))
        
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.settings, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.black // UIColor.appColor.darkblue
        
        self.navigationItem.leftBarButtonItems =  [closeButton, barButtonTitle]
        
        connect_peer_ip?.text = Settings.readStringValue(for: DcrlibwalletSpvPersistentPeerAddressesConfigKey)
        server_ip?.text = "" // deprecated in v2
        
        loadSettingsData()
        self.checkStartupSecurity()

        if Settings.networkMode == 0 {
            network_mode_subtitle?.text = LocalizedStrings.spv
            self.certificate_cell.isUserInteractionEnabled = false
            self.server_cell.isUserInteractionEnabled = false
            self.connectPeer_cell.isUserInteractionEnabled = true
            self.server_ip.textColor = UIColor.lightGray
            self.certificateLabel.textColor = UIColor.lightGray
            self.connect_peer_ip.textColor = UIColor.darkText
            self.serverAddressLabel.textColor = UIColor.lightGray
            self.connectIpDesc.textColor = UIColor.darkText
        } else {
            network_mode_subtitle?.text = LocalizedStrings.remoteFullNode
            self.certificate_cell.isUserInteractionEnabled = true
            self.server_cell.isUserInteractionEnabled = true
            self.connectPeer_cell.isUserInteractionEnabled = false
            self.connect_peer_ip.textColor = UIColor.lightGray
            self.certificateLabel.textColor = UIColor.darkText
            self.server_ip.textColor = UIColor.darkText
            self.serverAddressLabel.textColor = UIColor.darkText
            self.connectIpDesc.textColor = UIColor.lightGray
        }
    }
    
    func loadSettingsData() -> Void {
        spend_uncon_fund?.setOn(Settings.spendUnconfirmed, animated: false)
        connect_peer_ip?.text = Settings.readStringValue(for: DcrlibwalletSpvPersistentPeerAddressesConfigKey)
        server_ip?.text = "" // deprecated in v2
        incoming_notification_switch?.setOn(Settings.incomingNotificationEnabled, animated: true)
        
        self.cellularSyncSwitch.isOn = Settings.readBoolValue(for: DcrlibwalletSyncOnCellularConfigKey)
        
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
        switch section {
        case 0:
            return LocalizedStrings.general.capitalized
        case 1:
            return LocalizedStrings.security.capitalized
        case 2:
            return LocalizedStrings.notifications.capitalized
        case 3:
            return LocalizedStrings.connection.capitalized
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.appColors.darkBluishGray
        header.textLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 14)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isWalletOpen = WalletLoader.shared.firstWallet?.walletOpened() ?? false
        
        if indexPath.section == 1 {
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
        
        if indexPath.section == 3 {
            switch indexPath.row {
            case 1: // connect to peer, only show if network mode is SPV (0).
                 return Settings.networkMode == 0 ? 44 : 0
                
            case 2, 3: // server address and certificate options, only show if network mode is full node (1).
                return Settings.networkMode == 1 ? 44 : 0
                
            default:
                return 44
            }
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0: // change spending pin/password
                SpendingPinOrPassword.change(sender: self, walletID: WalletLoader.shared.firstWallet!.id_)
                
            case 1: // enable/disable startup pin/password
                if start_Pin.isOn {
                    StartupPinOrPassword.clear(sender: self, done: self.checkStartupSecurity)
                } else {
                    StartupPinOrPassword.set(sender: self, done: self.checkStartupSecurity)
                }
                
            case 2: // change startup pin/password
                StartupPinOrPassword.change(sender: self, done: self.checkStartupSecurity)
                
            default:
                break
            }
        }
    }
}
