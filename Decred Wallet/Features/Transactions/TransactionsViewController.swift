//
//  TransactionsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class TransactionsViewController: UIViewController {
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet var txTableView: UITableView!
    @IBOutlet var txFilterDropDown: DropMenuButton!
    @IBOutlet var txSortOrderDropDown: DropMenuButton!

    var noTxsLabel: UILabel {
        let noTxsLabel = UILabel(frame: self.txTableView.frame)
        noTxsLabel.text = LocalizedStrings.noTransactions
        noTxsLabel.font = UIFont(name: "Source Sans Pro", size: 16)
        noTxsLabel.textColor = UIColor.appColors.lightBluishGray
        noTxsLabel.textAlignment = .center
        return noTxsLabel
    }

    var refreshControl: UIRefreshControl!
    var allTransactions = [Transaction]()
    var txFilters = [Int32]()
    let txSorters: [Bool] = [true, false]
    var filteredTransactions = [Transaction]()
    var maximumHeaderTopConstraint: CGFloat?

    let countTransactionsFor: (Int32) -> Int = { txFilter in
        let intPointer = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        defer {
            intPointer.deallocate()
        }

        do {
            try WalletLoader.shared.firstWallet?.countTransactions(txFilter, ret0_: intPointer)
        } catch let error {
            print("count tx error:", error.localizedDescription)
        }

        return intPointer.pointee
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self,
                                      action: #selector(self.reloadTxsForCurrentFilter),
                                      for: UIControl.Event.valueChanged)

        self.txTableView.addSubview(self.refreshControl)
        self.txTableView.hideEmptyAndExtraRows()
        self.txTableView.register(UINib(nibName: TransactionTableViewCell.identifier, bundle: nil),
                                            forCellReuseIdentifier: TransactionTableViewCell.identifier)
        // register for new transactions notifications
        try? WalletLoader.shared.multiWallet.add(self, uniqueIdentifier: "\(self)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true

        self.txTableView.isHidden = false
        self.loadAllTransactions()
    }

    func loadAllTransactions() {
        self.allTransactions.removeAll()
        self.refreshControl.showLoader(in: self.txTableView)
        
        guard let txs = WalletLoader.shared.firstWallet?.transactionHistory(offset: 0), !txs.isEmpty else {
            self.txTableView.backgroundView = self.noTxsLabel
            self.txTableView.separatorStyle = .none
            self.refreshControl.endRefreshing()
            return
        }

        self.setupTxSorterDropDown()
        self.setupTxFilterDropDown()

        self.allTransactions = txs
        self.txTableView.backgroundView = nil
        self.txTableView.separatorStyle = .singleLine

        self.txTableView.reloadData()
        self.refreshControl.endRefreshing()
    }

    func setupTxSorterDropDown() {
        let sortOptions = [ LocalizedStrings.newest, LocalizedStrings.oldest ]
        self.txSortOrderDropDown.initMenu(sortOptions) { [weak self] index, value in
            self?.reloadTxsForCurrentFilter()
        }
    }

    func setupTxFilterDropDown() {
        var filterOptions = [LocalizedStrings.all]
        self.txFilters = [DcrlibwalletTxFilterAll]

        if self.countTransactionsFor(DcrlibwalletTxFilterSent) > 0 {
            filterOptions.append(LocalizedStrings.sent)
            self.txFilters.append(DcrlibwalletTxFilterSent)
        }

        if self.countTransactionsFor(DcrlibwalletTxFilterReceived) > 0 {
            filterOptions.append(LocalizedStrings.received)
            self.txFilters.append(DcrlibwalletTxFilterReceived)
        }

        if self.countTransactionsFor(DcrlibwalletTxFilterTransferred) > 0 {
            filterOptions.append(LocalizedStrings.yourself)
            self.txFilters.append(DcrlibwalletTxFilterTransferred)
        }

        if self.countTransactionsFor(DcrlibwalletTxFilterStaking) > 0 {
            filterOptions.append(LocalizedStrings.staking)
            self.txFilters.append(DcrlibwalletTxFilterStaking)
        }

        if self.countTransactionsFor(DcrlibwalletTxFilterCoinBase) > 0 {
            filterOptions.append(LocalizedStrings.coinbase)
            self.txFilters.append(DcrlibwalletTxFilterCoinBase)
        }

        self.txFilterDropDown.initMenu(filterOptions) { [weak self] index, value in
            self?.reloadTxsForCurrentFilter()
        }
    }

    @objc func reloadTxsForCurrentFilter() {
        self.allTransactions.removeAll()
        self.refreshControl.showLoader(in: self.txTableView)

        defer {
            self.txTableView.reloadData()
            self.refreshControl.endRefreshing()
        }

        let selectedFilterIndex = self.txFilterDropDown.selectedItemIndex
        let currentFilterItem = self.txFilters[safe: selectedFilterIndex] ?? DcrlibwalletTxFilterAll

        let selectedSortIndex = self.txSortOrderDropDown.selectedItemIndex
        let sortOrderNewerFirst = self.txSorters[safe: selectedSortIndex] ?? true

        if let txs = WalletLoader.shared.firstWallet?.transactionHistory(offset: 0, count: 0, filter: currentFilterItem, newestFirst: sortOrderNewerFirst) {
            self.allTransactions = txs
        }
    }
}

extension TransactionsViewController: DcrlibwalletTxAndBlockNotificationListenerProtocol {
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
            self.reloadTxsForCurrentFilter()
        }
    }

    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
        // all tx statuses will be updated when table rows are reloaded.
         DispatchQueue.main.async {
            self.txTableView.reloadData()
        }
    }
}

extension TransactionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.filteredTransactions.count > 0) ? self.filteredTransactions.count : self.allTransactions.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.txTableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell

        var frame = cell.frame
        frame.size.width = self.txTableView.frame.size.width
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

extension TransactionsViewController: UIScrollViewDelegate {
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
