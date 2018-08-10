//
//  GeneratedSeedDisplayViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit
import Wallet

class GeneratedSeedDisplayViewController: UIViewController {
    @IBOutlet var vWarningLabel: UILabel!
    @IBOutlet private var seedWordLabels: [UILabel]!
    
    @IBOutlet private var outerStackView: UIStackView!
    @IBOutlet var seedContainer: UIView!
    
    var seed: String! = ""
    var arrWords: Array<String> = []
    var yPosition: CGFloat?
    var xPostiion: CGFloat?
    var totalWidth: CGFloat?
    var widthOffset: CGFloat?
    var heightOffset: CGFloat?
    var calcultaedHeight: CGFloat?
    let font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seed = AppContext.instance.decrdConnection?.generateSeed() as String?
        arrWords = (seed?.components(separatedBy: " "))!
        
        drawSeed()
    }
    
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
            seedWordLabels[count].text = "\(count + 1) .\(arrWords[count])"
        }
        
//        outerStackView.topAnchor.constraint(equalTo: seedContainer.topAnchor)
//        outerStackView.bottomAnchor.constraint(equalTo: seedContainer.bottomAnchor)
//        outerStackView.leadingAnchor.constraint(equalTo: seedContainer.leadingAnchor)
//        outerStackView.trailingAnchor.constraint(equalTo: seedContainer.trailingAnchor)
        
        view.setNeedsLayout()
    }
    
    // Get location for new seed word
    func getLocation(stringSize: CGFloat) -> CGRect {
        let pos = xPostiion! + stringSize
        let rect: CGRect
        if pos < totalWidth! {
            rect = CGRect(origin: CGPoint(x: xPostiion!, y: yPosition!), size: CGSize(width: stringSize, height: 21))
            xPostiion = xPostiion! + stringSize + 5
        } else {
            xPostiion = 20.0
            yPosition = yPosition! + 26
            rect = CGRect(origin: CGPoint(x: xPostiion!, y: yPosition!), size: CGSize(width: stringSize, height: 21))
            xPostiion = xPostiion! + stringSize + 5
        }
        return rect
    }
    
    // Get width for new word
    func getWidth(str: String) -> CGSize {
        let maxLabelSize = CGSize(width: 300, height: 30)
        let contentNSString = str as String
        let expectedLabelSize = contentNSString.boundingRect(with: maxLabelSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: self.font], context: nil)
        print("\(expectedLabelSize)")
        return expectedLabelSize.size
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SeedCheckupProtocol
        vc.seedToVerify = seed
    }
}
