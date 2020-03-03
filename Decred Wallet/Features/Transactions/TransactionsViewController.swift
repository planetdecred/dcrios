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
    var initialPageHeaderTopConstraintValue: CGFloat?
    @IBOutlet weak var pageHeaderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageHeaderStackView: UIStackView!
    @IBOutlet weak var pageHeaderBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var walletSelectorContainerView: UIView!
    @IBOutlet weak var walletSelectorCollectionView: UICollectionView!
    @IBOutlet weak var walletSelectorPrevButton: UIButton!
    @IBOutlet weak var walletSelectorNextButton: UIButton!

    @IBOutlet var txFilterDropDown: DropMenuButton!
    @IBOutlet var txSortOrderDropDown: DropMenuButton!
    @IBOutlet var txTableView: UITableView!

    private var refreshControl: UIRefreshControl!
    private var currentWalletSelectorIndex: Int = 0
    private let walletSelectorGradientLayer = CAGradientLayer()

    var noTxsLabel: UILabel {
        let noTxsLabel = UILabel(frame: self.txTableView.frame)
        noTxsLabel.text = LocalizedStrings.noTransactions
        noTxsLabel.font = UIFont(name: "Source Sans Pro", size: 16)
        noTxsLabel.textColor = UIColor.appColors.lightBluishGray
        noTxsLabel.textAlignment = .center
        return noTxsLabel
    }

    var allTransactions = [Transaction]()
    var txFilters = [Int32]()
    let txSortOrders: [Bool] = [true, false]
    var newTxHashes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self,
                                      action: #selector(self.reloadTxsForCurrentFilter),
                                      for: UIControl.Event.valueChanged)

        self.txTableView.addSubview(self.refreshControl)
        self.txTableView.hideEmptyAndExtraRows()
        self.txTableView.registerCellNib(TransactionTableViewCell.self)

        // register for new transactions notifications
        try? WalletLoader.shared.multiWallet.add(self, uniqueIdentifier: "\(self)")

        self.setupWalletSelector()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.selectWallet(selectedIndex: self.currentWalletSelectorIndex)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateWalletSelectorSteppingButtonsAndGradientColors()
        self.updateWalletSelectorGradientFrame()
    }

    private func setupWalletSelector() {
        if WalletLoader.shared.wallets.count > 1 {
            self.walletSelectorContainerView.horizontalBorder(borderColor: UIColor.appColors.gray, yPosition: self.walletSelectorContainerView.frame.size.height - 1, borderHeight: 1)

            self.walletSelectorGradientLayer.frame = self.walletSelectorCollectionView.bounds
            self.walletSelectorGradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor]
            self.walletSelectorGradientLayer.locations = [0, 0.2, 0.8, 1]
            self.walletSelectorGradientLayer.transform = CATransform3DMakeRotation(.pi / -2, 0, 0, 1)
            self.walletSelectorGradientLayer.delegate = self
            self.walletSelectorCollectionView.layer.mask = walletSelectorGradientLayer

            self.walletSelectorPrevButton.setImage(UIImage(cgImage: UIImage(named: "ic_collapse")!.cgImage!, scale: CGFloat(1.0), orientation: .leftMirrored), for: .normal)
            self.walletSelectorNextButton.setImage(UIImage(cgImage: UIImage(named: "ic_collapse")!.cgImage!, scale: CGFloat(1.0), orientation: .rightMirrored), for: .normal)
        } else {
            self.walletSelectorContainerView.isHidden = true
        }
    }

    private func selectWallet(selectedIndex: Int) {
        self.currentWalletSelectorIndex = selectedIndex
        self.walletSelectorCollectionView.selectItem(at: IndexPath(row: self.currentWalletSelectorIndex, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        self.updateWalletSelectorSteppingButtonsAndGradientColors()
        self.loadAllTransactions()
    }

    private func updateWalletSelectorSteppingButtonsAndGradientColors() {
        if self.walletSelectorCollectionView.contentSize.width < self.walletSelectorCollectionView.bounds.width {
            self.walletSelectorPrevButton.isHidden = true
            self.walletSelectorNextButton.isHidden = true
        } else {
            self.walletSelectorPrevButton.isHidden = self.currentWalletSelectorIndex == 0
            self.walletSelectorNextButton.isHidden = self.currentWalletSelectorIndex == WalletLoader.shared.wallets.count - 1
            self.walletSelectorGradientLayer.colors = [(!self.walletSelectorPrevButton.isHidden || self.walletSelectorCollectionView.contentOffset.x > 0) ? UIColor.clear.cgColor : UIColor.black.cgColor,
                                         UIColor.black.cgColor,
                                         UIColor.black.cgColor,
                                         (!self.walletSelectorNextButton.isHidden || floor(self.walletSelectorCollectionView.contentOffset.x) < floor(self.walletSelectorCollectionView.contentSize.width - self.walletSelectorCollectionView.frame.size.width )) ? UIColor.clear.cgColor : UIColor.black.cgColor]
        }
    }

    @IBAction func walletSelectorPrevButtonTapped(_ sender: Any) {
        if self.currentWalletSelectorIndex > 0 {
            self.selectWallet(selectedIndex: self.currentWalletSelectorIndex - 1)
        }
    }

    @IBAction func walletSelectorNextButtonTapped(_ sender: Any) {
        if self.currentWalletSelectorIndex < WalletLoader.shared.wallets.count - 1 {
            self.selectWallet(selectedIndex: self.currentWalletSelectorIndex + 1)
        }
    }

    func loadAllTransactions() {
        self.allTransactions.removeAll()
        self.refreshControl.showLoader(in: self.txTableView)

        defer {
            self.refreshControl.endRefreshing()
        }

        if let txs = WalletLoader.shared.wallets[self.currentWalletSelectorIndex].transactionHistory(offset: 0), !txs.isEmpty {
            self.allTransactions = txs
            self.txTableView.backgroundView = nil
            self.txTableView.separatorStyle = .singleLine
        } else {
            self.txTableView.backgroundView = self.noTxsLabel
            self.txTableView.separatorStyle = .none
        }

        self.setupTxSortOrderDropDown()
        self.setupTxFilterDropDown()

        self.txTableView.reloadData()
    }

    func setupTxSortOrderDropDown() {
        let sortOptions = [ LocalizedStrings.newest, LocalizedStrings.oldest ]
        self.txSortOrderDropDown.initMenu(sortOptions) { [weak self] index, value in
            self?.reloadTxsForCurrentFilter()
        }
    }

    func setupTxFilterDropDown() {
        var filterOptions = [LocalizedStrings.all]
        self.txFilters = [DcrlibwalletTxFilterAll]

        let wallet = WalletLoader.shared.wallets[self.currentWalletSelectorIndex]
        if wallet.transactionsCount(forTxFilter: DcrlibwalletTxFilterSent) > 0 {
            filterOptions.append(LocalizedStrings.sent)
            self.txFilters.append(DcrlibwalletTxFilterSent)
        }

        if wallet.transactionsCount(forTxFilter: DcrlibwalletTxFilterReceived) > 0 {
            filterOptions.append(LocalizedStrings.received)
            self.txFilters.append(DcrlibwalletTxFilterReceived)
        }

        if wallet.transactionsCount(forTxFilter: DcrlibwalletTxFilterTransferred) > 0 {
            filterOptions.append(LocalizedStrings.yourself)
            self.txFilters.append(DcrlibwalletTxFilterTransferred)
        }

        if wallet.transactionsCount(forTxFilter: DcrlibwalletTxFilterStaking) > 0 {
            filterOptions.append(LocalizedStrings.staking)
            self.txFilters.append(DcrlibwalletTxFilterStaking)
        }

        if wallet.transactionsCount(forTxFilter: DcrlibwalletTxFilterCoinBase) > 0 {
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
        let sortOrderNewerFirst = self.txSortOrders[safe: selectedSortIndex] ?? true

        if let txs = WalletLoader.shared.wallets[self.currentWalletSelectorIndex].transactionHistory(offset: 0, count: 0, filter: currentFilterItem, newestFirst: sortOrderNewerFirst) {
            self.allTransactions = txs
        }
    }
}

extension TransactionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allTransactions.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.txTableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell

        if indexPath.row == 0 {
            cell.setRoundCorners(corners: [.topLeft, .topRight], radius: 14.0)
        } else if indexPath.row == allTransactions.count - 1 {
            cell.setRoundCorners(corners: [.bottomRight, .bottomLeft], radius: 14.0)
        } else {
            cell.setRoundCorners(corners: [.bottomRight, .bottomLeft, .topLeft, .topRight], radius: 0.0)
        }

        cell.displayInfo(for: allTransactions[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let tx = self.allTransactions[indexPath.row]
        if let newTxHashIndex = self.newTxHashes.firstIndex(of: tx.hash) {
            cell.blink()
            self.newTxHashes.remove(at: newTxHashIndex)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transactionDetailVC = TransactionDetailsViewController.instantiate(from: .TransactionDetails)
        transactionDetailVC.transaction = self.allTransactions[indexPath.row]
        self.present(transactionDetailVC, animated: true)
    }
}

extension TransactionsViewController: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
        // not relevant to this VC
    }

    func onTransaction(_ transaction: String?) {
        let tx = try! JSONDecoder().decode(Transaction.self, from: (transaction!.utf8Bits))

        if self.allTransactions.contains(where: { $0.hash == tx.hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }

        if self.newTxHashes.firstIndex(of: tx.hash) != nil {
            return
        }

        self.newTxHashes.append(tx.hash)
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

extension TransactionsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.txTableView {
            // make page header section view fade in or out progressively as user scrolls
            // up or down on the transactionsTableView.
            if self.initialPageHeaderTopConstraintValue == nil {
                self.initialPageHeaderTopConstraintValue = self.pageHeaderTopConstraint.constant
            }
            let minimumValue: CGFloat = -1 * (self.initialPageHeaderTopConstraintValue! + self.pageHeaderStackView.frame.size.height +
                self.pageHeaderBottomConstraint.constant)
            self.pageHeaderTopConstraint.constant = min(self.initialPageHeaderTopConstraintValue!, self.initialPageHeaderTopConstraintValue! + max(minimumValue, -scrollView.contentOffset.y))
            self.pageHeaderStackView.alpha = pageHeaderTopConstraint.constant / self.initialPageHeaderTopConstraintValue!
        } else if scrollView == self.walletSelectorCollectionView {
            self.updateWalletSelectorSteppingButtonsAndGradientColors()
            self.updateWalletSelectorGradientFrame()
        }
    }

    private func updateWalletSelectorGradientFrame() {
        self.walletSelectorGradientLayer.frame = CGRect( x: self.walletSelectorCollectionView.contentOffset.x,
                                           y: 0,
                                           width: self.walletSelectorCollectionView.bounds.width,
                                           height: self.walletSelectorCollectionView.bounds.height )
    }
}

extension TransactionsViewController: CALayerDelegate {
    // prevent any unwanted animation in a CAGradientLayer
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return NSNull()
    }
}

extension TransactionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WalletLoader.shared.wallets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletSelectorCell", for: indexPath) as! WalletSelectorCollectionViewCell
        cell.walletNameLabel.text = WalletLoader.shared.wallets[indexPath.row].name
        return cell
    }
}

extension TransactionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectWallet(selectedIndex: indexPath.row)
    }
}
