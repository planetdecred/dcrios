//
//  OverviewViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import SlideMenuControllerSwift
import Wallet

class OverviewViewController: UIViewController, WalletGetTransactionsResponseProtocol, WalletTransactionListenerProtocol, WalletBlockNotificationErrorProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbCurrentBalance: UILabel!
    
    var mainContens = ["4.000000 DCR", "-3.000000 DCR", "21.340000 DCR", "-1.000000 DCR", "12.000000 DCR", "-1.000000 DCR", "12.30000 DCR","-2.000000 DCR", "3.000000 DCR","2.000000 DCR", "3.000000 DCR"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerCellNib(DataTableViewCell.self)
        
        AppContext.instance.decrdConnection?.connect(onSuccess: { (height) in
            //let accounts = AppContext.instance.decrdConnection?.getAccounts()
            //let address = AppContext.instance.decrdConnection?.getCurrentAddress(account: (accounts?.Acc.first?.Number)!)
            //print("Address:\(address)")
            AppContext.instance.decrdConnection?.addObserver(transactionsHistoryObserver: self)
            AppContext.instance.decrdConnection?.addObserver(forBlockError: self)
            AppContext.instance.decrdConnection?.addObserver(forUpdateNotifications: self)
            AppContext.instance.decrdConnection?.fetchTransactions()

            self.lbCurrentBalance.text = "\((AppContext.instance.decrdConnection?.getAccounts()?.Acc.first?.dcrTotalBalance)!) DCR"
        }, onFailure: { (error) in
            print(error)
        })
    }
   
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Overview"
    }
    
    func onResult(_ json: String!) {
        mainContens = [String]()
        do{
            let transactions = try JSONDecoder().decode(GetTransactionResponse.self, from:json.data(using: .utf8)!)
            for transactionPack in transactions.Transactions!{
                for creditTransaction in transactionPack.Credits!{
                    mainContens.append("\(creditTransaction.dcrAmount) DCR")
                }
                for debitTransaction in transactionPack.Debits!{
                    mainContens.append("-\(debitTransaction.dcrAmount) DCR")
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch let error{
            print(error)
        }
    }
    
    func onBlockNotificationError(_ err: Error!) {
        
    }
    
    func onTransaction(_ transaction: String!) {
        let transactions = try! JSONDecoder().decode(Transaction.self, from:transaction.data(using: .utf8)!)
        for creditTransaction in transactions.Credits!{
            self.mainContens.append("\(creditTransaction.dcrAmount) DCR")
        }
        for debitTransaction in transactions.Debits!{
            self.mainContens.append("-\(debitTransaction.dcrAmount) DCR")
        }
    }
    
    func onTransactionRefresh() {
        self.tableView.reloadData()
    }
}

extension OverviewViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "SubContentsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewController(withIdentifier: "SubContentsViewController") as! SubContentsViewController
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
}

extension OverviewViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainContens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.identifier) as! DataTableViewCell
        let data = DataTableViewCellData(imageUrl: "dummy", text: self.mainContens[indexPath.row])
        cell.setData(data)
        return cell
    }
}

extension OverviewViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}
