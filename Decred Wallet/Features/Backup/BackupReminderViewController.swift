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
    @IBOutlet weak var labelSeedIsImportant: UILabel!
    @IBOutlet weak var labelSeedPhraseisTheOnlyWay: UILabel!
    @IBOutlet weak var labelStoreItInAPhysicalFormat: UILabel!
    @IBOutlet weak var labelDoNotStoreItInAnyDigitalFormat: UILabel!
    @IBOutlet weak var labelDoNotShowYourSeed: UILabel!
    var checkedCheckBoxesDict: [Int: Bool] = [:]
    @IBOutlet weak var viewSeedBtn: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSeedBtn.isEnabled = false
        addNavigationBackButton()
        addStyleToLabels()
    }
    
    private func addStyleToLabels() {
        let normal = Style {
            $0.font = UIFont(name: "SourceSansPro-Regular", size: 16)
            $0.color = UIColor.appColors.grayishBlue
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
            $0.color = UIColor.appColors.decredGreen
        }
        
        let myGroup = StyleGroup(base: normal, [ "bold": bold, "orange": orange, "green": green ])
        
        for label in [self.labelSeedIsImportant, self.labelSeedPhraseisTheOnlyWay, self.labelStoreItInAPhysicalFormat, self.labelDoNotStoreItInAnyDigitalFormat, self.labelDoNotShowYourSeed] {
            label?.attributedText = label?.text?.set(style: myGroup)
        }
    }
    
    @IBAction func onCheck(_ sender: Any) {
        if let checkbox = sender as? Button {
            checkbox.setImage(UIImage(named: "backup_checkbox_checked"), for: .normal)
            checkbox.borderWidth = 0
            self.checkedCheckBoxesDict[checkbox.tag] = true
            
            var allChecked = true;
            for i in 1...5 {
                allChecked = allChecked && self.checkedCheckBoxesDict[i] == true
            }
            
            if(allChecked) {
                self.viewSeedBtn?.isEnabled = true
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
        navigateToBackScreen()
    }
}
