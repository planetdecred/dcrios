//
//  Utils.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

extension Notification.Name {
    static let NeedAuth =   Notification.Name("NeedAuthorize")
    static let NeedLogout = Notification.Name("NeedDeauthorize")
}

func isWalletCreated() -> Bool{
        let fm = FileManager()
          let result = fm.fileExists(atPath: NSHomeDirectory()+"/Documents/dcrwallet/testnet3/wallet.db")
            return result
}

func createMainWindow(){
    // create viewController code...
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let mainViewController = storyboard.instantiateViewController(withIdentifier: "OverviewViewController") as! OverviewViewController
    let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
    let rightViewController = storyboard.instantiateViewController(withIdentifier: "RightViewController") as! RightViewController
    
    let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
    
    UINavigationBar.appearance().tintColor = GlobalConstants.Colors.navigationBarColor
    
    leftViewController.mainViewController = nvc
    
    let slideMenuController = ExSlideMenuController(mainViewController:nvc, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)
    
    slideMenuController.delegate = mainViewController
    UIApplication.shared.keyWindow?.backgroundColor = GlobalConstants.Colors.lightGrey
    UIApplication.shared.keyWindow?.rootViewController = slideMenuController
    UIApplication.shared.keyWindow?.makeKeyAndVisible()
}

func saveCertificate(secretKey: String) {
    do {
        let filePath = NSHomeDirectory() + "/Documents/rpc.cert"
        let filePathURL = URL.init(fileURLWithPath: filePath)
        try secretKey.write(to: filePathURL, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        debugPrint("Could not create certificate file")
    }
}
func getPeerAddress(appInstance:UserDefaults)-> String{
    let ip = appInstance.string(forKey: "pref_peer_ip")
    if(ip?.elementsEqual("0.0.0.0"))!{
        return ""
    }
    else{
        return (ip?.appending(":19108"))!
    }
    
}
func loadCertificate() throws ->  String {
    let filePath = NSHomeDirectory() + "/Documents/rpc.cert"
    return try String.init(contentsOfFile: filePath)
}
