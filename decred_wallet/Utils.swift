//
//  Utils.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD
import SlideMenuControllerSwift

struct Utils {
    static func runInMainThread(_ run: @escaping () -> Void) {
        DispatchQueue.main.async {
            run()
        }
    }
    
    static func createMainWindow() {
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "OverviewViewController") as! OverviewViewController
        let leftViewController = LeftViewController.instantiate()
        
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        
        UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor
        
        leftViewController.mainViewController = nvc
        
        let slideMenuController = SlideMenuController(mainViewController:nvc, leftMenuViewController: leftViewController)
        slideMenuController.changeLeftViewWidth((UIApplication.shared.keyWindow?.frame.size.width)! - (UIApplication.shared.keyWindow?.frame.size.width)! / 6)
        
        slideMenuController.delegate = mainViewController
        UIApplication.shared.keyWindow?.backgroundColor = GlobalConstants.Colors.lightGrey
        UIApplication.shared.keyWindow?.rootViewController = slideMenuController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    static func showProgressHud(with title:String?) -> JGProgressHUD{
        let hud = JGProgressHUD(style: .light)
        hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
        hud.textLabel.text = title ?? ""
        hud.show(in: (UIApplication.shared.keyWindow?.rootViewController?.view)!)
        return hud
    }
    
    static func getPeerAddress(appInstance:UserDefaults) -> String{
        let ip = appInstance.string(forKey: "pref_peer_ip") ?? ""
        if(ip.elementsEqual("")){
            return ""
        }
        else{
            return (ip.appending(":19108"))
        }
    }
    
    static func getTime( millis : Int64) -> String {
        var seconds = millis / 1000;
        if (seconds > 60) {
            let minutes = seconds / 60;
            seconds = seconds % 60;
            return "\(minutes) m \(seconds)s"
        }
        
        return "\(seconds)s"
    }
    
    static func calculateDays(seconds: Int64) -> String{
        let duration = seconds // 2 minutes, 30 seconds
        let formattedDuration  = duration/86400
        if (formattedDuration == 0) {
            return "< 1 day"
        } else if (formattedDuration == 1) {
            return "1 day";
        }
        
        return "\(String(describing: formattedDuration)) days";
    }
    
    static func getSyncTimeRemaining(millis: Int64,percentageCompleted : Int, syncView : Bool)-> String {
        print("milli seconds = \(millis)")
        if (millis > 1000) {
            let seconds = millis / 1000;
            
            if (seconds > 60) {
                let minutes = seconds / 60;
                if (syncView) {
                    return   "\(percentageCompleted)% completed, \(minutes) min remaining."
                }
                return "\(percentageCompleted)% completed, \(minutes) min left"
            }
            
            if (syncView) {
                return "\(percentageCompleted)% completed, \(seconds) sec remaining."
            }
            return "\(percentageCompleted)% completed, \(seconds) sec left."
        }
        
        if (syncView) {
            return " \(percentageCompleted)% completed, < 1 seconds remaining."
        }
        return " \(percentageCompleted)% completed, < 1 seconds left."
        
    }
    
    static func spendable(account:AccountsEntity) -> Decimal{
        let bRequireConfirm = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
        let iRequireConfirm = (bRequireConfirm ) ? Int32(0) : Int32(2)
        let int64Pointer = UnsafeMutablePointer<Int64>.allocate(capacity: 64)
        do {
            
            try  SingleInstance.shared.wallet?.spendable(forAccount: account.Number, requiredConfirmations: iRequireConfirm, ret0_: int64Pointer)
        } catch let error{
            print(error)
            return 0.0
        }
        print("spendable =")
        print(Decimal(int64Pointer.move()))
        return Decimal(int64Pointer.move()) / 100000000.0
    }
    
    static func loadCertificate() throws ->  String {
        let filePath = NSHomeDirectory() + "/Documents/rpc.cert"
        return try String.init(contentsOfFile: filePath)
    }
    
    static func saveCertificate(secretKey: String) {
        do {
            let filePath = NSHomeDirectory() + "/Documents/rpc.cert"
            let filePathURL = URL.init(fileURLWithPath: filePath)
            try secretKey.write(to: filePathURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            debugPrint("Could not create certificate file")
        }
    }
    
    static func getAttributedString(str: String, siz: CGFloat, TexthexColor: UIColor) -> NSAttributedString {
        var tmpString = str
        if tmpString.contains("."){
            var stt = tmpString as NSString?
            let sttbTmp = stt
            var atrStr = NSMutableAttributedString(string: stt! as String)
            var dotRange = sttbTmp?.range(of: ".")
            if ((dotRange!.location) > 3){
                let  tmpstt = Int((sttbTmp!.substring(to: (dotRange!.location))))
                let newValue = tmpstt!.formattedWithSeparator
                stt = newValue.appending(sttbTmp!.substring(from: (dotRange!.location))) as NSString?
                tmpString = newValue.appending(sttbTmp!.substring(from: (dotRange!.location)))
                atrStr = NSMutableAttributedString(string: stt! as String)
                dotRange = stt?.range(of: ".")
                
            }
            
            if (tmpString.length - ((dotRange?.location)!) <= 3) {
                return NSMutableAttributedString(string: tmpString.appending(" DCR") as String)
            }
            else if(tmpString.length > ((dotRange?.location)!+2)) {
                atrStr.append(NSMutableAttributedString(string: " DCR"))
                stt = (stt?.appending(((" DCR")))) as NSString?
                atrStr.addAttribute(NSAttributedString.Key.font,
                                    value: UIFont(name: "Inconsolata-Regular", size: siz)!,
                                    range: NSRange(location:(dotRange?.location)!+3, length:(stt?.length)!-1 - ((dotRange?.location)!+2)))
                
                atrStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                    value: TexthexColor,
                                    range: NSRange(location:0, length:(stt?.length)!))
            }
            
            return atrStr
        }
        
        if (tmpString.length > 3) {
            return NSMutableAttributedString(string: Int(tmpString)!.formattedWithSeparator.appending(" DCR") )
        }
        
        return NSMutableAttributedString(string: tmpString.appending(" DCR") as String)
    }
    
    static func infoForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
}
