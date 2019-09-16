//
//  TransactionHistoryViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

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
    @IBOutlet var transactionFilterDropDown: DropMenuButton!
    
    var filters: [Int32] = [0]
    
    var allTransactions = [Transaction]()
    var filteredTransactions = [Transaction]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var filterActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionFilterDropDown.initMenu([String]()) { [weak self] index, value in
            self?.applyTxFilter(currentFilter: self!.filters[index])
        }
        
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
            print("wallet not synced on history")
            return
        }
        self.refreshControl.showLoader(in: self.tableView)
        loadAllTransactions()
    }
    
    func loadAllTransactions() {
        self.allTransactions.removeAll()
        var error: NSError?
        
        let allTransactions = AppDelegate.walletLoader.wallet?.getTransactions(0, txFilter: DcrlibwalletTxFilterAll, error: &error)
        if error != nil {
            print(error!.localizedDescription)
        }
        
        if allTransactions == nil || allTransactions!.count == 0 {
            self.showNoTransactions()
            return
        }
        
        self.allTransactions = try! JSONDecoder().decode([Transaction].self, from: allTransactions!.data(using: .utf8)!)
        
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = .singleLine
        self.refreshControl.endRefreshing()
        self.updateFilterDropdownItems()
        self.tableView.reloadData()
    }
    
    func applyTxFilter(currentFilter: Int32) {
        refreshControl.showLoader(in: self.tableView)
        filteredTransactions.removeAll()
        
        self.filterActive = currentFilter != DcrlibwalletTxFilterAll
        
        switch currentFilter {
        case DcrlibwalletTxDirectionSent:
            self.filteredTransactions = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionSent && $0.Type == DcrlibwalletTxTypeRegular}
            self.transactionFilterDropDown.setTitle(LocalizedStrings.sent.appending("(\(self.filteredTransactions.count))"), for: .normal)
            break
        case DcrlibwalletTxDirectionReceived:
            self.filteredTransactions = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionReceived && $0.Type == DcrlibwalletTxTypeRegular}
            self.transactionFilterDropDown.setTitle(LocalizedStrings.received.appending("(\(self.filteredTransactions.count))"), for: .normal)
            break
        case DcrlibwalletTxDirectionTransferred:
            self.filteredTransactions = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionTransferred && $0.Type == DcrlibwalletTxTypeRegular}
            self.transactionFilterDropDown.setTitle(LocalizedStrings.yourself.appending("(\(self.filteredTransactions.count))"), for: .normal)
            break
        case DcrlibwalletTxFilterStaking:
            self.filteredTransactions = self.allTransactions.filter{$0.Type == DcrlibwalletTxTypeRevocation || $0.Type == DcrlibwalletTxTypeTicketPurchase || $0.Type == DcrlibwalletTxTypeVote }
            self.transactionFilterDropDown.setTitle(LocalizedStrings.staking.appending("(\(self.filteredTransactions.count))"), for: .normal)
            break
        case DcrlibwalletTxFilterCoinBase:
            self.filteredTransactions = self.allTransactions.filter{$0.Type == DcrlibwalletTxTypeCoinBase}
            self.transactionFilterDropDown.setTitle("COINBASE (\(self.filteredTransactions.count))", for: .normal)
            break
        default:
            self.transactionFilterDropDown.setTitle(LocalizedStrings.all.appending("(\(self.allTransactions.count))"), for: .normal)
            break
        }
        self.refreshControl.endRefreshing()
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
        var currentFilterItem = DcrlibwalletTxFilterAll
        if self.transactionFilterDropDown.selectedItemIndex >= 0 && self.filters.count > self.transactionFilterDropDown.selectedItemIndex {
            currentFilterItem = self.filters[self.transactionFilterDropDown.selectedItemIndex]
        }
        self.applyTxFilter(currentFilter: currentFilterItem)
    }
    
    func updateFilterDropdownItems() {
        let sentCount = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionSent}.count
        let receiveCount = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionReceived}.count
        let yourselfCount = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionTransferred}.count
        let stakeCount = self.allTransactions.filter{$0.Type != DcrlibwalletTxTypeRegular}.count
        let coinbaseCount = self.allTransactions.filter{$0.Type == DcrlibwalletTxTypeCoinBase}.count
        
        self.transactionFilterDropDown.items.removeAll()
        self.transactionFilterDropDown.setTitle(LocalizedStrings.all.appending("(\(self.allTransactions.count))"), for: .normal)
        self.transactionFilterDropDown.items.append(LocalizedStrings.all.appending("(\(self.allTransactions.count))"))
        
        self.filters.removeAll()
        self.filters.append(DcrlibwalletTxFilterAll)
        
        if sentCount != 0 {
            self.transactionFilterDropDown.items.append(LocalizedStrings.sent.appending("(\(sentCount))"))
            self.filters.append(DcrlibwalletTxFilterSent)
        }
        if receiveCount != 0 {
            self.transactionFilterDropDown.items.append(LocalizedStrings.received.appending("(\(receiveCount))"))
            self.filters.append(DcrlibwalletTxFilterReceived)
        }
        if yourselfCount != 0 {
            self.transactionFilterDropDown.items.append(LocalizedStrings.yourself.appending("(\(yourselfCount))"))
            self.filters.append(DcrlibwalletTxFilterSent)
        }
        if stakeCount != 0 {
            self.transactionFilterDropDown.items.append(LocalizedStrings.staking.appending("(\(stakeCount))"))
            self.filters.append(DcrlibwalletTxFilterStaking)
        }
        if coinbaseCount != 0 {
            self.transactionFilterDropDown.items.append("Coinbase (\(coinbaseCount))")
            self.filters.append(DcrlibwalletTxFilterCoinBase)
        }
    }
}

extension TransactionHistoryViewController: NewTransactionNotificationProtocol, ConfirmedTransactionNotificationProtocol {
    func onTransaction(_ transaction: String?) {
        var tx = try! JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        
        if self.allTransactions.contains(where: { $0.Hash == tx.Hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }
        
        tx.Animate = true
        self.allTransactions.insert(tx, at: 0)
        
        // Save hash for this tx as last viewed tx hash.
        Settings.setValue(tx.Hash, for: Settings.Keys.LastTxHash)
        
        DispatchQueue.main.async {
            self.reloadTxsForCurrentFilter()
        }
    }
    
    func onTransactionConfirmed(_ hash: String?, height: Int32) {
        DispatchQueue.main.async {
            self.loadAllTransactions()
        }
    }
}

extension TransactionHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.filteredTransactions.count > 0) ? self.filteredTransactions.count : self.allTransactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
        if self.filteredTransactions.isEmpty {
            cell.setData(allTransactions[indexPath.row])
            return cell
        }
        cell.setData(filteredTransactions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TransactionFullDetailsViewController", bundle: nil)
        let transactionDetailVC = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
        
        if filterActive {
            transactionDetailVC.transaction = self.filteredTransactions[indexPath.row]
        } else {
            transactionDetailVC.transaction = self.allTransactions[indexPath.row]
        }
        self.navigationController?.pushViewController(transactionDetailVC, animated: true)
    }
}
