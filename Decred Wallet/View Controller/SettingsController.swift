//  SettingsController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class SettingsController: UITableViewController {
    weak var delegate: LeftMenuProtocol?
    @IBOutlet var peer_cell: UIView!

    @IBOutlet var connectPeer_cell: UITableViewCellTheme!
    @IBOutlet var server_cell: UITableViewCellTheme!
    @IBOutlet var certificate_cell: UITableViewCellTheme!
    @IBOutlet var serverAdd_label: UILabelDefaultTextColor!
    @IBOutlet var connect_ip_label: UILabelDefaultTextColor!
    @IBOutlet var certificat_label: UILabelDefaultTextColor!
    @IBOutlet var network_mode_subtitle: UILabel!
    @IBOutlet var network_mode: UITableViewCellTheme!

    @IBOutlet var connect_peer_ip: UILabelDefaultTextColor!
    @IBOutlet var build: UILabelDefaultTextColor!
    @IBOutlet var version: UILabelDefaultTextColor!
    @IBOutlet var server_ip: UILabelDefaultTextColor!

    @IBOutlet var debu_msg: UISwitch!
    @IBOutlet var testnet_switch: UISwitch!
    @IBOutlet var spend_uncon_fund: UISwitch!
    @IBOutlet var incoming_notification_switch: UISwitch!

    var isFromLoader = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = UIColor.blue
        navigationItem.title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        connect_peer_ip?.text = UserDefaults.standard.string(forKey: "pref_peer_ip") ?? "0.0.0.0"
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? "0.0.0.0"

        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        if network_value == 0 {
            network_mode_subtitle?.text = "Simplified Payment Verification"
            certificate_cell.isUserInteractionEnabled = false
            server_cell.isUserInteractionEnabled = false
            connectPeer_cell.isUserInteractionEnabled = true
            server_ip.textColor = UIColor.lightGray
            certificat_label.textColor = UIColor.lightGray
            connect_peer_ip.textColor = UIColor.darkText
            serverAdd_label.textColor = UIColor.lightGray
            connect_ip_label.textColor = UIColor.darkText
        } else if network_value == 1 {
            network_mode_subtitle?.text = "Local Full full-node"
            certificate_cell.isUserInteractionEnabled = false
            server_cell.isUserInteractionEnabled = false
            connectPeer_cell.isUserInteractionEnabled = true
            server_ip.textColor = UIColor.lightGray
            certificat_label.textColor = UIColor.lightGray
            connect_peer_ip.textColor = UIColor.darkText
            serverAdd_label.textColor = UIColor.lightGray
            connect_ip_label.textColor = UIColor.darkText
        } else {
            network_mode_subtitle?.text = "Remote Full full-node"
            certificate_cell.isUserInteractionEnabled = true
            server_cell.isUserInteractionEnabled = true
            connectPeer_cell.isUserInteractionEnabled = false
            connect_peer_ip.textColor = UIColor.lightGray
            certificat_label.textColor = UIColor.darkText
            server_ip.textColor = UIColor.darkText
            serverAdd_label.textColor = UIColor.darkText
            connect_ip_label.textColor = UIColor.lightGray
        }
        
        [certificat_label, server_ip, serverAdd_label].forEach { lbl in
            lbl?.changeSkin()
        }
    }

    @objc func cancel() {
        if isFromLoader == true {
            navigationController?.navigationBar.isHidden = true
            navigationController?.popViewController(animated: true)
        } else {
            delegate?.changeViewController(LeftMenu.overview)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard let vc = (self.slideMenuController()?.mainViewController as? UINavigationController)?.topViewController else {
                return
            }
            if vc.isKind(of: SettingsController.self) {
                self.slideMenuController()?.removeLeftGestures()
                self.slideMenuController()?.removeRightGestures()
            }
        })
    }

    func loadDate() {
        let network_value = UserDefaults.standard.integer(forKey: "network_mode")
        version?.text = UserDefaults.standard.string(forKey: "app_version") ?? "1.0"
        build?.text = UserDefaults.standard.string(forKey: "build_version") ?? "1.0"
        debu_msg?.setOn((UserDefaults.standard.bool(forKey: "pref_debug_switch")), animated: true)
        spend_uncon_fund?.setOn(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch"), animated: true)
        connect_peer_ip?.text = UserDefaults.standard.string(forKey: "pref_peer_ip") ?? "0.0.0.0"
        server_ip?.text = UserDefaults.standard.string(forKey: "pref_server_ip") ?? "0.0.0.0"
        incoming_notification_switch?.setOn(UserDefaults.standard.bool(forKey: "pref_notification_switch"), animated: true)

        if network_value == 0 {
            network_mode_subtitle?.text = "Simplified Payment Verification (SPV)"
        } else if network_value == 1 {
            network_mode_subtitle?.text = "Local Full full-node"
        } else {
            network_mode_subtitle?.text = "Remote Full full-node"
        }
    }

    @objc func save() {
        UserDefaults.standard.set(incoming_notification_switch.isOn, forKey: "pref_notification_switch")
        UserDefaults.standard.set(spend_uncon_fund.isOn, forKey: "pref_spend_fund_switch")
        UserDefaults.standard.set(debu_msg.isOn, forKey: "pref_debug_switch")
        UserDefaults.standard.set(testnet_switch.isOn, forKey: "pref_use_testnet")
        UserDefaults.standard.synchronize()
        AppContext.instance.decrdConnection?.applySettings()
        if isFromLoader == true {
            navigationController?.navigationBar.isHidden = true
            navigationController?.popViewController(animated: true)
        } else {
            delegate?.changeViewController(LeftMenu.overview)
        }
    }

    /*  @IBAction func didTouchToMain(_ sender: UIButton) {
     delegate?.changeViewController(LeftMenu.overview)
     }*/
}
