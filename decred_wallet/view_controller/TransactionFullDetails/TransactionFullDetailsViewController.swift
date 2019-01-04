//  TransactionFullDetailsViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit
import IHProgressHUD

class TransactionFullDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableTransactionDetails: UITableView!    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var detailsHeader: UIView!
     @IBOutlet weak var amount: UILabel!
    var transactionHash: String?
    var account : String?
    
    var details: [TransactionDetails] = [
        TransactionDetails(
            title: "Status",
            value: "45 Confirmations",
            textColor: #colorLiteral(red: 0.2549019608, green: 0.7490196078, blue: 0.3254901961, alpha: 1)
        ),
        TransactionDetails(
            title: "Confirmation",
            value: "644",
            textColor: #colorLiteral(red: 0.3803921569, green: 0.4509803922, blue: 0.5254901961, alpha: 1)
        ),
        TransactionDetails(
            title: "Type",
            value: "Regular",
            textColor: #colorLiteral(red: 0.3803921569, green: 0.4509803922, blue: 0.5254901961, alpha: 1)
        ),
        TransactionDetails(
            title: "Date",
            value: "Mar 27, 2018 / 10:28:35 pm",
            textColor: #colorLiteral(red: 0.3803921569, green: 0.4509803922, blue: 0.5254901961, alpha: 1)
        ),
        TransactionDetails(
            title: "Fee",
            value: "0.000253 DCR",
            textColor: #colorLiteral(red: 0.3803921569, green: 0.4509803922, blue: 0.5254901961, alpha: 1)
        ),
        TransactionDetails(
            title: "Hash",
            value: "000000000000001a8befe3271f3c293e5af4365f1db5a664e8496ca3f6dc74d5",
            textColor: #colorLiteral(red: 0.1607843137, green: 0.4392156863, blue: 1, alpha: 1)
        )
    ]
    var transaction: Transaction!
    var txstatus: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableTransactionDetails
            .hideEmptyAndExtraRows()
            .autoResizeCell(estimatedHeight: 60.0)
            .registerCellNib(TransactiontInputDetails.self)
        
        tableTransactionDetails.registerCellNib(TransactionDetailCell.self)
        tableTransactionDetails.registerCellNib(TransactiontOutputDetailsCell.self)
        tableTransactionDetails.registerCellNib(TransactiontInputDetails.self)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        IHProgressHUD.show()
        wrap(transaction: self.transaction)
     
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (section == 0 ? details.count : 1)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40.0
        }
       
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.zero)
        headerView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        headerView.frame.size.height = 30.0
        
        return (section == 0 ? self.detailsHeader : headerView)
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailCell") as! TransactionDetailCell
            let data = details[indexPath.row]
            cell.txnDetails = data
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontInputDetails") as! TransactiontInputDetails
            cell.setup(with: transaction.Debits)
            cell.expandOrCollapse = { [weak self] in
                self?.tableTransactionDetails.reloadData()
            }
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontOutputDetailsCell") as! TransactiontOutputDetailsCell
            cell.setup(with: transaction.Credits)
            cell.expandOrCollapse = { [weak self] in
                self?.tableTransactionDetails.reloadData()
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            print("HASH: \(transaction.Hash)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    fileprivate func wrap(transaction:Transaction?){
        details = [
            TransactionDetails(
                title: "Status",
                value: "\(transaction?.Status ?? "0") Confirmed",
                textColor: nil
            ),
            TransactionDetails(
                title: "Confirmation",
                value: "\(transaction?.Height ?? 0)",
                textColor: nil
            ),
            TransactionDetails(
                title: "Type",
                value: "\(transaction?.Type ?? "Unknown" )",
                textColor: nil
            ),
            TransactionDetails(
                title: "Date",
                value: format(timestamp: transaction?.Timestamp),
                textColor: nil
            ),
            TransactionDetails(
                title: "Fee",
                value: "\(Double((transaction?.Fee)!) / 1e8) DCR",
                textColor: nil
            ),
            TransactionDetails(
                title: "Hash",
                value: (transaction?.Hash)!,
                textColor: nil
            )
        ]
        self.amount.text = "\(Double((transaction?.Amount)!) / 1e8) DCR"
    }
    
    fileprivate func format(timestamp:UInt64?) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy / hh:mm:ss pp"
        let date = Date(timeIntervalSince1970: Double(timestamp!))
        return formatter.string(from: date)
    }
}





