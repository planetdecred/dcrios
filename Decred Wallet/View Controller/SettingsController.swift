//
//  SettingsController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit



class SettingsController: UITableViewController  {
    
    weak var delegate: LeftMenuProtocol?
    
    @IBOutlet weak var network_mode_subtitle: UILabel!
    @IBOutlet weak var network_mode: UITableViewCell!
    @IBOutlet weak var node_cell_view: UITableViewCell!
    @IBOutlet weak var server_viewCell: UITableViewCell!
    @IBOutlet weak var connect_peer_ip: UITextField!
    @IBOutlet weak var build: UILabel!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var server_ip: UITextField!
    @IBOutlet weak var debu_msg: UISwitch!
    @IBOutlet weak var testnet_switch: UISwitch!
    @IBOutlet weak var spend_uncon_fund: UISwitch!
    @IBOutlet weak var incoming_notification_switch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        build.text = "2.0"
        
       
        UserDefaults.standard.set(0, forKey: "network_mode")
        UserDefaults.standard.synchronize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Settings"
        self.removeNavigationBarItem()
        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        if (network_value == 0){
            network_mode_subtitle.text = "Simplified Payment Verification"
        }
        else if(network_value == 1){
            network_mode_subtitle.text = "Local Full full-node"
        }
        else{
            network_mode_subtitle.text = "Remote Full full-node"
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
    func loadDate()->Bool{
        
        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        version.text = UserDefaults.standard.string(forKey: "app_version")
        build.text = UserDefaults.standard.string(forKey: "build_version")
        debu_msg.setOn(UserDefaults.standard.bool(forKey: "pref_notify_switch"), animated: true)
        spend_uncon_fund.setOn(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch"), animated: true)
        connect_peer_ip.text = UserDefaults.standard.string(forKey: "pref_peer_ip")
        server_ip.text = UserDefaults.standard.string(forKey: "pref_server_ip")
        incoming_notification_switch.setOn(UserDefaults.standard.bool(forKey: "pref_notification_switch"), animated: true)
        
        if (network_value == 0){
            network_mode_subtitle.text = "Simplified Payment Verification"
        }
        else if(network_value == 1){
            network_mode_subtitle.text = "Local Full full-node"
        }
        else{
            network_mode_subtitle.text = "Remote Full full-node"
        }
        return true;
    }
    func save() -> Bool {
        UserDefaults.standard.set(0, forKey: "network_mode")
        
        UserDefaults.standard.synchronize()
        return true;
    }

    
  /*  @IBAction func didTouchToMain(_ sender: UIButton) {
        delegate?.changeViewController(LeftMenu.overview)
    }*/
}
