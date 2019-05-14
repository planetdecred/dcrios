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
    var syncProgressViewController: SyncProgressViewController?
    
    @IBOutlet weak var overviewPageContentView: UIView!
    @IBOutlet weak var fetchingBalanceIndicator: UIImageView!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var recentActivityTableView: UITableView!
    
    var recentTransactions = [Transaction]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSyncProgressVC" {
            self.syncProgressViewController = segue.destination as? SyncProgressViewController
        }
    }
    
    override func viewDidLoad() {
        let initialSyncCompleted = WalletLoader.shared.syncer?.generalSyncProgress?.done ?? false
        if initialSyncCompleted {
            self.removeSyncViewsAndLoadOverview()
            return
        }
        
        self.overviewPageContentView.isHidden = true
        
        self.syncProgressViewController?.afterSyncCompletes = self.removeSyncViewsAndLoadOverview
        self.syncProgressViewController!.initialize()
    }
    
    func removeSyncViewsAndLoadOverview() {
        self.syncProgressViewController?.dismiss(animated: false, completion: nil)
        self.syncProgressViewContainer.removeFromSuperview()
        
        self.syncProgressViewController = nil
        self.syncProgressViewContainer = nil
        
        self.initializeOverviewContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar(withTitle: "Overview")
    }
    
    func initializeOverviewContent() {
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
        self.totalBalanceLabel.isHidden = true
        self.fetchingBalanceIndicator.superview?.isHidden = false
        
        do {
            let totalWalletAmount = try WalletLoader.wallet?.totalWalletBalance()
            let totalAmountRoundedOff = (Decimal(totalWalletAmount!) as NSDecimalNumber).round(8)
            
            self.totalBalanceLabel.attributedText = Utils.getAttributedString(str: "\(totalAmountRoundedOff)", siz: 17.0, TexthexColor: GlobalConstants.Colors.TextAmount)
            self.fetchingBalanceIndicator.superview?.isHidden = true
            self.totalBalanceLabel.isHidden = false
        } catch let error {
            print(error)
        }
    }
    
    @objc func handleRecentActivityTableRefresh(_ refreshControl: UIRefreshControl) {
        self.loadRecentActivity()
        refreshControl.endRefreshing()
    }
    
    func loadRecentActivity() {
        DispatchQueue.main.async {
            do {
                var getTransactionsError: NSError?
                let maxDisplayItems = round(self.recentActivityTableView.frame.size.height / TransactionTableViewCell.height())
                let transactionsJson = WalletLoader.wallet?.getTransactions(Int32(maxDisplayItems), error: &getTransactionsError)
                if getTransactionsError != nil {
                    throw getTransactionsError!
                }
                
                self.recentTransactions = try JSONDecoder().decode([Transaction].self, from: transactionsJson!.utf8Bits)
                self.recentActivityTableView.reloadData()
            } catch let Error {
                print(Error)
            }
        }
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.recentTransactions.count > indexPath.row {
            if self.recentTransactions[indexPath.row].Animate {
                cell.blink()
            }
            self.recentTransactions[indexPath.row].Animate = false
        }
    }
}
