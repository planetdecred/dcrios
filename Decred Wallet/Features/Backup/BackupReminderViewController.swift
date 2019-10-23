//
//  BackupReminderViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import SwiftRichString

class BackupReminderViewController: UIViewController {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    var checkDict: [Int: Bool] = [:]
    @IBOutlet weak var viewSeedBt: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSeedBt.isEnabled = false
        addNavigationBackButton()
        addStyleToLabels()
    }
    
    private func addStyleToLabels(){
        let normal = Style {
            $0.font = UIFont(name: "SourceSansPro-Regular", size: 16)
            $0.color = UIColor.appColors.darkBlue
        }

        let bold = Style {
            $0.font = UIFont(name: "SourceSansPro-bold", size: 16)
            $0.color = normal.color
        }
        
        let orange = Style {
            $0.font = bold.font
            $0.color = UIColor.appColors.decredOrange
        }

        let green = Style {
            $0.font = bold.font
            $0.color = UIColor.appColors.greenLabelColor
        }
        
        let myGroup = StyleGroup(base: normal, [ "bold": bold, "orange": orange, "green": green ] )
        
        for label in [self.label1, self.label2, self.label3, self.label4, self.label5]
        {
            label?.attributedText = label?.text?.set(style: myGroup)
        }
    }
    
    @IBAction func onCheck(_ sender: Any) {
        if let checkbox = sender as? UIButton {
            checkbox.setImage(UIImage(named: "backup_checkbox_checked"), for: .normal)
            self.checkDict[checkbox.tag] = true
            
            var allChecked = true;
            for i in 1...5 {
                allChecked = allChecked && self.checkDict[i] == true
            }
            
            if(allChecked)
            {
                self.viewSeedBt?.isEnabled = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
   
}
