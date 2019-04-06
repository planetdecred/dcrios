//
//  SettingsController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import Foundation
import UIKit

protocol StartUpPasswordProtocol {
    var senders: String?{get set}
    var pass_pinToVerify:String?{get set}
}

class SettingsController: UITableViewController  {
    
    weak var delegate: LeftMenuProtocol?
    
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
    
    @IBOutlet weak var connect_peer_ip: UILabel!
    @IBOutlet weak var build: UILabel!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var server_ip: UILabel!
    
    @IBOutlet weak var debu_msg: UISwitch!
    @IBOutlet weak var spend_uncon_fund: UISwitch!
    @IBOutlet weak var incoming_notification_switch: UISwitch!
    @IBOutlet weak var start_Pin: UISwitch!
    @IBOutlet weak var currency_subtitle: UILabel!
    
    
    
    var isFromLoader = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Settings"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        connect_peer_ip?.text = UserDefaults.standard.string(forKey: "pref_peer_ip") ?? ""
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? ""
        
        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        loadDate()
        if (network_value == 0) {
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
        if (start_Pin.isOn) {
            changeStartPINCell.isUserInteractionEnabled = true
            changeStartPINCell.alpha = 1
        }
        else{
            changeStartPINCell.isUserInteractionEnabled = false
            changeStartPINCell.alpha = 0.4
        }
        
    }
    
    @objc func cancel() -> Void {
        if self.isFromLoader == true {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.popViewController(animated: true)
        } else {
            delegate?.changeViewController(LeftMenu.overview)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.string(forKey: "TMPPIN") != nil{
            let pin = UserDefaults.standard.string(forKey: "TMPPIN")!
            self.handleDeleteWallet(pass: pin)
            UserDefaults.standard.set(nil, forKey: "TMPPIN")
        }
    }
    
    func loadDate()-> Void {
        
        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        let currency_value = UserDefaults.standard.integer(forKey: "currency")
        version?.text = UserDefaults.standard.string(forKey: "app_version") ?? "Pre-release"
        
        var compileDate:Date
        {
            let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
            if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
                let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
                let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
            { return infoDate }
            return Date()
        }
        
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        build?.text = dateformater.string(from: compileDate as Date)
        debu_msg?.setOn((UserDefaults.standard.bool(forKey: "pref_debug_switch") ), animated: false)
        spend_uncon_fund?.setOn(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch"), animated: false)
        connect_peer_ip?.text = UserDefaults.standard.string(forKey: "pref_peer_ip") ?? ""
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? ""
        incoming_notification_switch?.setOn(UserDefaults.standard.bool(forKey: "pref_notification_switch"), animated: true)
        start_Pin?.setOn(UserDefaults.standard.bool(forKey: "secure_wallet") , animated: false)
        
        if (network_value == 0) {
            network_mode_subtitle?.text = "Simplified Payment Verification (SPV)"
        }else{
            network_mode_subtitle?.text = "Remote Full Node"
        }
        if (currency_value == 0) {
            currency_subtitle?.text = "None"
        }else{
            currency_subtitle?.text = "USD (bittrex)"
        }
    }
    
    @objc func save() -> Void {
        UserDefaults.standard.set(incoming_notification_switch.isOn, forKey: "pref_notification_switch")
        UserDefaults.standard.set(spend_uncon_fund.isOn, forKey: "pref_spend_fund_switch")
        UserDefaults.standard.set(debu_msg.isOn, forKey: "pref_debug_switch")
        UserDefaults.standard.synchronize()
        if (self.isFromLoader == true) {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.popViewController(animated: true)
        } else {
            delegate?.changeViewController(LeftMenu.overview)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetstartupPin_pas"{
            var startUp = segue.destination as?
            StartUpPasswordProtocol
            startUp?.senders = "settings"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !(start_Pin.isOn) {
            if (indexPath.section == 0){
                if (indexPath.row == 2) {
                    return 0
                }
            }
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                if (start_Pin.isOn) {
                    if (UserDefaults.standard.string(forKey: "securitytype") == "PASSWORD") {
                        let sendVC = storyboard!.instantiateViewController(withIdentifier: "StartUpPasswordViewController") as! StartUpPasswordViewController
                        sendVC.senders = "settings"
                        self.navigationController?.pushViewController(sendVC, animated: true)
                    } else {
                        let pinSetupVC = storyboard!.instantiateViewController(withIdentifier: "PinSetupViewController") as! PinSetupViewController
                        pinSetupVC.isSpendingPassword = false
                        pinSetupVC.isSecure = true
                        self.navigationController?.pushViewController(pinSetupVC, animated: true)
                    }
                } else {
                    self.performSegue(withIdentifier: "SetstartupPin_pas", sender: self)
                }
            } else if (indexPath.row == 0) {
                if (UserDefaults.standard.string(forKey: "spendingSecureType") == "PASSWORD") {
                    let sendVC = storyboard!.instantiateViewController(withIdentifier: "StartUpPasswordViewController") as! StartUpPasswordViewController
                    sendVC.senders = "settingsChangeSpending"
                    self.navigationController?.pushViewController(sendVC, animated: true)
                } else {
                    let pinSetupVC = storyboard!.instantiateViewController(withIdentifier: "PinSetupViewController") as! PinSetupViewController
                    pinSetupVC.isSpendingPassword = true
                    pinSetupVC.isChange = true
                    self.navigationController?.pushViewController(pinSetupVC, animated: true)
                }
            }
            else if (indexPath.row == 2) {
                if (UserDefaults.standard.string(forKey: "startupSecureType") == "PASSWORD") {
                    let sendVC = storyboard!.instantiateViewController(withIdentifier: "StartUpPasswordViewController") as! StartUpPasswordViewController
                    sendVC.senders = "settingsChangeStartup"
                    self.navigationController?.pushViewController(sendVC, animated: true)
                } else {
                    let pinSetupVC = storyboard!.instantiateViewController(withIdentifier: "PinSetupViewController") as! PinSetupViewController
                    pinSetupVC.isSpendingPassword = false
                    pinSetupVC.isChange = true
                    self.navigationController?.pushViewController(pinSetupVC, animated: true)
                }
            }
        }
    }
    
    @IBAction func deleteWallet(_ sender: Any) {
        if UserDefaults.standard.string(forKey: "spendingSecureType") == "PASSWORD" {
            let alert = UIAlertController(title: "Delete Wallet", message: "Please enter spending password of your wallet", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "password"
                textField.isSecureTextEntry = true
            }
        
            let okAction = UIAlertAction(title: "Proceed", style: .default) { _ in
                let tfPasswd = alert.textFields![0] as UITextField
                if (tfPasswd.text?.count)! > 0 {
                    self.handleDeleteWallet(pass: tfPasswd.text!)
                    alert.dismiss(animated: false, completion: nil)
                } else {
                    alert.dismiss(animated: false, completion: nil)
                    self.showAlert(message: "Password can't be empty.", titles: "invalid input")
                }
            }
        
            let CancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                alert.dismiss(animated: false, completion: nil)
            }
            alert.addAction(CancelAction)
            alert.addAction(okAction)
        
            self.present(alert, animated: true, completion: nil)
        }else{
            let vc = storyboard!.instantiateViewController(withIdentifier: "PinSetupViewController") as! PinSetupViewController
            vc.isSpendingPassword = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showAlert(message: String? , titles: String?) {
        let alert = UIAlertController(title: titles, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleDeleteWallet(pass: String){
        let progressHud = showProgressHud(with: "Deleting wallet...")
        let wallet = SingleInstance.shared.wallet!
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                let passData = (pass as NSString).data(using: String.Encoding.utf8.rawValue)!
                wallet.dropSpvConnection()
                try wallet.unlock(passData)
                try wallet.close()

                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let walletDir = paths[0].appendingPathComponent("dcrlibwallet")
                try FileManager.default.removeItem(at: walletDir)
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    UserDefaults.standard.set(true, forKey: GlobalConstants.Strings.DELETE_WALLET)
                    UserDefaults.standard.synchronize()
                    self?.delegate?.changeViewController(LeftMenu.overview)
                }
            } catch {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    let alertController = UIAlertController(title: "", message: "Passphrase was not valid.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    this.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
}
