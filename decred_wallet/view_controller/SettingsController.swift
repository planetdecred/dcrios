//
//  SettingsController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit



class SettingsController: UITableViewController  {
    
    weak var delegate: LeftMenuProtocol?
    @IBOutlet weak var peer_cell: UIView!
    
    @IBOutlet weak var connectPeer_cell: UITableViewCell!
    @IBOutlet weak var server_cell: UITableViewCell!
    @IBOutlet weak var certificate_cell: UITableViewCell!
    @IBOutlet weak var serverAdd_label: UILabel!
    @IBOutlet weak var connect_ip_label: UILabel!
    @IBOutlet weak var certificat_label: UILabel!
    @IBOutlet weak var network_mode_subtitle: UILabel!
    @IBOutlet weak var network_mode: UITableViewCell!
  
    @IBOutlet weak var connect_peer_ip: UILabel!
    @IBOutlet weak var build: UILabel!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var server_ip: UILabel!
    
    @IBOutlet weak var debu_msg: UISwitch!
    @IBOutlet weak var testnet_switch: UISwitch!
    @IBOutlet weak var spend_uncon_fund: UISwitch!
    @IBOutlet weak var incoming_notification_switch: UISwitch!
    
    var isFromLoader = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       loadDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        self.navigationItem.title = "Settings"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        connect_peer_ip?.text = UserDefaults.standard.string(forKey: "pref_peer_ip") ?? "0.0.0.0"
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? "0.0.0.0"
        
        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        if (network_value == 0){
            network_mode_subtitle?.text = "Simplified Payment Verification"
            self.certificate_cell.isUserInteractionEnabled = false
            self.server_cell.isUserInteractionEnabled = false
            self.connectPeer_cell.isUserInteractionEnabled = true
            self.server_ip.textColor = UIColor.lightGray
            self.certificat_label.textColor = UIColor.lightGray
             self.connect_peer_ip.textColor = UIColor.darkText
             self.serverAdd_label.textColor = UIColor.lightGray
            self.connect_ip_label.textColor = UIColor.darkText
        }
        else if(network_value == 1){
            network_mode_subtitle?.text = "Local Full full-node"
            self.certificate_cell.isUserInteractionEnabled = false
            self.server_cell.isUserInteractionEnabled = false
            self.connectPeer_cell.isUserInteractionEnabled = true
            self.server_ip.textColor = UIColor.lightGray
            self.certificat_label.textColor = UIColor.lightGray
             self.connect_peer_ip.textColor = UIColor.darkText
            self.serverAdd_label.textColor = UIColor.lightGray
            self.connect_ip_label.textColor = UIColor.darkText
          
        }
        else{
            network_mode_subtitle?.text = "Remote Full full-node"
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
            if vc.isKind(of: SettingsController.self)  {
                self.slideMenuController()?.removeLeftGestures()
                self.slideMenuController()?.removeRightGestures()
            }
        })
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
        
    }
    func loadDate()-> Void{
        
        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        version?.text = UserDefaults.standard.string(forKey: "app_version") ?? "1.0"
        build?.text = UserDefaults.standard.string(forKey: "build_version") ?? "1.0"
        debu_msg?.setOn((UserDefaults.standard.bool(forKey: "pref_debug_switch") ), animated: true)
        spend_uncon_fund?.setOn(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch"), animated: true)
        connect_peer_ip?.text = UserDefaults.standard.string(forKey: "pref_peer_ip") ?? "0.0.0.0"
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? "0.0.0.0"
        incoming_notification_switch?.setOn(UserDefaults.standard.bool(forKey: "pref_notification_switch"), animated: true)
        
        if (network_value == 0){
            network_mode_subtitle?.text = "Simplified Payment Verification (SPV)"
        }
        else if(network_value == 1){
            network_mode_subtitle?.text = "Local Full full-node"
        }
        else{
            network_mode_subtitle?.text = "Remote Full full-node"
        }
    }
    @objc func save() -> Void {
        UserDefaults.standard.set(incoming_notification_switch.isOn, forKey: "pref_notification_switch")
        UserDefaults.standard.set(spend_uncon_fund.isOn, forKey: "pref_spend_fund_switch")
        UserDefaults.standard.set(debu_msg.isOn, forKey: "pref_debug_switch")
    UserDefaults.standard.set(testnet_switch.isOn, forKey: "pref_use_testnet")
        UserDefaults.standard.synchronize()
        AppContext.instance.decrdConnection?.applySettings()
        if self.isFromLoader == true {
            self.navigationController?.navigationBar.isHidden = true
            self.navigationController?.popViewController(animated: true)
        } else {
          delegate?.changeViewController(LeftMenu.overview)
        }
        
    }

    
  /*  @IBAction func didTouchToMain(_ sender: UIButton) {
        delegate?.changeViewController(LeftMenu.overview)
    }*/
}
