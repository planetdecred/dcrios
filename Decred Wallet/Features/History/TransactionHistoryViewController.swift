//
//  TransactionHistoryViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

enum TransactionSorterType: String {
    case newest = "NEWEST"
    case oldest = "OLDEST"
}

class TransactionHistoryViewController: UIViewController {
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var syncInProgressLabel: UILabel!
    @IBOutlet var transactionsTableView: UITableView!
    @IBOutlet var transactionFilterDropDown: DropMenuButton!
    @IBOutlet var transactionSorterDropDown: DropMenuButton!

    var noTxsLabel: UILabel {
        let noTxsLabel = UILabel(frame: self.transactionsTableView.frame)
        noTxsLabel.text = LocalizedStrings.noTransactions
        noTxsLabel.font = UIFont(name: "Source Sans Pro", size: 16)
        noTxsLabel.textColor = UIColor.appColors.lightBluishGray
        noTxsLabel.textAlignment = .center
        return noTxsLabel
    }

    var refreshControl: UIRefreshControl!    
    var allTransactions = [Transaction]()
    var transactionFilters = [Int32]()
    var transactionSorters =  [TransactionSorterType]()
    var filteredTransactions = [Transaction]()
    var maximumHeaderTopConstraint: CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self,
                                      action: #selector(self.reloadTxsForCurrentFilter),
                                      for: UIControl.Event.valueChanged)

        self.transactionsTableView.addSubview(self.refreshControl)
        self.transactionsTableView.hideEmptyAndExtraRows()
        self.transactionsTableView.register(UINib(nibName: TransactionTableViewCell.identifier, bundle: nil),
                                            forCellReuseIdentifier: TransactionTableViewCell.identifier)
        // register for new transactions notifications
        try? WalletLoader.shared.multiWallet.add(self, uniqueIdentifier: "\(self)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true

        if SyncManager.shared.isSynced {
            self.syncInProgressLabel.isHidden = true
            self.transactionsTableView.isHidden = false
            self.loadAllTransactions()
        }
    }

    func loadAllTransactions() {
        self.allTransactions.removeAll()
        self.refreshControl.showLoader(in: self.transactionsTableView)
        
        guard let txs = WalletLoader.shared.firstWallet?.transactionHistory(offset: 0), !txs.isEmpty else {
            self.transactionsTableView.backgroundView = self.noTxsLabel
            self.transactionsTableView.separatorStyle = .none
            self.refreshControl.endRefreshing()
            return
        }

        self.allTransactions = txs
        self.setupTxSorter()
        self.transactionsTableView.backgroundView = nil
        self.transactionsTableView.separatorStyle = .singleLine
        self.setupTxFilterAndDisplayAllTxs()
    }

    func setupTxSorter() {
        let sorterOptions = [LocalizedStrings.newest,
                             LocalizedStrings.oldest]
        self.transactionSorters = [TransactionSorterType.newest, TransactionSorterType.oldest]
        self.transactionSorterDropDown.initMenu(sorterOptions) { [weak self] index, value in
            self?.applyTxSorter()
            self?.reloadTxsForCurrentFilter()
        }
    }

    func setupTxFilterAndDisplayAllTxs() {
        var filterOptions = [LocalizedStrings.all]
        self.transactionFilters = [DcrlibwalletTxFilterAll]

        let sentCount = self.allTransactions.filter {$0.direction == DcrlibwalletTxDirectionSent}.count
        if sentCount != 0 {
            filterOptions.append(LocalizedStrings.sent)
            self.transactionFilters.append(DcrlibwalletTxFilterSent)
        }

        let receiveCount = self.allTransactions.filter {$0.direction == DcrlibwalletTxDirectionReceived}.count
        if receiveCount != 0 {
            filterOptions.append(LocalizedStrings.received)
            self.transactionFilters.append(DcrlibwalletTxFilterReceived)
        }

        let yourselfCount = self.allTransactions.filter {$0.direction == DcrlibwalletTxDirectionTransferred}.count
        if yourselfCount != 0 {
            filterOptions.append(LocalizedStrings.yourself)
            self.transactionFilters.append(DcrlibwalletTxFilterSent)
        }

        let stakeCount = self.allTransactions.filter {$0.type != DcrlibwalletTxTypeRegular}.count
        if stakeCount != 0 {
            filterOptions.append(LocalizedStrings.staking)
            self.transactionFilters.append(DcrlibwalletTxFilterStaking)
        }

        let coinbaseCount = self.allTransactions.filter {$0.type == DcrlibwalletTxTypeCoinBase}.count
        if coinbaseCount != 0 {
            filterOptions.append(LocalizedStrings.coinbase)
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
            self.filteredTransactions = self.allTransactions.filter {$0.direction == DcrlibwalletTxDirectionSent && $0.type == DcrlibwalletTxTypeRegular}
            break

        case DcrlibwalletTxFilterReceived:
            self.filteredTransactions = self.allTransactions.filter {$0.direction == DcrlibwalletTxDirectionReceived && $0.type == DcrlibwalletTxTypeRegular}
            break

        case DcrlibwalletTxFilterTransferred:
            self.filteredTransactions = self.allTransactions.filter {$0.direction == DcrlibwalletTxDirectionTransferred && $0.type == DcrlibwalletTxTypeRegular}
            break

        case DcrlibwalletTxFilterStaking:
            self.filteredTransactions = self.allTransactions.filter {$0.type == DcrlibwalletTxTypeRevocation || $0.type == DcrlibwalletTxTypeTicketPurchase || $0.type == DcrlibwalletTxTypeVote }
            break

        case DcrlibwalletTxFilterCoinBase:
            self.filteredTransactions = self.allTransactions.filter {$0.type == DcrlibwalletTxTypeCoinBase}
            break

        default:
            self.filteredTransactions.removeAll()
            break
        }
    }

    func applyTxSorter() {
        var currentSorterType = TransactionSorterType.newest
        if self.transactionSorterDropDown.selectedItemIndex >= 0 && self.transactionSorters.count > self.transactionSorterDropDown.selectedItemIndex {
            currentSorterType = self.transactionSorters[self.transactionSorterDropDown.selectedItemIndex]
        }

        self.allTransactions = currentSorterType == .newest ?  self.allTransactions.sorted {$0.timestamp > $1.timestamp} : self.allTransactions.sorted {$0.timestamp < $1.timestamp}
    }
}

extension TransactionHistoryViewController: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
        // not relevant to this VC
    }

    func onTransaction(_ transaction: String?) {
        var tx = try! JSONDecoder().decode(Transaction.self, from: (transaction!.utf8Bits))

        if self.allTransactions.contains(where: { $0.hash == tx.hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }

        tx.animate = true
        self.allTransactions.insert(tx, at: 0)

        // Save hash for this tx as last viewed tx hash.
        Settings.setStringValue(tx.hash, for: DcrlibwalletLastTxHashConfigKey)

        DispatchQueue.main.async {
            self.applyTxSorter()
            self.reloadTxsForCurrentFilter()
        }
    }

    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
        // all tx statuses will be updated when table rows are reloaded.
         DispatchQueue.main.async {
            self.transactionsTableView.reloadData()
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

        var frame = cell.frame
        frame.size.width = self.transactionsTableView.frame.size.width
        cell.frame = frame

        if indexPath.row == 0 {
            cell.setRoundCorners(corners: [.topLeft, .topRight], radius: 14.0)
        } else if indexPath.row == allTransactions.count - 1 {
            cell.setRoundCorners(corners: [.bottomRight, .bottomLeft], radius: 14.0)
        } else {
            cell.setRoundCorners(corners: [.bottomRight, .bottomLeft, .topLeft, .topRight], radius: 0.0)
        }

        if self.filteredTransactions.isEmpty {
            cell.setData(allTransactions[indexPath.row])
            return cell
        }
        cell.setData(filteredTransactions[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transactionDetailVC = TransactionDetailsViewController.instantiate(from: .TransactionDetails)

        if self.filteredTransactions.isEmpty {
            transactionDetailVC.transaction = self.allTransactions[indexPath.row]
        } else {
            transactionDetailVC.transaction = self.filteredTransactions[indexPath.row]
        }
        self.present(transactionDetailVC, animated: true)
    }
}

extension TransactionHistoryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.maximumHeaderTopConstraint == nil {
            self.maximumHeaderTopConstraint = self.headerTopConstraint.constant
        }
        let minimumValue: CGFloat = -1 * (self.maximumHeaderTopConstraint! + self.headerStackView.frame.size.height +
            self.headerBottomConstraint.constant)
        self.headerTopConstraint.constant = min(self.maximumHeaderTopConstraint!, self.maximumHeaderTopConstraint! + max(minimumValue, -scrollView.contentOffset.y))
        self.headerStackView.alpha = headerTopConstraint.constant / self.maximumHeaderTopConstraint!
    }
}
