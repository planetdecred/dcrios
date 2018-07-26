//
//  DcrdAccountsSupport.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation

protocol DcrAccountsManagementProtocol : DcrdBaseProtocol{
    func getAccounts() -> GetAccountResponse?
    func nextAccount(name:String, passwd:String, onSuccess:SuccessCallback, onFailure:FailureCallback) -> Bool
    func getCurrentAddress(account: Int32) -> String
    func rescan()
    var mBlockRescanObserverHub: BlockScanObserverHub?{get set}
    mutating func addObserver(blockScanObserver:WalletBlockScanResponseProtocol)
    func spendable(account:AccountsEntity) -> Double
}

extension DcrAccountsManagementProtocol{
    func getAccounts() -> GetAccountResponse?{
        var account : GetAccountResponse?
        do{
            let strAccount = try wallet?.getAccounts(0)
            account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
        } catch let error{
            print(error)
            return nil
        }
        return account
    }
    
    func nextAccount(name:String, passwd:String, onSuccess:SuccessCallback, onFailure:FailureCallback) -> Bool{
        return false
    }
    
    func getCurrentAddress(account: Int32) -> String {
        var result = ""
        do{
            result = (try wallet?.address(forAccount: account))!
        }catch {
            return ""
        }
        return result
    }
    
    func addObserver(blockScanObserver:WalletBlockScanResponseProtocol){
        mBlockRescanObserverHub?.subscribe(forBlockScanNotifications: blockScanObserver)
    }
    
    func rescan(){
        wallet?.rescan(0, response: mBlockRescanObserverHub)
    }
    
    func spendable(account:AccountsEntity) -> Double{
        let bRequireConfirm = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
        let iRequireConfirm = (bRequireConfirm ?? false) ? Int32(0) : Int32(2)
        let int64Pointer = UnsafeMutablePointer<Int64>.allocate(capacity: 64)
        do {
            try wallet?.spendable(forAccount: account.Number, requiredConfirmations: iRequireConfirm, ret0_: int64Pointer)
        } catch let error{
            print(error)
            return 0.0
        }
        return Double(int64Pointer.move() /  100000000)
    }
}
