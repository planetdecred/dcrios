//
//  WalletSetupViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class WalletSetupViewController : UIViewController {
    
    @IBOutlet weak var build: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var compileDate:Date{
            let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
            if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
                let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
                let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
            { return infoDate }
            return Date()
        }
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        build?.text = "Build Date: " + dateformater.string(from: compileDate as Date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btn_create_wallet(_ sender: Any) {}
    
    @IBAction func backToMenu(_:UIStoryboardSegue){}
    
}
