//
//  TransactionHistoryViewController.swift
//  Decred Wallet
//
//  Created by rails on 23/05/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: UIViewController,MobilewalletGetTransactionsResponseProtocol {
    
    
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(OverviewViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.lightGray
        
        return refreshControl
    }()
   
    weak var delegate: LeftMenuProtocol?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnFilter: DropMenuButton!
    var visible:Bool = false
    
    let filterMenu = ["ALL", "Regular", "Ticket", "Votes", "Revokes", "Sent"] as [String]
    
    var mainContens = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.tableView.addSubview(self.refreshControl)
        
        
        btnFilter.initMenu(filterMenu) { [weak self] index, value in
            guard let this = self else { return }
            print("index : \(index), Value : \(value)")
        }
       
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        navigationItem.title = "History"
    }
    override func viewDidAppear(_ animated: Bool) {
        self.visible = true
         prepareRecent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.visible = false
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func prepareRecent(){
        self.mainContens.removeAll()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let this = self else { return }
            do {
                try
                    SingleInstance.shared.wallet?.getTransactions(this)
                print("done getting transaction")
            } catch let Error {
                print(Error)
            }
        }
    }
    func onResult(_ json: String!) {
        print("on result")
        if(self.visible == false){
            print("on result returning")
            return
        }
        else{
            print("on result running")
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                do {
                    let trans = GetTransactionResponse.self
                    let transactions = try JSONDecoder().decode(trans, from: json.data(using: .utf8)!)
                    print("on result decoded")
                    if (transactions.Transactions.count) > 0 {
                        print("on result decoded")
                        if transactions.Transactions.count > this.mainContens.count {
                            print(transactions.Transactions.count)
                            print("new transaction OnResult")
                            print(this.mainContens.count)
                            this.mainContens.removeAll()
                            print("decoding")
                            for transactionPack in transactions.Transactions {
                                self?.mainContens.append(transactionPack)
                                /* for creditTransaction in transactionPack.Credits {
                                 this.mainContens.append("\(creditTransaction.dcrAmount) DCR")
                                 }
                                 for debitTransaction in transactionPack.Debits {
                                 this.mainContens.append("-\(debitTransaction.dcrAmount) DCR")
                                 }*/
                            }
                            this.mainContens.reverse()
                            this.tableView.reloadData()
                            
                        }
                    }
                    
                } catch let error {
                    print("onresult error")
                    print(error)
                }
            }
        }
    }
    
    
    /*
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - Table Delegates

extension TransactionHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainContens.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionHistoryTableViewCell.height()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TransactionFullDetailsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
        print("index is")
        print(indexPath.row)
        if self.mainContens.count == 0{
            print("error")
            return
        }
        subContentsVC.transaction = self.mainContens[indexPath.row]
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: TransactionHistoryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TransactionHistoryTableViewCell.identifier)
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell
        if self.mainContens.count != 0{
            let data = TransactionTableViewCellData(data: mainContens[indexPath.row])
            cell.setData(data)
            return cell
        }
        return cell
        
    }
}
