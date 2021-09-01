//
//  PoliteiaDetailController.swift
//  Decred Wallet
//
// Copyright © 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Down
import Dcrlibwallet

class PoliteiaDetailController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: PaddedLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sinceLabel: UILabel!
    @IBOutlet weak var countCommentLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var yesPercentLabel: UILabel!
    @IBOutlet weak var noPercentLabel: UILabel!
    @IBOutlet weak var percentView: PlainHorizontalProgressBar!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contentLoadingIndicator: UIActivityIndicatorView!
    
    var politeia: Politeia?
    var isNotificationOpen: Bool = false
    var proposalId: String?
    
    private var multiWallet = WalletLoader.shared.multiWallet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        if self.isNotificationOpen {
            self.getDetailPoliteia()
        } else {
            self.displayData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.text1

        let icon = self.navigationController?.modalPresentationStyle == .fullScreen ?  UIImage(named: "ic_close") : UIImage(named: "left-arrow")
        let closeButton = UIBarButtonItem(image: icon,
                                          style: .done,
                                          target: self,
                                          action: #selector(self.dismissView))

        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.politeiaDetail, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.appColors.text1

        self.navigationItem.leftBarButtonItems =  [closeButton, barButtonTitle]
        
        //setup rightBar button
        let openBrowserButton = UIButton(type: .custom)
        openBrowserButton.setImage(UIImage(named: "ic_open_browser"), for: .normal)
        openBrowserButton.addTarget(self, action: #selector(openButtonTapped), for: .touchUpInside)
        openBrowserButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        openBrowserButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        let shareButton = UIButton(type: .custom)
        shareButton.setImage(UIImage(named: "ic_share_black"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        shareButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let stackview = UIStackView.init(arrangedSubviews: [openBrowserButton, shareButton])
        stackview.distribution = .equalSpacing
        stackview.axis = .horizontal
        stackview.alignment = .center
        stackview.spacing = 12
        
        let stackButton:UIBarButtonItem = UIBarButtonItem(customView: stackview)
        self.navigationItem.rightBarButtonItem = stackButton
    }
    
    func getDetailPoliteia() {
        guard let idstr = self.proposalId, let id = Int(idstr) else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            if WalletLoader.shared.isInitialized {
                let result = self.multiWallet.politeia?.detailPoliteia(id)
                DispatchQueue.main.async {
                    if let poli = result!.0 {
                        self.politeia = poli
                        self.displayData()
                    }
                }
            }
        }
    }
    
    func setup() {
        self.statusLabel.layer.cornerRadius = 5
        self.statusLabel.clipsToBounds = true
        let bottomHeight = (self.tabBarController?.tabBar.frame.height ?? 0) + 10
        self.contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: bottomHeight, right: 16)
        self.percentView.isHidden = true
        self.yesPercentLabel.isHidden = true
        self.noPercentLabel.isHidden = true
    }
    
    @objc func shareButtonTapped(_ sender: Any) {
        guard let token = self.politeia?.token, let name = self.politeia?.name else {return}
        guard let urlString = URL(string: "http://proposals.decred.org/record/\(token)") else {return}
        let items: [Any] = [name, urlString]
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activity, animated: true)
    }
    
    @objc func openButtonTapped(_ sender: Any) {
        guard let token = self.politeia?.token else {return}
        let urlString = "http://proposals.decred.org/record/\(token)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func displayData() {
        guard let politeia = self.politeia else {return}
        
        self.titleLabel.text = politeia.name
        self.nameLabel.text = politeia.username
        let publishAge = Int64(Date().timeIntervalSince1970) - politeia.timestamp
        let publishAgeAsTimeAgo = Utils.timeAgo(timeInterval: publishAge)
        self.sinceLabel.text = String(format: publishAgeAsTimeAgo)
        self.countCommentLabel.text = String(format: LocalizedStrings.commentCount, politeia.numcomments)
        self.versionLabel.text = String(format: LocalizedStrings.politeiaVersion, politeia.version)
        self.statusLabel.text = politeia.votestatus.description
        self.statusLabel.backgroundColor = Utils.politeiaColorBGStatus(politeia.votestatus)
        
        if politeia.votestatus == .APPROVED || politeia.votestatus == .REJECT {
            self.percentView.isHidden = false
            self.yesPercentLabel.isHidden = false
            self.noPercentLabel.isHidden = false
            self.percentView.setProgress(Float(politeia.yesPercent), animated: false, isDefaultColor: politeia.novotes == 0)
            let yesPercent = politeia.yesPercent
            self.yesPercentLabel.text = "Yes: \(politeia.yesvotes) (\(yesPercent.round(decimals: 2))%)"
            self.noPercentLabel.text = "No: \(politeia.novotes) (\(politeia.novotes > 0 ? (100 - yesPercent).round(decimals: 2) : 0)%)"
        }
        
        if politeia.indexfile != "" && politeia.fileversion == politeia.version {
            let down = Down(markdownString: politeia.indexfile)
            let attributedString = try? down.toAttributedString()
            self.contentTextView.attributedText = attributedString
        } else {
            self.contentLoadingIndicator.isHidden = false
            DispatchQueue.global(qos: .userInitiated).async {
                var error: NSError?
                let description = self.multiWallet.politeia?.fetchProposalDescription(politeia.token, error: &error)
                DispatchQueue.main.async {
                    self.contentLoadingIndicator.isHidden = true
                    if error != nil {
                        self.contentTextView.text = error?.localizedDescription
                    } else {
                        let down = Down(markdownString: description!)
                        let attributedString = try? down.toAttributedString()
                        self.contentTextView.attributedText = attributedString
                    }
                }
            }
        }
        self.contentTextView.textColor = UIColor.appColors.text1
    }
}
