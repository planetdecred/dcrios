//  TransactionFullDetailsViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class TransactionFullDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private weak var tableTransactionDetails: UITableView!    
    @IBOutlet var detailsHeader: UIView!
    
    let details: [TransactionDetails] = [
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableTransactionDetails
            .hideEmptyAndExtraRows()
            .autoResizeCell(estimatedHeight: 60.0)
            .registerCellNib(TransactiontInputDetails.self)
        
        tableTransactionDetails.registerCellNib(TransactionDetailCell.self)
        tableTransactionDetails.registerCellNib(TransactiontOutputDetailsCell.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            cell.expandOrCollapse = { [weak self] in
                self?.tableTransactionDetails.reloadData()
            }
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontOutputDetailsCell") as! TransactiontOutputDetailsCell
            cell.expandOrCollapse = { [weak self] in
                self?.tableTransactionDetails.reloadData()
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}
