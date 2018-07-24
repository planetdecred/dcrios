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
}
