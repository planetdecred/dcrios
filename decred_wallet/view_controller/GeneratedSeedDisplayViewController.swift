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
        
//        outerStackView.topAnchor.constraint(equalTo: seedContainer.topAnchor).isActive = true
//        outerStackView.bottomAnchor.constraint(equalTo: seedContainer.bottomAnchor).isActive = true
//        outerStackView.leadingAnchor.constraint(equalTo: seedContainer.leadingAnchor).isActive = true
//        outerStackView.trailingAnchor.constraint(equalTo: seedContainer.trailingAnchor).isActive = true
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SeedCheckupProtocol
        vc.seedToVerify = seed
    }
}
