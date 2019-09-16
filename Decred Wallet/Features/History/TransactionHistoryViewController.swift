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
        self.setupNavigationBar(withTitle: LocalizedStrings.history)

        if AppDelegate.walletLoader.isSynced {
            self.syncInProgressLabel.isHidden = true
            self.transactionsTableView.isHidden = false
            self.loadAllTransactions()
        }
    }
    
    func loadAllTransactions() {
        self.allTransactions.removeAll()
        self.refreshControl.showLoader(in: self.transactionsTableView)
        
        defer {
            if self.allTransactions.isEmpty {
                self.transactionsTableView.backgroundView = self.noTxsLabel
                self.transactionsTableView.separatorStyle = .none
                self.refreshControl.endRefreshing()
            } else {
                self.transactionsTableView.backgroundView = nil
                self.transactionsTableView.separatorStyle = .singleLine
                self.setupTxFilterAndDisplayAllTxs()
            }
        }
        
        var error: NSError?
        let allTransactionsJson = AppDelegate.walletLoader.wallet?.getTransactions(0, txFilter: DcrlibwalletTxFilterAll, error: &error)
        if error != nil {
            print("wallet.getTransactions error:", error!.localizedDescription)
            return
        }
        
        do {
            self.allTransactions = try JSONDecoder().decode([Transaction].self, from: allTransactionsJson!.data(using: .utf8)!)
        } catch let error {
            print("decode allTransactionsJson error:", error.localizedDescription)
        }
    }
    
    func setupTxFilterAndDisplayAllTxs() {
        var filterOptions = [LocalizedStrings.all.appending(" (\(self.allTransactions.count))")]
        self.transactionFilters = [DcrlibwalletTxFilterAll]
        
        let sentCount = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionSent}.count
        if sentCount != 0 {
            filterOptions.append(LocalizedStrings.sent.appending(" (\(sentCount))"))
            self.transactionFilters.append(DcrlibwalletTxFilterSent)
        }
        
        let receiveCount = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionReceived}.count
        if receiveCount != 0 {
            filterOptions.append(LocalizedStrings.received.appending(" (\(receiveCount))"))
            self.transactionFilters.append(DcrlibwalletTxFilterReceived)
        }
        
        let yourselfCount = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionTransferred}.count
        if yourselfCount != 0 {
            filterOptions.append(LocalizedStrings.yourself.appending(" (\(yourselfCount))"))
            self.transactionFilters.append(DcrlibwalletTxFilterSent)
        }
        
        let stakeCount = self.allTransactions.filter{$0.Type != DcrlibwalletTxTypeRegular}.count
        if stakeCount != 0 {
            filterOptions.append(LocalizedStrings.staking.appending(" (\(stakeCount))"))
            self.transactionFilters.append(DcrlibwalletTxFilterStaking)
        }
        
        let coinbaseCount = self.allTransactions.filter{$0.Type == DcrlibwalletTxTypeCoinBase}.count
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
            self.filteredTransactions = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionSent && $0.Type == DcrlibwalletTxTypeRegular}
            break
            
        case DcrlibwalletTxFilterReceived:
            self.filteredTransactions = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionReceived && $0.Type == DcrlibwalletTxTypeRegular}
            break
            
        case DcrlibwalletTxFilterTransferred:
            self.filteredTransactions = self.allTransactions.filter{$0.Direction == DcrlibwalletTxDirectionTransferred && $0.Type == DcrlibwalletTxTypeRegular}
            break
            
        case DcrlibwalletTxFilterStaking:
            self.filteredTransactions = self.allTransactions.filter{$0.Type == DcrlibwalletTxTypeRevocation || $0.Type == DcrlibwalletTxTypeTicketPurchase || $0.Type == DcrlibwalletTxTypeVote }
            break
            
        case DcrlibwalletTxFilterCoinBase:
            self.filteredTransactions = self.allTransactions.filter{$0.Type == DcrlibwalletTxTypeCoinBase}
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
            // todo: why reloading all transactions because 1 tx was confirmed??
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
        let cell = self.transactionsTableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
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
        
        if self.filteredTransactions.count > 0 {
            transactionDetailVC.transaction = self.filteredTransactions[indexPath.row]
        } else {
            transactionDetailVC.transaction = self.allTransactions[indexPath.row]
        }
        
        self.navigationController?.pushViewController(transactionDetailVC, animated: true)
    }
}
