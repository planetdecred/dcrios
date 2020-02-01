//
//  CheckableListDialogViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class CheckableListDialogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var optionsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: Button!
    
    private var dialogTitle: String!
    private var options: [String]!
    private var selectedOption: String?
    private var cancelButtonText: String?
    private var okButtonText: String?
    private var callback: ((_ selectedOption: String?) -> Void)?
    
    static func show(sender vc: UIViewController,
                     title: String,
                     options: [String],
                     selectedOption: String? = nil,
                     cancelButtonText: String? = nil,
                     okButtonText: String? = nil,
                     callback: ((_ selectedOption: String?) -> Void)?) {
        
        let dialog = CheckableListDialogViewController.instantiate(from: .CustomDialogs)
        dialog.dialogTitle = title
        dialog.options = options
        dialog.selectedOption = selectedOption
        dialog.cancelButtonText = cancelButtonText
        dialog.okButtonText = okButtonText
        dialog.callback = callback
        
        dialog.modalTransitionStyle = .crossDissolve
        dialog.modalPresentationStyle = .overCurrentContext
        vc.present(dialog, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.dialogTitle
        
        self.optionsTableViewHeightConstraint.constant = min(
            CGFloat(self.options.count) * CheckableListOptionTableViewCell.height(),
            UIScreen.main.bounds.height * 0.33 // max height = 1/3rd of screen height
        )
        
        self.optionsTableView.registerCellNib(CheckableListOptionTableViewCell.self)
        self.optionsTableView.dataSource = self
        self.optionsTableView.delegate = self
        
        self.cancelButton.setTitle(self.cancelButtonText ?? LocalizedStrings.cancel, for: .normal)
        self.okButton.setTitle(self.okButtonText ?? LocalizedStrings.ok, for: .normal)
        self.okButton.isEnabled = self.selectedOption != nil
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismissView()
        self.callback?(nil)
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        self.dismissView()
        self.callback?(self.selectedOption)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CheckableListOptionTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let optionViewCell = tableView.dequeueReusableCell(withIdentifier: "CheckableListOptionTableViewCell") as! CheckableListOptionTableViewCell
        
        let thisOption = self.options[indexPath.row]
        optionViewCell.set(optionTitle: thisOption, isOptionSelected: thisOption == self.selectedOption)
        
        return optionViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOption = self.options[indexPath.row]
        self.okButton.isEnabled = true
        self.optionsTableView.reloadData()
    }
}
