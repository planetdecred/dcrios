//  TransactionDetailsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit
import Dcrlibwallet
import SafariServices

class TransactionDetailsViewController: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var txIconImageView: UIImageView!
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var confirmationsLabel: UILabel!
    @IBOutlet private weak var transactionDetailsTable: SelfSizedTableView!
    @IBOutlet weak var showOrHideDetailsBtn: UIButton!

    var transactionHash: String?
    var transaction: Transaction!

    var generalTxDetails: [TransactionDetail] = []
    var isTxInputsCollapsed: Bool = true
    var isTxOutputsCollapsed: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.transactionDetailsTable.isHidden = true
        self.transactionDetailsTable.hideEmptyAndExtraRows()
        self.showOrHideDetailsBtn.addBorder(atPosition: .top, color: UIColor.appColors.gray, thickness: 1)

        if self.transaction == nil && self.transactionHash != nil {
            let txHash = Data(fromHexEncodedString: self.transactionHash!)!
            var getTxError: NSError?
            let txJsonString = WalletLoader.shared.firstWallet?.getTransaction(txHash, error: &getTxError)
            if getTxError != nil {
                print("wallet.getTransaction error", getTxError!.localizedDescription)
            }

            do {
                self.transaction = try JSONDecoder().decode(Transaction.self, from: (txJsonString!.utf8Bits))
            } catch let error {
                print("decode transaction error:", error.localizedDescription)
            }
        }

        self.prepareTransactionDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // calculate maximum height of transactionDetailsTable to take up
        self.transactionDetailsTable.maxHeight = self.view.frame.size.height
            - self.view.frame.origin.y
            - self.headerView.frame.size.height
            - self.showOrHideDetailsBtn.frame.size.height
            - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)

        self.displayTransactionDetails()
    }

    private func prepareTransactionDetails() {
        let txFee = Utils.getAttributedString(
            str: "\(self.transaction.dcrFee.round(8))",
            siz: 16,
            TexthexColor: UIColor.appColors.darkBlue
        )

        self.generalTxDetails = [
            TransactionDetail(
                title: LocalizedStrings.fee,
                value: txFee.string,
                isCopyEnabled: false
            ),
            TransactionDetail(
                title: LocalizedStrings.type,
                value: self.transaction.type,
                isCopyEnabled: false
            ),
            TransactionDetail(
                title: LocalizedStrings.includedInBlock,
                value: "\(self.transaction.blockHeight)",
                isCopyEnabled: false
            ),
            TransactionDetail(
                title: LocalizedStrings.transactionID,
                value: self.transaction.hash,
                isCopyEnabled: true
            )
        ]

        if self.transaction.type == DcrlibwalletTxTypeTicketPurchase {
            let lastBlockValid = TransactionDetail(
                title: LocalizedStrings.lastBlockValid,
                value: String(describing: self.transaction.lastBlockValid),
                isCopyEnabled: false
            )
            generalTxDetails.append(lastBlockValid)

            let voteVersion = TransactionDetail(
                title: LocalizedStrings.version,
                value: "\(self.transaction.voteVersion)",
                isCopyEnabled: false
            )
            generalTxDetails.append(voteVersion)

            let voteBits = TransactionDetail(
                title: LocalizedStrings.voteBits,
                value: self.transaction.voteBits,
                isCopyEnabled: false
            )
            generalTxDetails.append(voteBits)
            self.txAmountLabel.attributedText = Utils.getAttributedString(
                str: "\(self.transaction.dcrAmount.round(8))",
                siz: 20,
                TexthexColor: UIColor.appColors.darkBlue
            )
        }
    }

    private func displayTransactionDetails() {
        let txConfirmations = transaction.confirmations

        let attributedAmountString = NSMutableAttributedString(string: (self.transaction.type == DcrlibwalletTxTypeRegular && self.transaction.direction == DcrlibwalletTxDirectionSent) ? "-" : "")
        attributedAmountString.append(Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 20.0, TexthexColor: UIColor.appColors.darkBlue))
        self.txAmountLabel.attributedText = attributedAmountString

        self.dateLabel.text = Utils.formatDateTime(timestamp: self.transaction.timestamp)

        if Settings.spendUnconfirmed || txConfirmations > 1 {
            self.statusImageView.image = UIImage(named: "ic_confirmed")
            self.statusLabel.text = LocalizedStrings.confirmed
            self.statusLabel.textColor = UIColor.appColors.green
            self.confirmationsLabel.text = " · " + String(format: LocalizedStrings.confirmations, txConfirmations)
        } else {
            self.statusImageView.image = UIImage(named: "ic_pending")
            self.statusLabel.text = LocalizedStrings.pending
            self.statusLabel.textColor = UIColor.appColors.lightBluishGray
            self.confirmationsLabel.text = ""
        }

        if self.transaction.type == DcrlibwalletTxTypeRegular {
            self.displayRegularTxInfo(self.transaction)
        } else if self.transaction.type == DcrlibwalletTxTypeVote {
            self.displayVoteTxInfo(self.transaction)
        } else if self.transaction.type == DcrlibwalletTxTypeTicketPurchase {
            self.displayTicketPurchaseInfo(self.transaction)
        }
    }

    func displayRegularTxInfo(_ transaction: Transaction) {
        if self.transaction.direction == DcrlibwalletTxDirectionSent {
            self.titleLabel.text = LocalizedStrings.sent
            self.txIconImageView.image = UIImage(named: "ic_send")
        } else if self.transaction.direction == DcrlibwalletTxDirectionReceived {
            self.titleLabel.text = LocalizedStrings.received
            self.txIconImageView.image = UIImage(named: "ic_receive")
        } else if transaction.direction == DcrlibwalletTxDirectionTransferred {
            self.titleLabel.text = LocalizedStrings.transferred
            self.txIconImageView.image = UIImage(named: "ic_fee")
        }
    }

    func displayTicketPurchaseInfo(_ transaction: Transaction) {
        self.titleLabel.text = LocalizedStrings.voted
        self.txIconImageView.image =  UIImage(named: "ic_ticketVoted")
    }

    func displayVoteTxInfo(_ transaction: Transaction) {
        self.titleLabel.text = LocalizedStrings.ticket
        self.txIconImageView.image =  UIImage(named: "ic_ticketImmature")

        let txConfirmations = transaction.confirmations
        let requiredConfirmations = Settings.spendUnconfirmed ? 0 : 2

        if txConfirmations < requiredConfirmations {
            self.statusImageView.image = UIImage(named: "ic_pending")
            self.statusLabel.text = LocalizedStrings.pending
            self.statusLabel.textColor = UIColor.appColors.lightBluishGray
            self.confirmationsLabel.text = ""
        } else if txConfirmations > BuildConfig.TicketMaturity {
            self.txIconImageView.image = UIImage(named: "ic_ticketLive")
        } else {
            self.txIconImageView.image = UIImage(named: "ic_ticketImmature")
        }
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func openLink(urlString: String) {
        //TODO
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
//            let viewController = SFSafariViewController(url: url)
//            viewController.delegate = self as SFSafariViewControllerDelegate
//            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    @IBAction func showInfo(_ sender: Any) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: LocalizedStrings.howToCopy,
                                                    message: "",
                                                    preferredStyle: UIAlertController.Style.alert)

            let blueTextColorStyle = AttributedStringStyle(tag: "blue",
                                                           font: UIFont.systemFont(ofSize: 14),
                                                           color: UIColor.appColors.lightBlue)

            let defaultTextStyle = AttributedStringStyle(font: UIFont.systemFont(ofSize: 14),
                                                         color: UIColor.appColors.deepGray)

            let infoMessage = Utils.styleAttributedString(LocalizedStrings.tapOnBlueText,
                                                           styles: [blueTextColorStyle],
                                                           defaultStyle: defaultTextStyle)

            alertController.setValue(infoMessage, forKey: "attributedMessage")
            alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt,
                                                    style: UIAlertAction.Style.default,
                                                    handler: nil))

            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func showOrHideDetails(_ sender: Any) {
        self.transactionDetailsTable.isHidden = !self.transactionDetailsTable.isHidden
        self.showOrHideDetailsBtn.setTitle(self.transactionDetailsTable.isHidden ? LocalizedStrings.showDetails : LocalizedStrings.hideDetails, for: .normal)
    }
}

extension TransactionDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.generalTxDetails.count
        } else if section == 1 {
            return self.isTxInputsCollapsed ? 0 : transaction.inputs.count
        } else if section == 2 {
            return self.isTxOutputsCollapsed ? 0 : transaction.outputs.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || section == 2 {
            return 48
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return self.getInputOutputSectionHeaderView(section: section,
                                                        title: String(format: LocalizedStrings.inputsConsumed, transaction.inputs.count),
                                                        isCollapsed: self.isTxInputsCollapsed)
        } else if section == 2 {
            return self.getInputOutputSectionHeaderView(section: section,
                                                        title: String(format: LocalizedStrings.outputsCreated, transaction.outputs.count),
                                                        isCollapsed: self.isTxOutputsCollapsed)
        } else {
            let headerView = UIView.init(frame: CGRect.zero)
            headerView.backgroundColor = UIColor.appColors.gray
            headerView.frame.size.height = 1
            return headerView
        }
    }

    private func getInputOutputSectionHeaderView(section: Int,
                                                 title: String,
                                                 isCollapsed: Bool) -> UIView {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 48))
        headerView.backgroundColor = UIColor.white
        headerView.frame.size.height = 48

        let headerSeparator = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1))
        headerSeparator.backgroundColor = UIColor.appColors.gray
        headerView.addSubview(headerSeparator)

        let headerLabel = UILabel.init(frame: CGRect(x: 16, y: 1, width: self.view.frame.size.width - 56, height: 47))
        headerLabel.textColor = UIColor.appColors.bluishGray
        headerLabel.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        headerLabel.numberOfLines = 1
        headerLabel.text = title
        headerView.addSubview(headerLabel)

        let arrowImageView = UIImageView.init(frame: CGRect(x: self.view.frame.size.width - 40, y: 12, width: 24, height: 24))
        let arrowImage = UIImage(named: "ic_collapse")
        if !isCollapsed {
            arrowImageView.image = arrowImage
        } else {
            arrowImageView.image = UIImage(cgImage: (arrowImage?.cgImage!)!, scale: CGFloat(1.0), orientation: .downMirrored)
        }
        headerView.addSubview(arrowImageView)

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(inputOutputSectionHeaderViewTapped(_:))
        )
        headerView.tag = section
        headerView.addGestureRecognizer(tapGestureRecognizer)

        return headerView
    }

    @objc func inputOutputSectionHeaderViewTapped(_ sender: UITapGestureRecognizer?) {
        guard let section = sender?.view?.tag else { return }

        if section == 1 {
            self.isTxInputsCollapsed = !self.isTxInputsCollapsed
            self.transactionDetailsTable.reloadData()
        } else if section == 2 {
            self.isTxOutputsCollapsed = !self.isTxOutputsCollapsed
            self.transactionDetailsTable.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailCell") as! TransactionDetailCell
            cell.txDetail = self.generalTxDetails[indexPath.row]
            cell.onTxDetailValueCopied = { copiedDetail in
                Utils.showBanner(parentVC: self, type: .success, text: String(format: LocalizedStrings.sgCopied, copiedDetail))
            }
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionInputDetailsCell") as! TransactionInputDetailCell
            cell.setup(transaction.inputs[indexPath.row])
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionOutputDetailsCell") as! TransactionOutputDetailCell
            cell.setup(transaction.outputs[indexPath.row])
            return cell

        case 3:
            return tableView.dequeueReusableCell(withIdentifier: "TransactionViewOnDcrdataCell")!

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, let cell = tableView.cellForRow(at: indexPath) as? TransactionInputDetailCell {
            DispatchQueue.main.async {
                UIPasteboard.general.string = cell.txHashLabel.text
                Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.previousOutpointCopied)
            }
        } else if indexPath.section == 2, let cell = tableView.cellForRow(at: indexPath) as? TransactionOutputDetailCell {
            DispatchQueue.main.async {
                UIPasteboard.general.string = cell.txHashLabel.text
                Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.addrCopied)
            }
        } else if indexPath.section == 3 {
            if BuildConfig.IsTestNet {
                self.openLink(urlString: "https://testnet.dcrdata.org/tx/\(self.transaction.hash)")
             } else {
                self.openLink(urlString: "https://dcrdata.decred.org/tx/\(self.transaction.hash)")
            }
        }
    }
}
