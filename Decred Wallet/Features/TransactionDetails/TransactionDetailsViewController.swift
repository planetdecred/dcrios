//  TransactionDetailsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class TransactionDetailsViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var txTypeLabel: UILabel!
    @IBOutlet weak var transactionDetailsTable: SelfSizedTableView!
    @IBOutlet weak var showOrHideDetailsBtn: UIButton!

    var transactionHash: String?
    var transaction: Transaction!

    var generalTxDetails: [TransactionDetail] = []
    var txOverview: TransactionOverView = TransactionOverView()
    var isTxDetailsTableViewCollapsed: Bool = true
    var isTxInputsCollapsed: Bool = true
    var isTxOutputsCollapsed: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

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

        self.displayTitle()
        self.prepareGeneralTxDetails()
        self.prepareTxOverview()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // calculate maximum height of transactionDetailsTable to take up
        self.transactionDetailsTable.maxHeight = self.view.frame.size.height
            - self.headerView.frame.size.height
            - self.showOrHideDetailsBtn.frame.size.height
            - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
    }

    private func displayTitle() {
        if self.transaction.type == DcrlibwalletTxTypeRegular {
            if self.transaction.direction == DcrlibwalletTxDirectionSent {
                self.txTypeLabel.text = LocalizedStrings.sent
            } else if self.transaction.direction == DcrlibwalletTxDirectionReceived {
                self.txTypeLabel.text = LocalizedStrings.received
            } else if self.transaction.direction == DcrlibwalletTxDirectionTransferred {
                self.txTypeLabel.text = LocalizedStrings.transferred
            }
        } else if self.transaction.type == DcrlibwalletTxTypeVote {
            self.txTypeLabel.text = LocalizedStrings.voted
        } else if self.transaction.type == DcrlibwalletTxTypeTicketPurchase {
            self.txTypeLabel.text = LocalizedStrings.ticket
        }
    }

    private func prepareGeneralTxDetails() {
        let txFee = Utils.getAttributedString(
            str: "\(self.transaction.dcrFee.round(8))",
            siz: 16,
            TexthexColor: UIColor.appColors.darkBlue
        )

        if transaction.type == DcrlibwalletTxTypeRegular {
            if transaction.direction == DcrlibwalletTxDirectionSent {
                if let sourceAccount = self.transaction.sourceAccount {
                    generalTxDetails.append(TransactionDetail(
                        title: LocalizedStrings.fromAccountDetail,
                        value: "\(sourceAccount.capitalizingFirstLetter())",
                        walletName: self.transaction.walletName,
                        isCopyEnabled: false
                    ))
                }
                if let receiveAddress = self.transaction.receiveAddress {
                    generalTxDetails.append(TransactionDetail(
                        title: LocalizedStrings.toDetail,
                        value: "\(receiveAddress)",
                        isCopyEnabled: true
                    ))
                }
            } else if transaction.direction == DcrlibwalletTxDirectionReceived {
                if let sourceAddress = self.transaction.sourceAddress {
                    generalTxDetails.append(TransactionDetail(
                        title: LocalizedStrings.fromDetail,
                        value: "\(sourceAddress)",
                        isCopyEnabled: true
                    ))
                }
                if let receiveAccount = self.transaction.receiveAccount {
                    generalTxDetails.append(TransactionDetail(
                        title: LocalizedStrings.toAccountDetail,
                        value: "\(receiveAccount.capitalizingFirstLetter())",
                        walletName: self.transaction.walletName,
                        isCopyEnabled: false
                    ))
                }
            }
        }

        self.generalTxDetails.append(TransactionDetail(
                title: LocalizedStrings.fee,
                value: txFee.string,
                isCopyEnabled: false
        ))
        self.generalTxDetails.append(TransactionDetail(
                title: LocalizedStrings.includedInBlock,
                value: "\(self.transaction.blockHeight)",
                isCopyEnabled: false
        ))
        self.generalTxDetails.append(TransactionDetail(
                title: LocalizedStrings.type,
                value: self.transaction.type,
                isCopyEnabled: false
        ))
        self.generalTxDetails.append(TransactionDetail(
                title: LocalizedStrings.transactionID,
                value: self.transaction.hash,
                isCopyEnabled: true
        ))

        if self.transaction.type == DcrlibwalletTxTypeTicketPurchase {
            generalTxDetails.append(TransactionDetail(
                title: LocalizedStrings.lastBlockValid,
                value: String(describing: self.transaction.lastBlockValid),
                isCopyEnabled: false
            ))
            generalTxDetails.append(TransactionDetail(
                title: LocalizedStrings.version,
                value: "\(self.transaction.voteVersion)",
                isCopyEnabled: false
            ))
            generalTxDetails.append(TransactionDetail(
                title: LocalizedStrings.voteBits,
                value: self.transaction.voteBits,
                isCopyEnabled: false
            ))
        }
    }

    private func prepareTxOverview() {
        let attributedAmountString = NSMutableAttributedString(string: (transaction.type == DcrlibwalletTxTypeRegular && transaction.direction == DcrlibwalletTxDirectionSent) ? "-" : "")
        attributedAmountString.append(Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 20.0, TexthexColor: UIColor.appColors.darkBlue))
        self.txOverview.txAmount = attributedAmountString

        self.txOverview.date = Utils.formatDateTime(timestamp: transaction.timestamp)

        let txConfirmations = transaction.confirmations
        if Settings.spendUnconfirmed || txConfirmations > 1 {
            self.txOverview.statusImage = UIImage(named: "ic_confirmed")
            self.txOverview.status = LocalizedStrings.confirmed
            self.txOverview.statusLabelColor = UIColor.appColors.green
            self.txOverview.confirmations = " · " + String(format: LocalizedStrings.confirmations, txConfirmations)
        } else {
            self.txOverview.statusImage = UIImage(named: "ic_pending")
            self.txOverview.status = LocalizedStrings.pending
            self.txOverview.statusLabelColor = UIColor.appColors.lightBluishGray
            self.txOverview.confirmations = ""
        }

        if transaction.type == DcrlibwalletTxTypeRegular {
            self.prepareRegularTxOverview(transaction)
        } else if transaction.type == DcrlibwalletTxTypeVote {
            self.prepareVoteTxOverview(transaction)
        } else if transaction.type == DcrlibwalletTxTypeTicketPurchase {
            self.prepareTicketPurchaseTxOverview(transaction)
        }
    }

    private func prepareRegularTxOverview(_ transaction: Transaction) {
        if transaction.direction == DcrlibwalletTxDirectionSent {
            self.txOverview.txIconImage = UIImage(named: "ic_send")
        } else if transaction.direction == DcrlibwalletTxDirectionReceived {
            self.txOverview.txIconImage = UIImage(named: "ic_receive")
        } else if transaction.direction == DcrlibwalletTxDirectionTransferred {
            self.txOverview.txIconImage = UIImage(named: "ic_fee")
        }
    }

    private func prepareVoteTxOverview(_ transaction: Transaction) {
        self.txOverview.txIconImage =  UIImage(named: "ic_ticketImmature")

        let txConfirmations = transaction.confirmations
        let requiredConfirmations = Settings.spendUnconfirmed ? 0 : 2

        if txConfirmations < requiredConfirmations {
            self.txOverview.statusImage = UIImage(named: "ic_pending")
            self.txOverview.status = LocalizedStrings.pending
            self.txOverview.statusLabelColor = UIColor.appColors.lightBluishGray
            self.txOverview.confirmations = ""
        } else if txConfirmations > BuildConfig.TicketMaturity {
            self.txOverview.txIconImage = UIImage(named: "ic_ticketLive")
        } else {
            self.txOverview.txIconImage = UIImage(named: "ic_ticketImmature")
        }
    }

    private func prepareTicketPurchaseTxOverview(_ transaction: Transaction) {
        self.txOverview.txIconImage =  UIImage(named: "ic_ticketVoted")
    }

    @IBAction func onClose(_ sender: Any) {
        self.dismissView()
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
        self.isTxDetailsTableViewCollapsed = !self.isTxDetailsTableViewCollapsed
        self.transactionDetailsTable.reloadData()
        self.showOrHideDetailsBtn.setTitle(self.isTxDetailsTableViewCollapsed ? LocalizedStrings.showDetails : LocalizedStrings.hideDetails, for: .normal)
    }
}

extension TransactionDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.isTxDetailsTableViewCollapsed ? 1 : 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return self.generalTxDetails.count
        } else if section == 2 {
            return self.isTxInputsCollapsed ? 0 : transaction.inputs.count
        } else if section == 3 {
            return self.isTxOutputsCollapsed ? 0 : transaction.outputs.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if section == 2 || section == 3 {
            return 48
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            return self.inputOutputSectionHeaderView(section: section,
                                                        title: String(format: LocalizedStrings.inputsConsumed, transaction.inputs.count),
                                                        isCollapsed: self.isTxInputsCollapsed)
        } else if section == 3 {
            return self.inputOutputSectionHeaderView(section: section,
                                                        title: String(format: LocalizedStrings.outputsCreated, transaction.outputs.count),
                                                        isCollapsed: self.isTxOutputsCollapsed)
        } else {
            let headerView = UIView.init(frame: CGRect.zero)
            headerView.backgroundColor = UIColor.appColors.gray
            headerView.frame.size.height = 1
            return headerView
        }
    }

    private func inputOutputSectionHeaderView(section: Int,
                                                 title: String,
                                                 isCollapsed: Bool) -> UIView {
        let transactionDetailsTableWidth = self.transactionDetailsTable.frame.size.width

        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: transactionDetailsTableWidth, height: 48))
        headerView.backgroundColor = UIColor.white
        headerView.horizontalBorder(borderColor: UIColor.appColors.gray, yPosition: 0, borderHeight: 1)

        let headerLabel = UILabel.init(frame: CGRect(x: 16, y: 1, width: transactionDetailsTableWidth - 56, height: 47))
        headerLabel.textColor = UIColor.appColors.bluishGray
        headerLabel.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        headerLabel.numberOfLines = 1
        headerLabel.text = title
        headerView.addSubview(headerLabel)

        let arrowImageView = UIImageView.init(frame: CGRect(x: transactionDetailsTableWidth - 40, y: 12, width: 24, height: 24))
        let arrowImage = UIImage(named: "ic_expand")
        if isCollapsed {
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

        if section == 2 {
            self.isTxInputsCollapsed.toggle()
            self.transactionDetailsTable.reloadData()
        } else if section == 3 {
            self.isTxOutputsCollapsed.toggle()
            self.transactionDetailsTable.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionOverviewCell") as! TransactionOverviewCell
            cell.display(self.txOverview)
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailCell") as! TransactionDetailCell
            cell.txDetail = self.generalTxDetails[indexPath.row]
            cell.onTxDetailValueCopied = { copiedDetail in
                Utils.showBanner(in: self.view.subviews.first!, type: .success, text: String(format: LocalizedStrings.sgCopied, copiedDetail))
            }
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionInputDetailCell") as! TransactionInputDetailCell
            cell.display(transaction.inputs[indexPath.row])
            cell.onTxHashCopied = {
                Utils.showBanner(in: self.view.subviews.first!, type: .success, text: LocalizedStrings.previousOutpointCopied)
            }
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionOutputDetailCell") as! TransactionOutputDetailCell
            cell.display(transaction.outputs[indexPath.row])
            cell.onTxHashCopied = {
                Utils.showBanner(in: self.view.subviews.first!, type: .success, text: LocalizedStrings.addrCopied)
            }
            return cell

        case 4:
            return tableView.dequeueReusableCell(withIdentifier: "TransactionViewOnDcrdataCell")!

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            if BuildConfig.IsTestNet {
                self.openLink(urlString: "https://testnet.dcrdata.org/tx/\(self.transaction.hash)")
             } else {
                self.openLink(urlString: "https://dcrdata.decred.org/tx/\(self.transaction.hash)")
            }
        }
    }

    func openLink(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
