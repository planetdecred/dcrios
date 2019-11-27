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
    @IBOutlet weak var syncInProgressLabel: UILabel!
    var noTxsLabel: UILabel {
        let noTxsLabel = UILabel(frame: self.transactionsTableView.frame)
        noTxsLabel.text = LocalizedStrings.noTransactions
        noTxsLabel.textAlignment = .center
        return noTxsLabel
    }
    
    var refreshControl: UIRefreshControl!
    @IBOutlet var transactionsTableView: UITableView!
    @IBOutlet var transactionFilterDropDown: DropMenuButton!
    
    var allTransactions = [Transaction]()
    var transactionFilters = [Int32]()
    var filteredTransactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self,
                                      action: #selector(self.reloadTxsForCurrentFilter),
                                      for: UIControl.Event.valueChanged)
        
        self.transactionsTableView.addSubview(self.refreshControl)
        self.transactionsTableView.register(UINib(nibName: TransactionTableViewCell.identifier, bundle: nil),
                                            forCellReuseIdentifier: TransactionTableViewCell.identifier)
        
        AppDelegate.walletLoader.notification.registerListener(for: "\(self)", newTxistener: self)
        AppDelegate.walletLoader.notification.registerListener(for: "\(self)", confirmedTxListener: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = LocalizedStrings.history

        if AppDelegate.walletLoader.isSynced {
            self.syncInProgressLabel.isHidden = true
            self.transactionsTableView.isHidden = false
            self.loadAllTransactions()
        }
    }
    
    func loadAllTransactions() {
        self.allTransactions.removeAll()
        self.refreshControl.showLoader(in: self.transactionsTableView)
        
        guard let txs = AppDelegate.walletLoader.wallet?.transactionHistory(offset: 0), !txs.isEmpty else {
            self.transactionsTableView.backgroundView = self.noTxsLabel
            self.transactionsTableView.separatorStyle = .none
            self.refreshControl.endRefreshing()
            return
        }
        
        self.allTransactions = txs
        self.transactionsTableView.backgroundView = nil
        self.transactionsTableView.separatorStyle = .singleLine
        self.setupTxFilterAndDisplayAllTxs()
    }
    
    func setupTxFilterAndDisplayAllTxs() {
        var filterOptions = [LocalizedStrings.all.appending(" (\(self.allTransactions.count))")]
        self.transactionFilters = [DcrlibwalletTxFilterAll]
        
        let sentCount = self.allTransactions.filter{$0.direction == DcrlibwalletTxDirectionSent}.count
        if sentCount != 0 {
            filterOptions.append(LocalizedStrings.sent.appending(" (\(sentCount))"))
            self.transactionFilters.append(DcrlibwalletTxFilterSent)
        }
        
        let receiveCount = self.allTransactions.filter{$0.direction == DcrlibwalletTxDirectionReceived}.count
        if receiveCount != 0 {
            filterOptions.append(LocalizedStrings.received.appending(" (\(receiveCount))"))
            self.transactionFilters.append(DcrlibwalletTxFilterReceived)
        }
        
        let yourselfCount = self.allTransactions.filter{$0.direction == DcrlibwalletTxDirectionTransferred}.count
        if yourselfCount != 0 {
            filterOptions.append(LocalizedStrings.yourself.appending(" (\(yourselfCount))"))
            self.transactionFilters.append(DcrlibwalletTxFilterSent)
        }
        
        let stakeCount = self.allTransactions.filter{$0.type != DcrlibwalletTxTypeRegular}.count
        if stakeCount != 0 {
            filterOptions.append(LocalizedStrings.staking.appending(" (\(stakeCount))"))
            self.transactionFilters.append(DcrlibwalletTxFilterStaking)
        }
        
        let coinbaseCount = self.allTransactions.filter{$0.type == DcrlibwalletTxTypeCoinBase}.count
        if coinbaseCount != 0 {
            filterOptions.append(LocalizedStrings.coinbase.appending(" (\(coinbaseCount))"))
            self.transactionFilters.append(DcrlibwalletTxFilterCoinBase)
        }

        self.transactionFilterDropDown.initMenu(filterOptions) { [weak self] index, value in
            self?.applyTxFilter(currentFilter: self!.transactionFilters[index])
        }
        self.transactionFilterDropDown.setSelectedItemIndex(0)
    }
    
    @objc func reloadTxsForCurrentFilter() {
        var currentFilterItem = DcrlibwalletTxFilterAll
        if self.transactionFilterDropDown.selectedItemIndex >= 0 && self.transactionFilters.count > self.transactionFilterDropDown.selectedItemIndex {
            currentFilterItem = self.transactionFilters[self.transactionFilterDropDown.selectedItemIndex]
        }
        self.applyTxFilter(currentFilter: currentFilterItem)
    }
    
    func applyTxFilter(currentFilter: Int32) {
        self.refreshControl.showLoader(in: self.transactionsTableView)
        
        defer {
            self.transactionsTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        
        switch currentFilter {
        case DcrlibwalletTxFilterSent:
            self.filteredTransactions = self.allTransactions.filter{$0.direction == DcrlibwalletTxDirectionSent && $0.type == DcrlibwalletTxTypeRegular}
            break
            
        case DcrlibwalletTxFilterReceived:
            self.filteredTransactions = self.allTransactions.filter{$0.direction == DcrlibwalletTxDirectionReceived && $0.type == DcrlibwalletTxTypeRegular}
            break
            
        case DcrlibwalletTxFilterTransferred:
            self.filteredTransactions = self.allTransactions.filter{$0.direction == DcrlibwalletTxDirectionTransferred && $0.type == DcrlibwalletTxTypeRegular}
            break
            
        case DcrlibwalletTxFilterStaking:
            self.filteredTransactions = self.allTransactions.filter{$0.type == DcrlibwalletTxTypeRevocation || $0.type == DcrlibwalletTxTypeTicketPurchase || $0.type == DcrlibwalletTxTypeVote }
            break
            
        case DcrlibwalletTxFilterCoinBase:
            self.filteredTransactions = self.allTransactions.filter{$0.type == DcrlibwalletTxTypeCoinBase}
            break
            
        default:
            self.filteredTransactions.removeAll()
            break
        }
    }
}

extension TransactionHistoryViewController: NewTransactionNotificationProtocol, ConfirmedTransactionNotificationProtocol {
    func onTransaction(_ transaction: String?) {
        var tx = try! JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        
        if self.allTransactions.contains(where: { $0.hash == tx.hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }
        
        tx.animate = true
        self.allTransactions.insert(tx, at: 0)
        
        // Save hash for this tx as last viewed tx hash.
        Settings.setValue(tx.hash, for: Settings.Keys.LastTxHash)
        
        DispatchQueue.main.async {
            self.reloadTxsForCurrentFilter()
        }
    }
    
    func onTransactionConfirmed(_ hash: String?, height: Int32) {
        // all tx statuses will be updated when table rows are reloaded.
        self.transactionsTableView.reloadData()
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
        let cell = self.transactionsTableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
        if self.filteredTransactions.isEmpty {
            cell.setData(allTransactions[indexPath.row])
            return cell
        }
        cell.setData(filteredTransactions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transactionDetailVC = Storyboards.TransactionDetails.instantiateViewController(for: TransactionDetailsViewController.self)
        
        if self.filteredTransactions.isEmpty {
            transactionDetailVC.transaction = self.allTransactions[indexPath.row]
        } else {
            transactionDetailVC.transaction = self.filteredTransactions[indexPath.row]
        }
        
        self.navigationController?.pushViewController(transactionDetailVC, animated: true)
    }
}
