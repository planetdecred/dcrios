//
//  ConnectedPeerTableViewCell.swift
//  Decred Wallet
//
//  Created by JustinDo on 1/17/21.
//  Copyright © 2021 Decred. All rights reserved.
//

import Foundation
import UIKit

class ConnectedPeerTableViewCell: UITableViewCell {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressLocalLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var subVerLabel: UILabel!
    @IBOutlet weak var startingHeightLabel: UILabel!
    @IBOutlet weak var banScoreLabel: UILabel!
    
    override class func awakeFromNib() {
        
    }
    
    class var peerCellIdentifier: String {
        return "\(self)"
    }
    
    func render(_ peer: PeerInfo) {
        self.idLabel.text = "ID: \(peer.id)"
        self.addressLabel.text = "Addr: \(peer.addr)"
        self.addressLocalLabel.text = "Addr Local: \(peer.addrLocal)"
        self.serviceLabel.text = "Services: \(peer.services)"
        self.versionLabel.text = "Version: \(peer.version)"
        self.subVerLabel.text = "SubVer: \(peer.subVer)"
        self.startingHeightLabel.text = "Starting height: \(peer.startingHeight)"
        self.banScoreLabel.text = "Ban score: \(peer.banScore)"
    }
    
}
