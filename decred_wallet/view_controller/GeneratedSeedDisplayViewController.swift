//
//  GeneratedSeedDisplayViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class GeneratedSeedDisplayViewController: UIViewController {
    
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var subHeaderLabel: UILabel!
    @IBOutlet var vWarningLabel: UILabel!
    @IBOutlet private var seedWordLabels: [UILabel]!
    
    @IBOutlet weak var buttonCopied: UIButton!
    @IBOutlet private var outerStackView: UIStackView!
    @IBOutlet var seedContainer: UIView!
    var labelFont : CGFloat = 14
    
    var seed: String! = ""
    var arrWords = Array<String>()
    var yPosition: CGFloat?
    var xPostiion: CGFloat?
    var totalWidth: CGFloat?
    var widthOffset: CGFloat?
    var heightOffset: CGFloat?
    var calcultaedHeight: CGFloat?
    let font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setScreenFont()
        do{
            try
                self.seed =  (SingleInstance.shared.wallet?.generateSeed())
        } catch {
            seed = ""
        }
        arrWords = (seed.components(separatedBy: " "))
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
            guard let this = self else { return }
            
            this.drawSeed()
        }
        
        backButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func unwind(_: UIStoryboardSegue){}
    // MARK: - Utility
    
    func setUpUItraits() {
        totalWidth = seedContainer.frame.size.width
        yPosition = 20.0
        xPostiion = 20.0
        widthOffset = 0.0
        heightOffset = 0.0
        calcultaedHeight = 21.0
    }
    
    // Draw seed
    func drawSeed() {
        for view in seedContainer.subviews {
            view.removeFromSuperview()
        }       
        setUpUItraits()        
        seedContainer.addSubview(outerStackView)
        
        for count in 0 ..< arrWords.count {
            seedWordLabels[count].text = "\(count + 1). \(arrWords[count])"
            seedWordLabels[count].font = seedWordLabels[count].font.withSize(self.labelFont)
        }
        
        outerStackView.frame = seedContainer.frame
        let windowSize = AppDelegate.shared.window?.frame.size ?? CGSize.zero
        outerStackView.frame.size.width = 0.9 * min(windowSize.width, windowSize.height)
        outerStackView.center = seedContainer.center
        outerStackView.center.x = self.view.center.x
        seedContainer.setNeedsLayout()
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SeedCheckupProtocol
        vc.seedToVerify = self.seed
    }
    func setScreenFont(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                self.setFontSize(HeaderTxt: 18, subHeadTxt: 11, waningTxt: 12, buttonCopyTxt: 11)
                self.labelFont = 12
                print("iPhone 5 or 5S or 5C")
            case 1334:
                self.setFontSize(HeaderTxt: 21, subHeadTxt: 14, waningTxt: 14, buttonCopyTxt: 14)
                self.labelFont = 14
                print("iPhone 6/6S/7/8")
            case 2208:
                self.setFontSize(HeaderTxt: 22, subHeadTxt: 15, waningTxt: 15, buttonCopyTxt: 15)
                self.labelFont = 15
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                self.setFontSize(HeaderTxt: 22, subHeadTxt: 15, waningTxt: 15, buttonCopyTxt: 15)
                self.labelFont = 15
                print("iPhone X")
            default:
                print("unknown")
            }
        }
        else if UIDevice().userInterfaceIdiom == .pad{
            switch UIScreen.main.nativeBounds.height {
            case 2048:
                // iPad Pro (9.7-inch)/ iPad Air 2/ iPad Mini 4
                self.setFontSize(HeaderTxt: 40, subHeadTxt: 30, waningTxt: 32, buttonCopyTxt: 28)
                self.labelFont = 26
                print("ipad air")
                break
            case 2224:
                //iPad Pro 10.5-inch
                self.setFontSize(HeaderTxt: 42, subHeadTxt: 32, waningTxt: 34, buttonCopyTxt: 30)
                self.labelFont = 28
                print("ipad air 10inch")
                break
            case 2732:
                //iPad Pro 12.9-inch
            self.setFontSize(HeaderTxt: 50, subHeadTxt: 40, waningTxt: 42, buttonCopyTxt: 38)
            self.labelFont = 36
            break
            default:
                self.setFontSize(HeaderTxt: 42, subHeadTxt: 32, waningTxt: 34, buttonCopyTxt: 30)
                self.labelFont = 28
                break
        }
            
        }
    }
    func setFontSize(HeaderTxt: CGFloat, subHeadTxt: CGFloat,waningTxt : CGFloat,buttonCopyTxt: CGFloat){
        self.HeaderLabel.font = HeaderLabel.font.withSize(HeaderTxt)
        self.subHeaderLabel.font = subHeaderLabel.font.withSize(subHeadTxt)
        self.vWarningLabel.font = vWarningLabel.font.withSize(waningTxt)
        self.buttonCopied.titleLabel?.font = .systemFont(ofSize: buttonCopyTxt)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
