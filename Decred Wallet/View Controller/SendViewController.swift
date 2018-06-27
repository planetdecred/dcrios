//
//  SendViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import UIKit

class SendViewController: UIViewController {

    @IBOutlet weak var accountDropdown: DropMenuButton!
    @IBOutlet weak var totalAmountSending: UILabel!
    @IBOutlet weak var estimateFee: UILabel!
    @IBOutlet weak var estimateSize: UILabel!
    @IBOutlet weak var walletAddress: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.accountDropdown.backgroundColor = UIColor.clear
        accountDropdown.initMenu(["My Wallet [153.0055 DCR]", "My Wallet2 [153.0055 DCR]", "My Wallet3 [153.0055 DCR]"], actions: ({ (ind, val) -> (Void) in

            self.accountDropdown.setAttributedTitle(self.getAttributedString(str: val), for: UIControlState.normal)

            self.accountDropdown.backgroundColor = UIColor(red: 173.0/255.0, green: 231.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        }))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
         self.navigationItem.title = "Send"
    }

    func getAttributedString(str: String) -> NSAttributedString {

        let stt = str as NSString!
        let atrStr = NSMutableAttributedString(string: stt! as String)
        let dotRange = stt?.range(of: "[")
        //print("Index = \(dotRange?.location)")
        if(str.length > 0) {
            atrStr.addAttribute(NSAttributedStringKey.font,
                                value: UIFont(
                                    name: "Helvetica-bold",
                                    size: 15.0)!,
                                range: NSRange(
                                    location:0,
                                    length:(dotRange?.location)!))

            atrStr.addAttribute(NSAttributedStringKey.font,
                                value: UIFont(
                                    name: "Helvetica",
                                    size: 15.0)!,
                                range: NSRange(
                                    location:(dotRange?.location)!,
                                    length:(str.length - (dotRange?.location)!)))

            atrStr.addAttribute(NSAttributedStringKey.foregroundColor,
                                value: UIColor.darkGray,
                                range: NSRange(
                                    location:0,
                                    length:str.length))

        }
        return atrStr
    }

    @IBAction func accountDropdown(_ sender: Any) {
    }

    @IBAction private func sendFund(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let confirmSendFundViewController = storyboard.instantiateViewController(withIdentifier: "ConfirmToSendFundViewController") as! ConfirmToSendFundViewController
        confirmSendFundViewController.modalTransitionStyle = .crossDissolve
        confirmSendFundViewController.modalPresentationStyle = .overCurrentContext
        confirmSendFundViewController.amount = 25.869

        confirmSendFundViewController.confirm = { [weak self] in
            guard let `self` = self else { return }
            debugPrint(self)
        }

        self.present(confirmSendFundViewController, animated: true, completion: nil)
    }
}
