//
//  DcrdAccountsSupport.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation
import UIKit
import CoreImage

protocol DcrAccountsManagementProtocol : DcrdBaseProtocol{
    func getAccounts() -> GetAccountResponse?
    func nextAccount(name:String, passwd:String, onSuccess:SuccessCallback, onFailure:FailureCallback) -> Bool
    func getCurrentAddress(account: Int32) -> String

    func generateQRCodeFor(with addres: String, forImageViewFrame: CGRect) -> UIImage?

    func rescan()
    var mBlockRescanObserverHub: BlockScanObserverHub?{get set}
    mutating func addObserver(blockScanObserver:MobilewalletBlockScanResponseProtocol)
    func spendable(account:AccountsEntity) -> Double
}

extension DcrAccountsManagementProtocol{
    func getAccounts() -> GetAccountResponse?{
        var account : GetAccountResponse?
        do{
            let strAccount = try AppContext.instance.decrdConnection?.wallet?.getAccounts(0)
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
            result = (try AppContext.instance.decrdConnection?.wallet?.address(forAccount: account))!
        }catch {
            return ""
        }
        return result
    }
    
    func generateQRCodeFor(with addres: String, forImageViewFrame: CGRect) -> UIImage? {
        guard let addrData = addres.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        // Color code and background
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(addrData, forKey: "inputMessage")
        
        /// Foreground color of the output
        let color = CIColor(red: 26/255, green: 29/255, blue: 47/255)
        
        /// Background color of the output
        let backgroundColor = CIColor.clear
        
        colorFilter.setDefaults()
        colorFilter.setValue(filter!.outputImage, forKey: "inputImage")
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")
        
        if let imgQR = colorFilter.outputImage {
            var tempFrame: CGRect? = forImageViewFrame
            
            if tempFrame == nil {
                tempFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
            }
            
            guard let frame = tempFrame else { return nil }
            
            let smallerSide = frame.size.width < frame.size.height ? frame.size.width : frame.size.height
            
            let scale = smallerSide/imgQR.extent.size.width
            let transformedImage = imgQR.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            
            let imageQRCode = UIImage(ciImage: transformedImage)
            
            return imageQRCode
        }
        
        return nil
    }
    func addObserver(blockScanObserver:MobilewalletBlockScanResponseProtocol){
        mBlockRescanObserverHub?.subscribe(forBlockScanNotifications: blockScanObserver)
    }
    
    func rescan(rescanHeight: Int){
        AppContext.instance.decrdConnection?.wallet?.rescan(0, response: mBlockRescanObserverHub)
    }
    
    func spendable(account:AccountsEntity) -> Double{
        let bRequireConfirm = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
        let iRequireConfirm = (bRequireConfirm ?? false) ? Int32(0) : Int32(2)
        let int64Pointer = UnsafeMutablePointer<Int64>.allocate(capacity: 64)
        do {
            try  AppContext.instance.decrdConnection?.wallet?.spendable(forAccount: account.Number, requiredConfirmations: iRequireConfirm, ret0_: int64Pointer)
        } catch let error{
            print(error)
            return 0.0
        }
        return Double(int64Pointer.move() /  100000000)
    }
}

