//
//  ConnectedPeerViewcontroller.swift
//  Decred Wallet
//
//  Created by JustinDo on 1/16/21.
//  Copyright © 2021 Decred. All rights reserved.
//

import Foundation
import UIKit

class ConnectedPeerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var peers = [PeerInfo]()
    private var showSections = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getPeers()
    }
    
    func setupUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func getPeers() {
        guard let peers = WalletLoader.shared.multiWallet.getPeersInfo() else { return }
        self.peers = peers
        self.tableView.reloadData()
    }
    
    @objc
    private func hideSection(sender: UIButton) {
        let section = sender.tag
        
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            
            indexPaths.append(IndexPath(row: 0, section: section))
            
            return indexPaths
        }
        
        if self.showSections.contains(section) {
            self.showSections.remove(section)
            self.tableView.deleteRows(at: indexPathsForSection(), with: .fade)
            sender.setImage(UIImage(named: "ic_expand"), for: .normal)
        } else {
            self.showSections.insert(section)
            self.tableView.insertRows(at: indexPathsForSection(), with: .fade)
            sender.setImage(UIImage(named: "ic_collapse"), for: .normal)
        }
    }
}

extension ConnectedPeerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.peers.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        
        let idLabel = UILabel()
        let addrLabel = UILabel()
        let sectionButton = UIButton()

        idLabel.translatesAutoresizingMaskIntoConstraints = false
        addrLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionButton.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(idLabel)
        headerView.addSubview(addrLabel)
        headerView.addSubview(sectionButton)
        
        idLabel.text = "\(self.peers[section].id)"
        idLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        idLabel.textColor = UIColor.appColors.darkBlue
        
        addrLabel.text = "\(self.peers[section].addr)"
        addrLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        addrLabel.textColor = UIColor.appColors.darkBluishGray

        sectionButton.addTarget(self, action: #selector(self.hideSection(sender:)), for: .touchUpInside)
        sectionButton.tag = section
        sectionButton.leftImage(image: UIImage(named: "ic_expand")!, renderMode: .alwaysOriginal)
        
        NSLayoutConstraint.activate([
            
            idLabel.heightAnchor.constraint(equalToConstant: 21),
            idLabel.leadingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.leadingAnchor, constant: 30),
            idLabel.trailingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.trailingAnchor),
            idLabel.topAnchor.constraint(equalTo: headerView.layoutMarginsGuide.topAnchor),
            
            
            addrLabel.heightAnchor.constraint(equalToConstant: 21),
            addrLabel.leadingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.leadingAnchor, constant: 30),
            addrLabel.trailingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.trailingAnchor),
            addrLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor),
            
            sectionButton.leadingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.leadingAnchor),
            sectionButton.trailingAnchor.constraint(equalTo: headerView.layoutMarginsGuide.trailingAnchor),
            sectionButton.topAnchor.constraint(equalTo: headerView.layoutMarginsGuide.topAnchor),
            sectionButton.bottomAnchor.constraint(equalTo: headerView.layoutMarginsGuide.bottomAnchor),
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showSections.contains(section) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ConnectedPeerTableViewCell.peerCellIdentifier) as! ConnectedPeerTableViewCell
        cell.render(self.peers[indexPath.row])
        return cell
    }
    
    
}
