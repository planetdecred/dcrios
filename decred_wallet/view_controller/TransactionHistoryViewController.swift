//
//  TransactionHistoryViewController.swift
//  Decred Wallet
//
//  Created by rails on 23/05/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: UIViewController {
    weak var delegate: LeftMenuProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnFilter: DropMenuButton!
    
    var dic1 = [ "status":"Pending", "type" : "Credit", "amount" : "112.000000 DCR","date" : "23 Mar, 2018 10:30 pm" ] as Dictionary!
    var dic2 = [ "status":"Confirmed", "type" : "Debit", "amount" : "24.000000 DCR","date" : "23 Mar, 2018 10:30 pm" ] as Dictionary!

    
    let filterMenu = ["ALL", "Regular", "Ticket", "Votes", "Revokes", "Sent"] as [String]
    
    var mainContens = [Dictionary<String, String>]()

    override func viewDidLoad() {
        super.viewDidLoad()
         mainContens.append(dic1!)
         mainContens.append(dic2!)
        
         btnFilter.initMenu(filterMenu) {(index, value) in
            print("index : \(index), Value : \(value)")
         }
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "History"
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension TransactionHistoryViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainContens.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        tableView.register(UINib(nibName: TransactionHistoryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TransactionHistoryTableViewCell.identifier)
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell
        
        let data = TransactionTableViewCellData(data: mainContens[indexPath.row])
        cell.setData(data)
        return cell
    }
}
