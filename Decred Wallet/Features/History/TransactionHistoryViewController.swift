//
//  TransactionHistoryViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
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
    
    var filterMenu = ["All"] as [String]
    var filtertitle = [0] as [Int]
    
    var mainContens = [Transaction]()
    var Filtercontent = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFilterBtn()
        self.tableView.addSubview(self.refreshControl)
        self.tableView.register(UINib(nibName: TransactionTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TransactionTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar(withTitle: "History")

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
            prepareRecent()
            FromMenu = true
        }
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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.prepareRecent()
    }
    
    func prepareRecent(){
        self.mainContens.removeAll()
        self.Filtercontent.removeAll()
        DispatchQueue.global(qos: .background).async {
            do {
                var getTxsError: NSError?
                // use limit = 0 to return all transactions
                let jsonResponse = AppDelegate.walletLoader.wallet?.getTransactions(0, error: &getTxsError)
                if getTxsError != nil {
                    throw getTxsError!
                }
                self.onResult(jsonResponse)
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            } catch let Error {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                print(Error)
            }
        }
    }
    
    func onResult(_ json: String?) {
        if (self.visible == false) {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            do {
                let transactions = try JSONDecoder().decode([Transaction].self, from: (json?.data(using: .utf8)!)!)
                if transactions.count > 0 {
                    this.tableView.backgroundView = nil
                    this.tableView.separatorStyle = .singleLine
                    
                    this.Filtercontent.removeAll()
                    
                    this.mainContens = transactions
                    this.Filtercontent = this.mainContens
                    
                    this.tableView.reloadData()
                } else {
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: this.tableView.bounds.size.width, height: this.tableView.bounds.size.height))
                    label.text = "No Transactions"
                    label.textAlignment = .center
                    this.tableView.backgroundView = label
                    this.tableView.separatorStyle = .none
                }
                
                this.btnFilter.items.removeAll()
                this.updateDropdown()
            } catch let error {
                print("onresult error")
                print(error)
            }
        }
    }
    
    func initFilterBtn() {
        self.btnFilter.initMenu(filterMenu) { [weak self] index, value in
            guard let this = self else { return }
            
            switch(self?.filtertitle[index]){
            case 1:
                // TODO: Remove after next dcrlibwallet update
                this.Filtercontent = this.mainContens.filter{$0.Direction == 0 && $0.Type == GlobalConstants.Strings.REGULAR}
                this.btnFilter.setTitle("Sent (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.tableView.reloadData()
                break
            case 2:
                // TODO: Remove after next dcrlibwallet update
                this.Filtercontent = this.mainContens.filter{$0.Direction == 1 && $0.Type == GlobalConstants.Strings.REGULAR}
                this.btnFilter.setTitle("Received (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.tableView.reloadData()
                break
            case 3:
                // TODO: Remove after next dcrlibwallet update
                this.Filtercontent = this.mainContens.filter{$0.Direction == 2 && $0.Type == GlobalConstants.Strings.REGULAR}
                this.btnFilter.setTitle("Yourself (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.tableView.reloadData()
                break
            case 4:
                this.Filtercontent = this.mainContens.filter{$0.Type == GlobalConstants.Strings.REVOCATION || $0.Type == GlobalConstants.Strings.TICKET_PURCHASE || $0.Type == GlobalConstants.Strings.VOTE}
                this.btnFilter.setTitle("Staking (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.tableView.reloadData()
                break
            case 5:
                this.Filtercontent = this.mainContens.filter{$0.Type == GlobalConstants.Strings.COINBASE}
                this.btnFilter.setTitle("Coinbase (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.tableView.reloadData()
                break
            default:
                this.Filtercontent = this.mainContens
                this.btnFilter.setTitle("All (".appending(String(this.Filtercontent.count)).appending(")"), for: .normal)
                this.tableView.reloadData()
            }
        }
    }
    
    
    func updateDropdown() {
        let sentCount = self.mainContens.filter{$0.Direction == 0}.count
        let ReceiveCount = self.mainContens.filter{$0.Direction == 1}.count
        let yourselfCount = self.mainContens.filter{$0.Direction == 2}.count
        let stakeCount = self.mainContens.filter{$0.Type.lowercased() != "Regular".lowercased()}.count
        let coinbaseCount = self.mainContens.filter{$0.Type == GlobalConstants.Strings.COINBASE}.count
        self.filtertitle.removeAll()
        self.btnFilter.setTitle("All (".appending(String(self.Filtercontent.count)).appending(")"), for: .normal)
        self.btnFilter.items.append("All (".appending(String(self.Filtercontent.count)).appending(")"))
        self.filtertitle.append(0)
        if(sentCount != 0){
            self.btnFilter.items.append("Sent (".appending(String(sentCount)).appending(")"))
            filtertitle.append(1)
        }
        if(ReceiveCount != 0){
            self.btnFilter.items.append("Received (".appending(String(ReceiveCount)).appending(")"))
            filtertitle.append(2)
        }
        if(yourselfCount != 0){
            self.btnFilter.items.append("Yourself (".appending(String(yourselfCount)).appending(")"))
            filtertitle.append(3)
        }
        if(stakeCount != 0){
            self.btnFilter.items.append("Stake (".appending(String(stakeCount)).appending(")"))
            filtertitle.append(4)
        }
        if(coinbaseCount != 0){
            self.btnFilter.items.append("Coinbase (".appending(String(coinbaseCount)).appending(")"))
            filtertitle.append(5)
        }
    }
}

// MARK: - Table Delegates

extension TransactionHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Filtercontent.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
        if self.Filtercontent.count != 0{
            let transaction = Filtercontent[indexPath.row]
            cell.setData(transaction)
            return cell
        }
        
        return cell
    }
}
