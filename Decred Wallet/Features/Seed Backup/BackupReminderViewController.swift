//
//  BackupReminderViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import SwiftRichString

class BackupReminderViewController: UIViewController {
    @IBOutlet var backupNoticeLabels: Array<UILabel>?
    var checkedCheckBoxesDict: [Int: Bool] = [:]
    @IBOutlet weak var viewSeedBtn: Button!
    private var savedCheckboxBorderWidth: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addStyleToLabels()
    }
    
    private func addStyleToLabels() {
        let normal = Style {
            $0.font = UIFont(name: "SourceSansPro-Regular", size: 16)
            $0.color = UIColor.appColors.bluishGray
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
        
        if let backupNoticeLabels = self.backupNoticeLabels {
            for label in backupNoticeLabels {
                label.attributedText = label.text?.set(style: myGroup)
            }
        }
    }
    
    @IBAction func onCheck(_ sender: Any) {
        if let checkbox = sender as? Button {
            if let checked = self.checkedCheckBoxesDict[checkbox.tag], checked {
                checkbox.setImage(nil, for: .normal)
                checkbox.borderWidth = self.savedCheckboxBorderWidth
                self.checkedCheckBoxesDict[checkbox.tag] = false
            } else {
                checkbox.setImage(UIImage(named: "backup_checkbox_checked"), for: .normal)
                self.savedCheckboxBorderWidth = checkbox.borderWidth
                checkbox.borderWidth = 0
                self.checkedCheckBoxesDict[checkbox.tag] = true
            }
            
            var allChecked = true
            for i in 1...5 {
                allChecked = allChecked && self.checkedCheckBoxesDict[i] == true
            }            
            self.viewSeedBtn?.isEnabled = allChecked
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigateToBackScreen()
    }
}
