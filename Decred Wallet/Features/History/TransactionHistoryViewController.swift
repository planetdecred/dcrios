//
//  TransactionHistoryViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of self source code is governed by an ISC
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
    
    var filterMenu = ["all".localized] as [String]
    var filtertitle = [0] as [Int]
    
    var mainContens = [Transaction]()
    var Filtercontent = [Transaction]()
    
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
        self.setupNavigationBar(withTitle: "history".localized)

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
    
    func loadTransactions() {
        self.mainContens.removeAll()
        self.Filtercontent.removeAll()
        
        // use count = 0 to return all transactions
        AppDelegate.walletLoader.wallet?.transactionHistory(count: 0) { transactions in
            self.refreshControl.endRefreshing()
            
            if transactions == nil || transactions!.count == 0 {
                self.showNoTransactions()
                return
            }
            
            self.mainContens = transactions!
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            self.reloadTxsForCurrentFilter()
        }
    }
    
    func showNoTransactions() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        label.text = "noTransactions".localized
        label.textAlignment = .center
        self.tableView.backgroundView = label
        self.tableView.separatorStyle = .none
    }
    
    func initFilterBtn() {
        self.btnFilter.initMenu(filterMenu) { [weak self] index, value in
            self?.applyTxFilter(currentFilter: self!.filtertitle[index])
        }
    }
    
    func reloadTxsForCurrentFilter() {
        var currentFilterItem = 0
        if self.btnFilter.selectedItemIndex >= 0 && self.filtertitle.count > self.btnFilter.selectedItemIndex {
            currentFilterItem = self.filtertitle[self.btnFilter.selectedItemIndex]
        }
        self.updateFilterDropdownItems()
        self.applyTxFilter(currentFilter: currentFilterItem)
    }
    
    func applyTxFilter(currentFilter: Int) {
        switch currentFilter {
        case 1:
            // TODO: Remove after next dcrlibwallet update
            self.Filtercontent = self.mainContens.filter{$0.Direction == 0 && $0.Type == GlobalConstants.Strings.REGULAR}
            self.btnFilter.setTitle("sent".localized .appending("(").appending(String(self.Filtercontent.count)).appending(")"), for: .normal)
            self.tableView.reloadData()
            break
        case 2:
            // TODO: Remove after next dcrlibwallet update
            self.Filtercontent = self.mainContens.filter{$0.Direction == 1 && $0.Type == GlobalConstants.Strings.REGULAR}
            self.btnFilter.setTitle("received".localized .appending("(").appending(String(self.Filtercontent.count)).appending(")"), for: .normal)
            self.tableView.reloadData()
            break
        case 3:
            // TODO: Remove after next dcrlibwallet update
            self.Filtercontent = self.mainContens.filter{$0.Direction == 2 && $0.Type == GlobalConstants.Strings.REGULAR}
            self.btnFilter.setTitle("yourself".localized.appending("(").appending(String(self.Filtercontent.count)).appending(")"), for: .normal)
            self.tableView.reloadData()
            break
        case 4:
            self.Filtercontent = self.mainContens.filter{$0.Type == GlobalConstants.Strings.REVOCATION || $0.Type == GlobalConstants.Strings.TICKET_PURCHASE || $0.Type == GlobalConstants.Strings.VOTE}
            self.btnFilter.setTitle("staking".localized.appending("(").appending(String(self.Filtercontent.count)).appending(")"), for: .normal)
            self.tableView.reloadData()
            break
        case 5:
            self.Filtercontent = self.mainContens.filter{$0.Type == GlobalConstants.Strings.COINBASE}
            self.btnFilter.setTitle("Coinbase (".appending(String(self.Filtercontent.count)).appending(")"), for: .normal)
            self.tableView.reloadData()
            break
        default:
            self.Filtercontent = self.mainContens
            self.btnFilter.setTitle("all".localized.appending("(").appending(String(self.Filtercontent.count)).appending(")"), for: .normal)
            self.tableView.reloadData()
        }
    }
    
    func updateFilterDropdownItems() {
        let sentCount = self.mainContens.filter{$0.Direction == 0}.count
        let ReceiveCount = self.mainContens.filter{$0.Direction == 1}.count
        let yourselfCount = self.mainContens.filter{$0.Direction == 2}.count
        let stakeCount = self.mainContens.filter{$0.Type.lowercased() != "Regular".lowercased()}.count
        let coinbaseCount = self.mainContens.filter{$0.Type == GlobalConstants.Strings.COINBASE}.count
        
        self.btnFilter.items.removeAll()
        self.btnFilter.setTitle("all".localized.appending("(").appending(String(self.mainContens.count)).appending(")"), for: .normal)
        self.btnFilter.items.append("all".localized.appending("(").appending(String(self.mainContens.count)).appending(")"))
        
        self.filtertitle.removeAll()
        self.filtertitle.append(0)
        
        if sentCount != 0 {
            self.btnFilter.items.append("sent".localized .appending("(").appending(String(sentCount)).appending(")"))
            self.filtertitle.append(1)
        }
        if ReceiveCount != 0 {
            self.btnFilter.items.append("received".localized .appending("(").appending(String(ReceiveCount)).appending(")"))
            self.filtertitle.append(2)
        }
        if yourselfCount != 0 {
            self.btnFilter.items.append("yourself".localized.appending("(").appending(String(yourselfCount)).appending(")"))
            self.filtertitle.append(3)
        }
        if stakeCount != 0 {
            self.btnFilter.items.append("staking".localized.appending("(").appending(String(stakeCount)).appending(")"))
            self.filtertitle.append(4)
        }
        if coinbaseCount != 0 {
            self.btnFilter.items.append("Coinbase (".appending(String(coinbaseCount)).appending(")"))
            self.filtertitle.append(5)
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
