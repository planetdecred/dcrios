//
//  DcrdAccountsSupport.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation

protocol AccountsManagementProtocol {
    func getAccounts()
    func nextAccount(name:String, passwd:String) -> Bool
}
