//
//  OverviewViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
import SlideMenuControllerSwift
import Wallet

class TransactionsManager : TransactionBlockObserverProtocol, TransactionObserverProtocol{
    func onBlockError(error: Error) {
        print(error)
    }
    
    var transactions: [String]?
    
    func populateTransaction(transaction: String) {
        print(transaction)
    }
    
    func refresh() {
        transactions = [String]()
        print("refresh")
    }
    
    
}

class OverviewViewController: UIViewController {
    //var transactions: [String]?
    let transactions = TransactionsManager()
    var transactionBlockObserver : TransactionsBlockObserver?
    var transactionObserver : TransactionsObserver?
    
    @IBOutlet weak var tableView: UITableView!


    var mainContens = ["2.000000 DCR", "-3.000000 DCR", "21.340000 DCR", "-1.000000 DCR", "12.000000 DCR", "-1.000000 DCR", "12.30000 DCR","-2.000000 DCR", "3.000000 DCR","2.000000 DCR", "3.000000 DCR"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerCellNib(DataTableViewCell.self)
        //self.transactions = [String]()
        transactionBlockObserver = TransactionsBlockObserver(listener: transactions )
        transactionObserver = TransactionsObserver(listener: transactions )
        if (AppContext.instance.decrdConnection?.connect())!{
            transactionBlockObserver?.subscribe()
            transactionObserver?.subscribe()
            AppContext.instance.decrdConnection?.fetchTransactions(onGotTransaction: { (transaction) in
                
            }, onFailure: { (error) in
                
            })
        }
    }
    
   
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Overview"
    }

    func populateTransaction(transaction:String){
        //transactions?.append(transaction)
        self.tableView.reloadData()
    }
    
    func refresh(){
        self.tableView.reloadData()
    }
    
    func onBlockError(error:Error){
        print(error)
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
        let data = DataTableViewCellData(imageUrl: "dummy", text: mainContens[indexPath.row])
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
