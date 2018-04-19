//
//  Entities.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 18.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import Foundation
import RealmSwift

class WalletEntity : Object {
    @objc dynamic var id = ""
    @objc dynamic var seed = "" 
}

