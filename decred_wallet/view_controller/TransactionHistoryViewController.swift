//
//  TransactionHistoryViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class TransactionHistoryViewController: UIViewController, DcrlibwalletGetTransactionsResponseProtocol {
    
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
    
    var filterMenu = ["All"] as [String]
    
    var mainContens = [Transaction]()
    var Filtercontent = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFilterBtn()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
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
        self.Filtercontent.removeAll()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let this = self else { return }
            do {
                try
                    SingleInstance.shared.wallet?.getTransactions(this)
            } catch let Error {
                print(Error)
            }
        }
    }
    
    func onResult(_ json: String!) {
        
        if (self.visible == false) {
            return
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                do {
                    let trans = GetTransactionResponse.self
                    let transactions = try JSONDecoder().decode(trans, from: json.data(using: .utf8)!)
                    if (transactions.Transactions.count) > 0 {
                        if (transactions.Transactions.count > this.Filtercontent.count) {
                            print(this.Filtercontent.count)
                            this.Filtercontent.removeAll()
                            for transactionPack in transactions.Transactions {
                                
                                this.mainContens.append(transactionPack)
                            }
                            this.Filtercontent = this.mainContens
                            this.btnFilter.items.removeAll()
                            this.updateDropdown()
                            this.Filtercontent.reverse()
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
    func initFilterBtn(){
        self.btnFilter.initMenu(filterMenu) { [weak self] index, value in
            guard let this = self else { return }
            
            switch(index){
            case 0:
                this.Filtercontent = this.mainContens
                this.Filtercontent.reverse()
                this.btnFilter.setTitle("All (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.tableView.reloadData()
                break
            case 1:
                this.Filtercontent = this.mainContens.filter{$0.Direction == 0}
                this.btnFilter.setTitle("Sent (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.Filtercontent.reverse()
                this.tableView.reloadData()
                break
            case 2:
                this.Filtercontent = this.mainContens.filter{$0.Direction == 1}
                this.btnFilter.setTitle("Received (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.Filtercontent.reverse()
                this.tableView.reloadData()
                break
            case 3:
                this.Filtercontent = this.mainContens.filter{$0.Direction == 2}
                this.btnFilter.setTitle("Yourself (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.Filtercontent.reverse()
                this.tableView.reloadData()
                break
            case 4:
                this.Filtercontent = this.mainContens.filter{$0.Type.lowercased() != "Regular".lowercased()}
                this.btnFilter.setTitle("Staking (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.Filtercontent.reverse()
                this.tableView.reloadData()
                break
            default:
                this.Filtercontent = this.mainContens
                this.btnFilter.setTitle("All (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.Filtercontent.reverse()
                this.tableView.reloadData()
            }
            
        }
    }
    
    
    func updateDropdown(){
        
        let sentCount = self.mainContens.filter{$0.Direction == 0}.count
        let ReceiveCount = self.mainContens.filter{$0.Direction == 1}.count
        let yourselfCount = self.mainContens.filter{$0.Direction == 2}.count
        let stakeCount = self.mainContens.filter{$0.Type.lowercased() != "Regular".lowercased()}.count
        self.btnFilter.setTitle("All (".appending(String(self.Filtercontent.count)).appending(")"), for: .normal)
        self.btnFilter.items.insert("All (".appending(String(self.Filtercontent.count)).appending(")"), at: 0)
        if(sentCount != 0){
            self.btnFilter.items.insert("Sent (".appending(String(sentCount)).appending(")"), at: 1)
        }
        if(ReceiveCount != 0){
            self.btnFilter.items.insert("Received (".appending(String(ReceiveCount)).appending(")"), at: 2)
        }
        if(yourselfCount != 0){
            self.btnFilter.items.insert("Yourself (".appending(String(yourselfCount)).appending(")"), at: 3)
        }
        if(stakeCount != 0){
            self.btnFilter.items.insert("Stake (".appending(String(stakeCount)).appending(")"), at: 4)
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
        return Filtercontent.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionHistoryTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TransactionFullDetailsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
        if self.Filtercontent.count == 0{
            return
        }
        
        subContentsVC.transaction = self.Filtercontent[indexPath.row]
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: TransactionHistoryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TransactionHistoryTableViewCell.identifier)
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell
        if self.Filtercontent.count != 0{
            let data = TransactionTableViewCellData(data: Filtercontent[indexPath.row])
            cell.setData(data)
            return cell
        }
        
        return cell
    }
}
