//
//  TransactionHistoryViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class TransactionHistoryViewController: UIViewController {
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(TransactionHistoryViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.lightGray
        
        return refreshControl
    }()
    
    
    @IBOutlet weak var syncLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnFilter: DropMenuButton!
    
    var FromMenu = true
    var visible:Bool = false
    
    var filterMenu = [LocalizedStrings.all] as [String]
    
    var transactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initFilterBtn()
        self.tableView.addSubview(self.refreshControl)
        self.tableView.register(UINib(nibName: TransactionTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TransactionTableViewCell.identifier)

        AppDelegate.walletLoader.notification.registerListener(for: "\(self)", newTxistener: self)
        AppDelegate.walletLoader.notification.registerListener(for: "\(self)", confirmedTxListener: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar(withTitle: LocalizedStrings.history)

        if AppDelegate.walletLoader.isSynced {
            print(" wallet is synced on history")
            self.syncLabel.isHidden = true
            self.tableView.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !AppDelegate.walletLoader.isSynced {
            print(" wallet not synced on history")
            return
        }
        self.visible = true
        if (self.FromMenu){
            refreshControl.showLoader(in: self.tableView)
            loadTransactions()
            FromMenu = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.visible = false
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.loadTransactions()
    }
    
    func loadTransactions(filter: Int? = 0) {
        self.transactions.removeAll()
        var error: NSError?
        let allTransactions = AppDelegate.walletLoader.wallet?.getTransactions(0, txFilter: Int32(filter!), error: &error)
        if error != nil{
            print(error!.localizedDescription)
        }
        
        if allTransactions == nil || allTransactions!.count == 0{
            self.showNoTransactions()
            return
        }
        
        self.transactions = try! JSONDecoder().decode([Transaction].self, from: allTransactions!.data(using: .utf8)!)
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = .singleLine
        self.refreshControl.endRefreshing()
        self.updateFilterDropdownItems()
    }
    
    func showNoTransactions() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        label.text = LocalizedStrings.noTransactions
        label.textAlignment = .center
        self.tableView.backgroundView = label
        self.tableView.separatorStyle = .none
    }
    
    func initFilterBtn() {
        self.btnFilter.initMenu(filterMenu) { [weak self] index, value in
            self?.applyTxFilter(currentFilter: index)
        }
    }
    
    func reloadTxsForCurrentFilter() {
        self.applyTxFilter(currentFilter: self.btnFilter.selectedItemIndex)
    }
    
    func applyTxFilter(currentFilter: Int) {
        refreshControl.showLoader(in: self.tableView)
        self.loadTransactions(filter: currentFilter)
        self.tableView.reloadData()
    }
    
    func updateFilterDropdownItems() {
        let sentCount = self.mainContens.filter{$0.Direction == 0}.count
        let ReceiveCount = self.mainContens.filter{$0.Direction == 1}.count
        let yourselfCount = self.mainContens.filter{$0.Direction == 2}.count
        let stakeCount = self.mainContens.filter{$0.Type.lowercased() != "Regular".lowercased()}.count
        let coinbaseCount = self.mainContens.filter{$0.Type == GlobalConstants.Strings.COINBASE}.count
        
        self.btnFilter.items.removeAll()
        self.btnFilter.items.append(LocalizedStrings.all)
        
        if sentCount != 0 {
            self.btnFilter.items.append(LocalizedStrings.sent.appending("(\(sentCount))"))
        }
        if ReceiveCount != 0 {
            self.btnFilter.items.append(LocalizedStrings.received.appending("(\(ReceiveCount))"))
        }
        if yourselfCount != 0 {
            self.btnFilter.items.append(LocalizedStrings.yourself.appending("(\(yourselfCount))"))
        }
        if stakeCount != 0 {
            self.btnFilter.items.append(LocalizedStrings.staking.appending("(\(stakeCount))"))
        }
        if coinbaseCount != 0 {
            self.btnFilter.items.append("Coinbase (\(coinbaseCount))")
        }
    }
}

extension TransactionHistoryViewController: NewTransactionNotificationProtocol, ConfirmedTransactionNotificationProtocol {
    func onTransaction(_ transaction: String?) {
        var tx = try! JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        
        if self.mainContens.contains(where: { $0.Hash == tx.Hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }
        
        tx.Animate = true
        self.mainContens.insert(tx, at: 0)
        
        // Save hash for this tx as last viewed tx hash.
        Settings.setValue(tx.Hash, for: Settings.Keys.LastTxHash)
        
        DispatchQueue.main.async {
            self.reloadTxsForCurrentFilter()
        }
    }
    
    func onTransactionConfirmed(_ hash: String?, height: Int32) {
        DispatchQueue.main.async {
            self.loadTransactions()
        }
    }
}

extension TransactionHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Filtercontent.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
        if self.Filtercontent.count != 0 {
            let transaction = Filtercontent[indexPath.row]
            cell.setData(transaction)
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.Filtercontent.count > indexPath.row {
            if self.Filtercontent[indexPath.row].Animate {
                cell.blink()
            }
            self.Filtercontent[indexPath.row].Animate = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TransactionFullDetailsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
        if self.Filtercontent.count == 0{
            return
        }
        self.FromMenu = false
        subContentsVC.transaction = self.Filtercontent[indexPath.row]
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
}
