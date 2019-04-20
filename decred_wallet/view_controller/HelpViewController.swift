//
//  HelpViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import SafariServices

class HelpViewController: UIViewController,SFSafariViewControllerDelegate {
    
    @IBOutlet weak var helpInfo: UILabel!
    @IBOutlet weak var linkBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setScreenFont()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Help"
    }
    
    @IBAction func openHelpLink(_ sender: Any) {
        self.openLink(urlString: linkBtn.currentTitle!)
    }
    
    func openLink(urlString: String) {
        
        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            viewController.delegate = self as SFSafariViewControllerDelegate
            
            self.present(viewController, animated: true)
        }
    }
    func setScreenFont(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                self.setFontSize(helpInfoTxt: 12, linkBtnTxt: 13)
                print("iPhone 5 or 5S or 5C")
            case 1334:
                self.setFontSize(helpInfoTxt: 14, linkBtnTxt: 15)
                print("iPhone 6/6S/7/8")
            case 2208:
                self.setFontSize(helpInfoTxt: 15, linkBtnTxt: 16)
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                self.setFontSize(helpInfoTxt: 15, linkBtnTxt: 16)
                print("iPhone X")
            default:
                print("unknown")
            }
        }
        else if UIDevice().userInterfaceIdiom == .pad{
            switch UIScreen.main.nativeBounds.height {
            case 2048:
                // iPad Pro (9.7-inch)/ iPad Air 2/ iPad Mini 4
                 self.setFontSize(helpInfoTxt: 26, linkBtnTxt: 22)
                print("ipad air")
                break
            case 2224:
                //iPad Pro 10.5-inch
                 self.setFontSize(helpInfoTxt: 28, linkBtnTxt: 24)
                print("ipad air 10inch")
                break
            case 2732:
                //iPad Pro 12.9-inch
                 self.setFontSize(helpInfoTxt: 36, linkBtnTxt: 32)
                break
            default:break
            }
           
        }
    }
    func setFontSize(helpInfoTxt: CGFloat ,linkBtnTxt : CGFloat){
        helpInfo.font = helpInfo.font.withSize(helpInfoTxt)
        linkBtn.titleLabel?.font = .systemFont(ofSize: linkBtnTxt)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
