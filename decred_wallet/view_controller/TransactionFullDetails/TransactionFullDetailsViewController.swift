//  TransactionFullDetailsViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit
import MBProgressHUD
import SafariServices

class TransactionFullDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableTransactionDetails: UITableView!    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var detailsHeader: UIView!
     @IBOutlet weak var amount: UILabel!
    var transactionHash: String?
    var account : String?
    
    let hud = MBProgressHUD(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
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
        
       // self.view.addSubview(hud)
        
        tableTransactionDetails
            .hideEmptyAndExtraRows()
            .autoResizeCell(estimatedHeight: 60.0)
            .registerCellNib(TransactiontInputDetails.self)
        
        tableTransactionDetails.registerCellNib(TransactionDetailCell.self)
        tableTransactionDetails.registerCellNib(TransactiontOutputDetailsCell.self)
        tableTransactionDetails.registerCellNib(TransactiontInputDetails.self)
        self.navigationItem.title = "Transaction Details"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "left-arrow"), style: .done, target: self, action: #selector(backk))
        
    }
    
    
    @objc func backk(){
        self.navigationController?.popViewController(animated: true)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        hud.show(animated: true)
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
           copyHash(hash: transaction.Hash)
            print("HASH: \(transaction.Hash)")
        }
    }

    private func copyHash(hash: String){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = hash
            
            //Alert
            let alertController = UIAlertController(title: "", message: "Hash copied", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    fileprivate func wrap(transaction:Transaction?){
        var confirmations: Int32 = 0
        var status = "Pending"
        let textColor: UIColor?
        
        if(transaction!.Height != -1){
            confirmations = (SingleInstance.shared.wallet?.getBestBlock())! - Int32(transaction!.Height)
            confirmations += 1
        }
        let height = transaction?.Height
        if(height == -1){
            status = "Pending"
            textColor = #colorLiteral(red: 0.2392156863, green: 0.3960784314, blue: 0.6117647059, alpha: 1)
        }
            
        else{
            if(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch") || confirmations > 1){
                status = "Confirmed"
                textColor = #colorLiteral(red: 0.2549019608, green: 0.7490196078, blue: 0.3254901961, alpha: 1)
              
            }
            else{
                status = "Pending"
                textColor = #colorLiteral(red: 0.2392156863, green: 0.3960784314, blue: 0.6117647059, alpha: 1)
               
            }
        }
        details = [
            
            TransactionDetails(
            title: "Date",
            value: format(timestamp: transaction?.Timestamp),
            textColor: nil
            ),
            TransactionDetails(
                title: "Status",
                value: status,
                textColor: textColor
            ),
            TransactionDetails(
                title: "Fee",
                value: "\(Double((transaction?.Fee)!) / 1e8) DCR",
                textColor: nil
            ),
            TransactionDetails(
                title: "Type",
                value: "\(transaction?.Type ?? "Unknown" )",
                textColor: nil
            ),
            TransactionDetails(
                title: "Confirmation",
                value: "\(confirmations )",
                textColor: nil
            ),
            TransactionDetails(
                title: "Hash",
                value: (transaction?.Hash)!,
                textColor: #colorLiteral(red: 0.1607843137, green: 0.4392156863, blue: 1, alpha: 1)
            )
        ]
        let tnt = Decimal(Double((transaction?.Amount)!) / 1e8) as NSDecimalNumber
        self.amount.attributedText = getAttributedString(str: "\(tnt.round(8))", siz: 13)
    }
    
    func openLink(urlString: String) {
        
        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            viewController.delegate = self as? SFSafariViewControllerDelegate
            
            self.present(viewController, animated: true)
        }
    }
    
    fileprivate func format(timestamp:UInt64?) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy / hh:mm:ss pp"
        let date = Date(timeIntervalSince1970: Double(timestamp!))
        return formatter.string(from: date)
    }
}





