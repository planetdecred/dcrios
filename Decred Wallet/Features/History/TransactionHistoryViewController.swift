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
    
    var filterMenu = [LocalizedStrings.all]
    var filters = [0]
      
    var transactions = [Transaction]()
    var filteredItems = [Transaction]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var filterActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initFilterBtn()
        self.tableView.addSubview(self.refreshControl)
        self.tableView.register(UINib(nibName: TransactionTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        
        AppDelegate.walletLoader.notification.registerListener(for: "(\(self)", newTxistener: self)
        AppDelegate.walletLoader.notification.registerListener(for: "(\(self)", confirmedTxListener: self)
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
            print("wallet not synced on history")
            return
        }
        self.refreshControl.showLoader(in: self.tableView)
        loadTransactions()
    }
    
    func initFilterBtn() {
        self.btnFilter.initMenu(self.filterMenu) { [weak self] index, value in
            self?.applyTxFilter(currentFilter: self!.filters[index])
        }
    }
    
    func applyTxFilter(currentFilter: Int) {
        refreshControl.showLoader(in: self.tableView)
        filteredItems.removeAll()
        
        switch currentFilter {
        case 1:
            self.filterActive = true
            self.filteredItems = self.transactions.filter{$0.Direction == 0 && $0.Type == GlobalConstants.Strings.REGULAR}
            self.btnFilter.setTitle(LocalizedStrings.sent.appending("(\(self.filteredItems.count))"), for: .normal)
            break
        case 2:
            self.filterActive = true
            self.filteredItems = self.transactions.filter{$0.Direction == 1 && $0.Type == GlobalConstants.Strings.REGULAR}
            self.btnFilter.setTitle(LocalizedStrings.received.appending("(\(self.filteredItems.count))"), for: .normal)
            break
        case 3:
            self.filterActive = true
            self.filteredItems = self.transactions.filter{$0.Direction == 2 && $0.Type == GlobalConstants.Strings.REGULAR}
            self.btnFilter.setTitle(LocalizedStrings.yourself.appending("(\(self.filteredItems.count))"), for: .normal)
            break
        case 4:
            self.filterActive = true
            self.filteredItems = self.transactions.filter{$0.Type == GlobalConstants.Strings.REVOCATION || $0.Type == GlobalConstants.Strings.TICKET_PURCHASE || $0.Type == GlobalConstants.Strings.VOTE}
            self.btnFilter.setTitle(LocalizedStrings.staking.appending("(\(self.filteredItems.count))"), for: .normal)
            break
        case 5:
            self.filterActive = true
            self.filteredItems = self.transactions.filter{$0.Type == GlobalConstants.Strings.COINBASE}
            self.btnFilter.setTitle("COINBASE (\(self.filteredItems.count))", for: .normal)
            break
        default:
            self.filterActive = false
            self.btnFilter.setTitle(LocalizedStrings.all.appending("(\(self.transactions.count))"), for: .normal)
            break
        }
        self.refreshControl.endRefreshing()
    }
    
    func loadTransactions() {
        self.transactions.removeAll()
        var error: NSError?
        
        let allTransactions = AppDelegate.walletLoader.wallet?.getTransactions(0, txFilter: Int32(0), error: &error)
        if error != nil {
            print(error!.localizedDescription)
        }
        
        if allTransactions == nil || allTransactions!.count == 0 {
            self.showNoTransactions()
            return
        }
        
        self.transactions = try! JSONDecoder().decode([Transaction].self, from: allTransactions!.data(using: .utf8)!)
        
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = .singleLine
        self.refreshControl.endRefreshing()
        self.updateFilterDropdownItems()
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.reloadTxsForCurrentFilter()
    }
    
    func showNoTransactions() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        label.text = LocalizedStrings.noTransactions
        label.textAlignment = .center
        self.refreshControl.endRefreshing()
        self.tableView.backgroundView = label
        self.tableView.separatorStyle = .none
    }
    
    func reloadTxsForCurrentFilter() {
        var currentFilterItem = 0
        if self.btnFilter.selectedItemIndex >= 0 && self.filters.count > self.btnFilter.selectedItemIndex {
            currentFilterItem = self.filters[self.btnFilter.selectedItemIndex]
        }
        self.applyTxFilter(currentFilter: currentFilterItem)
    }
    
    func updateFilterDropdownItems() {
        let sentCount = self.transactions.filter{$0.Direction == 0}.count
        let ReceiveCount = self.transactions.filter{$0.Direction == 1}.count
        let yourselfCount = self.transactions.filter{$0.Direction == 2}.count
        let stakeCount = self.transactions.filter{$0.Type.lowercased() != "Regular".lowercased()}.count
        let coinbaseCount = self.transactions.filter{$0.Type == GlobalConstants.Strings.COINBASE}.count
        
        self.btnFilter.items.removeAll()
        self.btnFilter.setTitle(LocalizedStrings.all.appending("(\(self.transactions.count))"), for: .normal)
        self.btnFilter.items.append(LocalizedStrings.all.appending("(\(self.transactions.count))"))
        
        self.filters.removeAll()
        self.filters.append(0)
        
        if sentCount != 0 {
            self.btnFilter.items.append(LocalizedStrings.sent.appending("(\(sentCount))"))
            self.filters.append(1)
        }
        if ReceiveCount != 0 {
            self.btnFilter.items.append(LocalizedStrings.received.appending("(\(ReceiveCount))"))
            self.filters.append(2)
        }
        if yourselfCount != 0 {
            self.btnFilter.items.append(LocalizedStrings.yourself.appending("(\(yourselfCount))"))
            self.filters.append(3)
        }
        if stakeCount != 0 {
            self.btnFilter.items.append(LocalizedStrings.staking.appending("(\(stakeCount))"))
            self.filters.append(4)
        }
        if coinbaseCount != 0 {
            self.btnFilter.items.append("Coinbase (\(coinbaseCount))")
            self.filters.append(5)
        }
    }
}

extension TransactionHistoryViewController: NewTransactionNotificationProtocol, ConfirmedTransactionNotificationProtocol {
    func onTransaction(_ transaction: String?) {
        var tx = try! JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        
        if self.transactions.contains(where: { $0.Hash == tx.Hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }
        
        tx.Animate = true
        self.transactions.insert(tx, at: 0)
        
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
        return (self.filteredItems.count != 0) ? self.filteredItems.count : self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
        guard filteredItems.count != 0 else {
            cell.setData(transactions[indexPath.row])
            return cell
        }
        cell.setData(filteredItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TransactionFullDetailsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
        
        if filterActive {
            subContentsVC.transaction = self.filteredItems[indexPath.row]
        }else {
            subContentsVC.transaction = self.transactions[indexPath.row]
        }
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
}
