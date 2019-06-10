//
//  OverviewViewControllerr.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 11/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {
    @IBOutlet weak var syncProgressViewContainer: UIView!
    
    @IBOutlet weak var overviewPageContentView: UIView!
    @IBOutlet weak var fetchingBalanceIndicator: UIImageView!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var recentActivityTableView: UITableView!
    
    var recentTransactions = [Transaction]()
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "embedSyncProgressVC" && AppDelegate.walletLoader.isSynced {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSyncProgressVC" {
            (segue.destination as! SyncProgressViewController).afterSyncCompletes = self.initializeOverviewContent
        }
    }
    
    override func viewDidLoad() {
        if AppDelegate.walletLoader.isSynced {
            self.initializeOverviewContent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar(withTitle: "Overview")
    }
    
    func initializeOverviewContent() {
        self.syncProgressViewContainer.removeFromSuperview()
        self.syncProgressViewContainer = nil
        
        AppDelegate.walletLoader.notification.registerListener(for: "\(self)", newTxistener: self)
        AppDelegate.walletLoader.notification.registerListener(for: "\(self)", confirmedTxListener: self)
        
        self.fetchingBalanceIndicator.loadGif(name: "progress bar-1s-200px")
        self.updateCurrentBalance()
        
        self.recentActivityTableView.registerCellNib(TransactionTableViewCell.self)
        self.recentActivityTableView.delegate = self
        self.recentActivityTableView.dataSource = self
        self.loadRecentActivity()
        
        let pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.addTarget(self, action: #selector(self.handleRecentActivityTableRefresh(_:)), for: UIControl.Event.valueChanged)
        pullToRefreshControl.tintColor = UIColor.lightGray
        self.recentActivityTableView.addSubview(pullToRefreshControl)
        
        self.overviewPageContentView.isHidden = false
    }
    
    func updateCurrentBalance() {
        DispatchQueue.main.async {
            self.totalBalanceLabel.isHidden = true
            self.fetchingBalanceIndicator.superview?.isHidden = false
            
            let totalWalletAmount = AppDelegate.walletLoader.wallet?.totalWalletBalance()
            let totalAmountRoundedOff = (Decimal(totalWalletAmount!) as NSDecimalNumber).round(8)
            
            self.totalBalanceLabel.attributedText = Utils.getAttributedString(str: "\(totalAmountRoundedOff)", siz: 17.0, TexthexColor: GlobalConstants.Colors.TextAmount)
            self.fetchingBalanceIndicator.superview?.isHidden = true
            self.totalBalanceLabel.isHidden = false
        }
    }
    
    @objc func handleRecentActivityTableRefresh(_ refreshControl: UIRefreshControl) {
        self.loadRecentActivity()
        refreshControl.endRefreshing()
    }
    
    func loadRecentActivity() {
        let maxDisplayItems = round(self.recentActivityTableView.frame.size.height / TransactionTableViewCell.height())
        AppDelegate.walletLoader.wallet?.transactionHistory(count: Int32(maxDisplayItems)) { transactions in
            if transactions == nil || transactions!.count == 0 {
                self.showNoTransactions()
                return
            }
            
            self.recentTransactions = transactions!
            self.recentActivityTableView.backgroundView = nil
            self.recentActivityTableView.separatorStyle = .singleLine
            self.recentActivityTableView.reloadData()
        }
    }
    
    func showNoTransactions() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.recentActivityTableView.bounds.size.width, height: self.recentActivityTableView.bounds.size.height))
        label.text = "No Transactions"
        label.textAlignment = .center
        self.recentActivityTableView.backgroundView = label
        self.recentActivityTableView.separatorStyle = .none
    }
    
    @IBAction func showAllTransactionsButtonTap(_ sender: Any) {
        self.navigateToMenu(.history)
    }
    
    @IBAction func showSendPage(_ sender: Any) {
        self.navigateToMenu(.send)
    }
    
    @IBAction func showReceivePage(_ sender: Any) {
        self.navigateToMenu(.receive)
    }
    
    func navigateToMenu(_ menuItem: MenuItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.navigationMenuViewController()?.changeActivePage(to: menuItem)
        }
    }
}

extension OverviewViewController: NewTransactionNotificationProtocol, ConfirmedTransactionNotificationProtocol {
    func onTransaction(_ transaction: String?) {
        var tx = try! JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        
        if self.recentTransactions.contains(where: { $0.Hash == tx.Hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }
        
        tx.Animate = true
        self.recentTransactions.insert(tx, at: 0)
        self.updateCurrentBalance()
        
        DispatchQueue.main.async {
            let maxDisplayItems = round(self.recentActivityTableView.frame.size.height / TransactionTableViewCell.height())
            if self.recentTransactions.count > Int(maxDisplayItems) {
                _ = self.recentTransactions.popLast()
            }
            
            self.recentActivityTableView.reloadData()
        }
    }
    
    func onTransactionConfirmed(_ hash: String?, height: Int32) {
        DispatchQueue.main.async {
            self.updateCurrentBalance()
            self.loadRecentActivity()
        }
    }
}

extension OverviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.recentTransactions.count == 0 {
            return
        }
        
        let txDetailsVC = Storyboards.TransactionFullDetailsViewController.instantiateViewController(for: TransactionFullDetailsViewController.self)
        txDetailsVC.transaction = self.recentTransactions[indexPath.row]
        self.navigationController?.pushViewController(txDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.recentTransactions[indexPath.row].Animate {
            cell.blink()
        }
        self.recentTransactions[indexPath.row].Animate = false
    }
}

extension OverviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
        
        if self.recentTransactions.count != 0 {
            let tx = self.recentTransactions[indexPath.row]
            cell.setData(tx)
        }
        
        return cell
    }
}
