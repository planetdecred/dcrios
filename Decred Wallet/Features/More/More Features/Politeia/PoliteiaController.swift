//
//  PoliteiaController.swift
//  Decred Wallet
//
// Copyright © 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

class PoliteiaController: UIViewController {
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var filterCategoryMenu: DropMenuButton!
    @IBOutlet weak var politeiaTableView: UITableView!
    @IBOutlet weak var sortOrderMenu: DropMenuButton!
    @IBOutlet weak var syncingView: LoadingView!
    
    private var refreshControl: UIRefreshControl!
    var politeiasList = [Politeia]()
    let limit: Int32 = 20
    var offset: Int32 = 0
    var isLoading: Bool = false
    var isMore: Bool = true
    let sortOrder: [Bool] = [true, false]
    
    var noTxsLabel: UILabel {
        let noTxsLabel = UILabel(frame: self.politeiaTableView.frame)
        noTxsLabel.text = LocalizedStrings.noPoliteia
        noTxsLabel.font = UIFont(name: "Source Sans Pro", size: 16)
        noTxsLabel.textColor = UIColor.appColors.lightBluishGray
        noTxsLabel.textAlignment = .center
        return noTxsLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getProposalsPoliteia()
        self.setupView()
        self.setupArrayFilter()
        self.setupSortOrderDropDown()
    }
    
    func setupView() {
        self.politeiaTableView.autoResizeCell(estimatedHeight: 140)
        self.politeiaTableView.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self,
                                      action: #selector(self.reloadCurrentPoliteia),
                                      for: UIControl.Event.valueChanged)

        self.politeiaTableView.addSubview(self.refreshControl)
        self.footerView.isHidden = true
        self.startListeningForNotifications()
        self.updateSyncingStatus()
    }
    
    func startListeningForNotifications() {
        try? WalletLoader.shared.multiWallet.politeia?.add(self, uniqueIdentifier: "\(self)")
    }
    
    func setupArrayFilter() {
        guard let politeia = WalletLoader.shared.multiWallet.politeia else {
            print("PoliteiaController.setupFilter get politeia instance false")
            return
        }
        var filterOptions: [String] = []
        DispatchQueue.global(qos: .userInitiated).async {
            filterOptions.append(politeia.categoryCount(category: .pre))
            filterOptions.append(politeia.categoryCount(category: .active))
            filterOptions.append(politeia.categoryCount(category: .approved))
            filterOptions.append(politeia.categoryCount(category: .rejected))
            filterOptions.append(politeia.categoryCount(category: .abandoned))
            DispatchQueue.main.async {
                self.filterCategoryMenu.initMenu(filterOptions) { [weak self] index, value in
                    self?.reloadPoliteiaWithFilter()
                }
            }
        }
    }
    
    func updateSyncingStatus() {
        DispatchQueue.main.async {
            let isSync = WalletLoader.shared.multiWallet.politeia!.isSyncing()
            self.syncingView.isHidden = !isSync
        }
    }
    
    func setupSortOrderDropDown() {
        let sortOptions = [ LocalizedStrings.newest, LocalizedStrings.oldest ]
        self.sortOrderMenu.initMenu(sortOptions) { [weak self] index, value in
            self?.reloadPoliteiaWithFilter()
        }
    }
    
    func reloadPoliteiaWithFilter() {
        self.offset = 0
        self.isMore = true
        self.getProposalsPoliteia()
    }
    
    @objc func reloadCurrentPoliteia() {
        self.reloadPoliteiaWithFilter()
    }
    
    func getProposalsPoliteia() {
        let selectedCategory = self.filterCategoryMenu.selectedItemIndex + 2
        let category = PoliteiaCategory(rawValue: Int32(selectedCategory)) ?? .pre
        let selectedSortIndex = self.sortOrderMenu.selectedItemIndex
        let sortOrder = self.sortOrder[safe: selectedSortIndex] ?? true
        
        if self.isLoading || !self.isMore { return }
        self.isLoading = true
        if self.offset > 0 {
            self.footerView.isHidden = false
        }
        DispatchQueue.global(qos: .userInitiated).async {
            if let politeias = WalletLoader.shared.multiWallet.politeia?.getPoliteias(category: category, offset: self.offset, newestFirst: sortOrder) {
                self.isMore = politeias.count >= 20
                if self.offset > 0 {
                    self.politeiasList.append(contentsOf: politeias)
                } else {
                    self.politeiasList.removeAll()
                    self.politeiasList = politeias
                }
                self.offset += 20
            }
            self.isLoading = false
            DispatchQueue.main.async {
                self.politeiaTableView.backgroundView = self.politeiasList.count == 0 ? self.noTxsLabel : nil
                self.refreshControl.endRefreshing()
                self.politeiaTableView.reloadData()
                self.footerView.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
        
        let icon = self.navigationController?.modalPresentationStyle == .fullScreen ?  UIImage(named: "ic_close") : UIImage(named: "left-arrow")
        let closeButton = UIBarButtonItem(image: icon,
                                          style: .done,
                                          target: self,
                                          action: #selector(self.dismissView))
        
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.politeia, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.appColors.darkBlue
        
        self.navigationItem.leftBarButtonItems =  [closeButton, barButtonTitle]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        WalletLoader.shared.multiWallet.politeia?.removeNotificationListener("\(self)")
        
    }
}

extension PoliteiaController: UITableViewDelegate, UITableViewDataSource {
    
    func navigatePoliteiaDetail(politeia: Politeia) {
        let storyboard = UIStoryboard(name: "Politeia", bundle: nil)
        if let politeiaVC = storyboard.instantiateViewController(withIdentifier: "PoliteiaDetailController") as? PoliteiaDetailController {
            politeiaVC.politeia = politeia
            navigationController?.pushViewController(politeiaVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.politeiasList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let politeiaCell = self.politeiaTableView.dequeueReusableCell(withIdentifier: PoliteiaTableViewCell.politeiaIdentifier) as! PoliteiaTableViewCell
        let politeiaItem = self.politeiasList[indexPath.row]
        politeiaCell.displayInfo(politeiaItem)
        if indexPath.row == self.politeiasList.count - 1 && self.isMore {
            self.getProposalsPoliteia()
        }
        return politeiaCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigatePoliteiaDetail(politeia: self.politeiasList[indexPath.row])
    }
    
}

extension PoliteiaController: DcrlibwalletProposalNotificationListenerProtocol {
    
    func onNewProposal(_ proposal: DcrlibwalletProposal?) {
    }
    
    func onProposalVoteFinished(_ proposal: DcrlibwalletProposal?) {
    }
    
    func onProposalVoteStarted(_ proposal: DcrlibwalletProposal?) {
    }
    
    func onProposalsSynced() {
        self.updateSyncingStatus()
        self.reloadPoliteiaWithFilter()
    }
}

