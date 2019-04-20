//
//  SecurityViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SecurityViewController: UIViewController, SeedCheckupProtocol, StartUpPasswordProtocol {
    
    var senders: String?
    var pass_pinToVerify: String?
    var seedToVerify: String?
    
    var pager: UITabBarController?
    
    @IBOutlet weak var btnPin: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    
    @IBAction func onPasswordTab(_ sender: Any) {
        pager?.selectedIndex = 0
        btnPassword.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        btnPin.backgroundColor = #colorLiteral(red: 0.9449833035, green: 0.9450840354, blue: 0.9490672946, alpha: 1)
    }
    
    @IBAction func onPinTab(_ sender: Any) {
        pager?.selectedIndex = 1
        btnPin.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        btnPassword.backgroundColor = #colorLiteral(red: 0.9449833035, green: 0.9450840354, blue: 0.9490672946, alpha: 1)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setScreenFont()
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPager" {
            if (self.seedToVerify != nil) {
                pager = segue.destination as? UITabBarController
                pager?.tabBar.isHidden = true
                
                var vc1 = pager?.viewControllers?.first as? SeedCheckupProtocol
                var vc2 = pager?.viewControllers?.last as? SeedCheckupProtocol
                vc1?.seedToVerify = seedToVerify
                vc2?.seedToVerify = seedToVerify
            } else {
                
                pager = segue.destination as? UITabBarController
                pager?.tabBar.isHidden = true
                
                var startChecked1 = pager?.viewControllers?.first as? StartUpPasswordProtocol
                var startChecked2 = pager?.viewControllers?.last as? StartUpPasswordProtocol
                startChecked2?.senders = senders
                startChecked1?.senders = senders
                
                if senders == "settingsChangeSpending" || senders == "settingsChangeStartup" {
                    startChecked1?.pass_pinToVerify = pass_pinToVerify
                    startChecked2?.pass_pinToVerify = pass_pinToVerify
                }
            }
        }
    }
    func setScreenFont(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //iPhone 5 or 5S or 5C
                self.setFontSize(PassBtnTxt: 13, PINBtnTxt: 13)
                break
            case 1334:
               // iPhone 6/6S/7/8
                self.setFontSize(PassBtnTxt: 15, PINBtnTxt: 15)
                
                break
            case 2208:
                //iPhone 6+/6S+/7+/8+
                self.setFontSize(PassBtnTxt: 16, PINBtnTxt: 16)
                break
            case 2436:
              // iPhone X
                self.setFontSize(PassBtnTxt: 16, PINBtnTxt: 16)
                break
            default: break
               // print("unknown")
            }
        }
        else if UIDevice().userInterfaceIdiom == .pad{
            switch UIScreen.main.nativeBounds.height {
            case 2048:
                // iPad Pro (9.7-inch)/ iPad Air 2/ iPad Mini 4
                self.setFontSize(PassBtnTxt: 32, PINBtnTxt: 32)
                print("ipad air")
                break
            case 2224:
                //iPad Pro 10.5-inch
                self.setFontSize(PassBtnTxt: 34, PINBtnTxt: 34)
                print("ipad air 10inch")
                break
            case 2732:
                //iPad Pro 12.9-inch
                self.setFontSize(PassBtnTxt: 42, PINBtnTxt: 42)
                break
            default:break
            }
            
        }
    }
    func setFontSize(PassBtnTxt: CGFloat, PINBtnTxt: CGFloat){
        self.btnPassword.titleLabel?.font = .systemFont(ofSize: PassBtnTxt)
         self.btnPin.titleLabel?.font = .systemFont(ofSize: PINBtnTxt)
    }
}
