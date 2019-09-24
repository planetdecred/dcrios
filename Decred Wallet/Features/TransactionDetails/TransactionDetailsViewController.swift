//  TransactionDetailsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit
import Dcrlibwallet
import SafariServices

class TransactionDetailsViewController: UIViewController, SFSafariViewControllerDelegate  {
    @IBOutlet private weak var tableTransactionDetails: UITableView!    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var detailsHeader: UIView!
    @IBOutlet weak var amount: UILabel!
    
    var transactionHash: String?
    var transaction: Transaction!
    
    var generalTxDetails: [TransactionDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableTransactionDetails
            .hideEmptyAndExtraRows()
            .autoResizeCell(estimatedHeight: 60.0)
            .registerCellNib(TransactiontInputDetailsCell.self)
        
        tableTransactionDetails.registerCellNib(TransactionDetailCell.self)
        tableTransactionDetails.registerCellNib(TransactiontInputDetailsCell.self)
        tableTransactionDetails.registerCellNib(TransactiontOutputDetailsCell.self)
        
        self.removeNavigationBarItem()
        self.slideMenuController()?.removeLeftGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = LocalizedStrings.transactionDetails
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "left-arrow"),
                                                                style: .done, target: self,
                                                                action: #selector(back))
       
        let optionsMenuButton = UIButton(type: .custom)
        optionsMenuButton.setImage(UIImage(named: "right-menu"), for: .normal)
        optionsMenuButton.addTarget(self, action: #selector(showOptionsMenu), for: .touchUpInside)
        optionsMenuButton.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: optionsMenuButton)
        ]
        
        if self.transaction == nil && self.transactionHash != nil {
            let txHash = Data(fromHexEncodedString: self.transactionHash!)!
            var getTxError: NSError?
            let txJsonString = AppDelegate.walletLoader.wallet?.getTransaction(txHash, error: &getTxError)
            if getTxError != nil {
                print("wallet.getTransaction error", getTxError!.localizedDescription)
            }
            
            do {
                self.transaction = try JSONDecoder().decode(Transaction.self, from:(txJsonString!.utf8Bits))
            } catch let error {
                print("decode transaction error:", error.localizedDescription)
            }
        }
        
        self.prepareTransactionDetails()
    }
    
    fileprivate func prepareTransactionDetails() {
        var confirmations: Int32 = 0
        if self.transaction.blockHeight != -1 {
            confirmations = AppDelegate.walletLoader.wallet!.getBestBlock() - Int32(self.transaction.blockHeight) + 1
        }
        
        let isConfirmed = Settings.spendUnconfirmed || confirmations > 1
        let status = isConfirmed ? LocalizedStrings.confirmed : LocalizedStrings.pending
        let textColor = isConfirmed ? #colorLiteral(red: 0.2549019608, green: 0.7490196078, blue: 0.3254901961, alpha: 1) : #colorLiteral(red: 0.2392156863, green: 0.3960784314, blue: 0.6117647059, alpha: 1)
        
        let txAmount = Utils.getAttributedString(
            str: "\(self.transaction.dcrAmount.round(8))",
            siz: 13,
            TexthexColor: GlobalConstants.Colors.TextAmount
        )
        let txFee = Utils.getAttributedString(
            str: "\(self.transaction.dcrFee.round(8))",
            siz: 13,
            TexthexColor: GlobalConstants.Colors.TextAmount
        )
        
        generalTxDetails = [
            TransactionDetails(
                title: LocalizedStrings.date,
                value: NSMutableAttributedString(string: Utils.formatDateTime(timestamp: self.transaction.timestamp)),
                textColor: nil
            ),
            TransactionDetails(
                title: LocalizedStrings.status,
                value: NSMutableAttributedString(string:status),
                textColor: textColor
            ),
            TransactionDetails(
                title: LocalizedStrings.amount,
                value: txAmount,
                textColor: nil
            ),
            TransactionDetails(
                title: LocalizedStrings.fee,
                value: txFee,
                textColor: nil
            ),
            TransactionDetails(
                title: LocalizedStrings.type,
                value: NSMutableAttributedString(string: self.transaction.type),
                textColor: nil
            ),
            TransactionDetails(
                title: LocalizedStrings.confirmation,
                value: NSMutableAttributedString(string: "\(confirmations)"),
                textColor: nil
            ),
            TransactionDetails(
                title: LocalizedStrings.hash,
                value: NSMutableAttributedString(string: self.transaction.hash),
                textColor: #colorLiteral(red: 0.1607843137, green: 0.4392156863, blue: 1, alpha: 1)
            )
        ]
        
        if self.transaction.type == DcrlibwalletTxTypeVote {
            let lastBlockValid = TransactionDetails(
                title: LocalizedStrings.lastBlockValid,
                value: NSMutableAttributedString(string: String(describing: self.transaction.lastBlockValid)),
                textColor: nil
            )
            generalTxDetails.append(lastBlockValid)
            
            let voteVersion = TransactionDetails(
                title: LocalizedStrings.version,
                value: NSAttributedString(string: "\(self.transaction.voteVersion)"),
                textColor: nil
            )
            generalTxDetails.append(voteVersion)
            
            let voteBits = TransactionDetails(
                title:LocalizedStrings.voteBits,
                value: NSAttributedString(string: self.transaction.voteBits),
                textColor: nil
            )
            generalTxDetails.append(voteBits)
        }
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showOptionsMenu(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)
        
        let copyTxHash = UIAlertAction(title: LocalizedStrings.copyTransactionHash, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.copyText(self.transaction.hash)
        })
        
        let copyRawTx = UIAlertAction(title: LocalizedStrings.copyRawTransaction, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.copyText(self.transaction.hex)
        })
        
        let viewOnDcrdata = UIAlertAction(title: LocalizedStrings.viewOnDcrdata, style: .default, handler: { (alert: UIAlertAction!) -> Void in
             if BuildConfig.IsTestNet {
                self.openLink(urlString: "https://testnet.dcrdata.org/tx/\(self.transaction.hash)")
             } else {
                self.openLink(urlString: "https://mainnet.dcrdata.org/tx/\(self.transaction.hash)")
            }
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(copyTxHash)
        alertController.addAction(copyRawTx)
        alertController.addAction(viewOnDcrdata)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItems![0]
        }
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    private func copyText(_ text: String) {
        DispatchQueue.main.async {
            UIPasteboard.general.string = text
            
            let alertController = UIAlertController(title: "",
                                                    message: LocalizedStrings.copied,
                                                    preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: LocalizedStrings.ok,
                                                    style: UIAlertAction.Style.default,
                                                    handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func openLink(urlString: String) {
        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url)
            viewController.delegate = self as SFSafariViewControllerDelegate
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension TransactionDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.generalTxDetails.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.zero)
        headerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        headerView.frame.size.height = 0
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailCell") as! TransactionDetailCell
            cell.txnDetails = self.generalTxDetails[indexPath.row]
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontInputDetailsCell") as! TransactiontInputDetailsCell
            cell.setup(transaction.inputs, presentingController: self)
            cell.expandOrCollapse = { [weak self] in
                self?.tableTransactionDetails.reloadData()
            }
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactiontOutputDetailsCell") as! TransactiontOutputDetailsCell
            cell.setup(transaction.outputs, presentingController: self)
            cell.expandOrCollapse = { [weak self] in
                self?.tableTransactionDetails.reloadData()
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 6 {
            self.copyText(self.transaction.hash)
        }
    }
}
