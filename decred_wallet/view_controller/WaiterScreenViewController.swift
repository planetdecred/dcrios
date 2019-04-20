//
//  WaiterScreenViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

protocol WaiterScreenProtocol {
    func set(label:String)
    func set(duration:Double)
    func stopAnimation()
    var onFinish:(()->Void)?{get set}
    var onTapAnimation:(()->Void)?{get set}
}


class WaiterScreenViewController: UIViewController, WaiterScreenProtocol {
    
    var onTapAnimation: (() -> Void)?
    var onFinish:(()->Void)?
    
    var timer: Timer?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var testnetLabel: UILabel!
    
    var  groupAnimation: CAAnimationGroup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isTestnet = Bool(infoForKey(GlobalConstants.Strings.IS_TESTNET)!)!
        if(isTestnet) {
            testnetLabel.isHidden = false
            testnetLabel.text = "testnet"
        }
        setScreenFont()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        logo.loadGif(name: "splashLogo")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        set(duration: 5)
        
        if isWalletCreated(){
            set(label: "Opening wallet...")
        }
        
    }
    
    func set(label: String) {
        
        self.label.text = label
    }
    func setScreenFont(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                setFontSize(testnetTxt: 14, labelTxt: 15)
                print("iPhone 5 or 5S or 5C")
                break
            case 1334:
                setFontSize(testnetTxt: 17, labelTxt: 18)
                print("iPhone 6/6S/7/8")
                break
            case 2208:
                setFontSize(testnetTxt: 18, labelTxt: 19)
                print("iPhone 6+/6S+/7+/8+")
                break
            case 2436:
                setFontSize(testnetTxt: 18, labelTxt: 19)
                print("iPhone X")
            default:
                print("unknown")
            }
        }
        else if UIDevice().userInterfaceIdiom == .pad{
            switch UIScreen.main.nativeBounds.height {
            case 2048:
                // iPad Pro (9.7-inch)/ iPad Air 2/ iPad Mini 4
                setFontSize(testnetTxt: 24, labelTxt: 26)
                print("ipad air")
                break
            case 2224:
                //iPad Pro 10.5-inch
                setFontSize(testnetTxt: 26, labelTxt: 28)
                print("ipad air 10inch")
                break
            case 2732:
                //iPad Pro 12.9-inch
                setFontSize(testnetTxt: 34, labelTxt: 36)
                break
            default:break
            }
           
        }
    }
    func setFontSize(testnetTxt: CGFloat ,labelTxt : CGFloat ){
        testnetLabel.font = testnetLabel.font.withSize(testnetTxt)
        label.font = label.font.withSize(labelTxt)
    }
    
    func set(duration: Double) {
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: {_ in
            self.stopAnimation()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToSeetings(_ sender: Any) {
        timer?.invalidate()
        onTapAnimation?()
    }
    
    func stopAnimation() {
        onFinish?()
    }
}
