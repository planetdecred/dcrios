//
//  DcrRpc.swift
//  DcrRPC
//
//  Created by Philipp Maluta on 19.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import Foundation

protocol WalletServiceProtocol {
    func generateSeed() -> String?
    func createWallet(userame login:String, password passwd:String, seed:String, onSuccess:(()->Void)?, onFailure:((_ error:NSError?)->Void)?)
}

public enum DecredRpc {
    
}
