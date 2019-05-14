////
////  OverviewViewController.swift
////  Decred Wallet
//
//// Copyright (c) 2018-2019 The Decred developers
//// Use of this source code is governed by an ISC
//// license that can be found in the LICENSE file.
//
//import SlideMenuControllerSwift
//import Dcrlibwallet
//import JGProgressHUD
//import UserNotifications
//
//class OverviewViewControllerOld: UIViewController, DcrlibwalletTransactionListenerProtocol, DcrlibwalletBlockScanResponseProtocol, DcrlibwalletSpvSyncResponseProtocol {
//
//    var pinInput: String?
//    var reScan_percentage = 0.1;
//    var discovery_percentage = 0.8
//    var peerCount = 0
//    var bestBlock :Int32?
//    var bestBlockTimestamp : Int64?
//    @IBOutlet weak var syncProgressbar: UIProgressView!
//    @IBOutlet weak var syncContainer: UIView!
//    @IBOutlet weak var topAmountContainer: UIStackView!
//    @IBOutlet weak var bottomBtnContainer: UIStackView!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var lbCurrentBalance: UILabel!
//    @IBOutlet var viewTableHeader: UIView!
//    @IBOutlet var viewTableFooter: UIView!
//    @IBOutlet weak var activityIndicator: UIImageView!
//    @IBOutlet weak var SendBtn: UIButton!
//    @IBOutlet weak var showAllTransactionBtn: UIButton!
//    @IBOutlet weak var connetStatus: UIButton!
//    @IBOutlet weak var chainStatusText: UIButton!
//    @IBOutlet weak var daysbeindText: UIButton!
//    @IBOutlet weak var peersSyncText: UILabel!
//
//    @IBOutlet weak var tapViewMoreBtn: UIButton!
//    @IBOutlet weak var percentageComplete: UILabel!
//    @IBOutlet weak var ReceiveBtn: UIButton!
//    var visible = false
//    var scanning = false
//    var synced = false
//    var showAllSyncInfo = false
//    var recognizer:UIGestureRecognizer?
//    var recognizer2 : UIGestureRecognizer?
//    var recognizer3 : UIGestureRecognizer?
//    var recognizer4 : UIGestureRecognizer?
//    @IBOutlet weak var connectStatusCont: UIStackView!
//    @IBOutlet weak var chainStatusCont: UIStackView!
//    @IBOutlet weak var verboseContainer: UIView!
//    @IBOutlet weak var verboseText: UIButton!
//    @IBOutlet weak var dummyVerboseCont: UIView!
//    @IBOutlet weak var syncLoadingText: UILabel!
//    var wallet = SingleInstance.shared.wallet
//    var walletInfo = SingleInstance.shared
//    var NetType = "mainnet"
//    var mainContens = [Transaction]()
//    var refreshControl: UIRefreshControl!
//
//    func onTransactionConfirmed(_ hash: String?, height: Int32) {
//        if(visible == true){
//            self.prepareRecent()
//            updateCurrentBalance()
//        }
//    }
//
//    func onTransaction(_ transaction: String?) {
//
//        print("New transaction for onTransaction")
//        var transactions = try! JSONDecoder().decode(Transaction.self, from:(transaction?.data(using: .utf8)!)!)
//
//        if(self.mainContens.contains(where: { $0.Hash == transactions.Hash })){
//            return
//        }
//
//        self.mainContens.append(transactions)
//
//        if(transactions.Fee == 0 && UserDefaults.standard.bool(forKey: "pref_notification_switch") == true){
//            let content = UNMutableNotificationContent()
//            content.title = "New Transaction"
//            let tnt = Decimal(transactions.Amount / 100000000.00) as NSDecimalNumber
//            content.body = "You received ".appending(tnt.round(8).description).appending(" DCR")
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//            let request = UNNotificationRequest(identifier: "TxnIdentifier", content: content, trigger: trigger)
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//        }
//
//        transactions.Animate = true
//        DispatchQueue.main.async {
//            self.mainContens.reverse()
//
//            self.mainContens.append(transactions)
//            self.mainContens.reverse()
//            if(self.visible == false){
//                return
//            }
//            self.tableView.reloadData()
//        }
//
//        self.updateCurrentBalance()
//        return
//    }
//
//    func updatePeerCount() {
//        if (!self.walletInfo.synced && !self.walletInfo.syncing) {
//            self.walletInfo.syncStatus = "Not Synced";
//            return
//    }
//        if (!self.walletInfo.syncing) {
//            if (self.walletInfo.peers == 1) {
//                self.walletInfo.syncStatus = "Synced with 1 peer";
//
//            } else {
//                self.walletInfo.syncStatus = "Synced with \(self.walletInfo.peers) peers "
//                }
//
//        }else {
//            if (self.walletInfo.peers == 1) {
//                self.walletInfo.syncStatus = "Synced with 1 peer"
//
//            } else {
//                 self.walletInfo.syncStatus = "Synced with \(self.walletInfo.peers) peers "
//            }
//        }
//    }

//    func onBlockAttached(_ height: Int32, timestamp: Int64) {
//        self.bestBlock = height;
//        self.bestBlockTimestamp = timestamp / 1000000000;
//        if (!self.walletInfo.syncing) {
//            let status =  "latest Block \(String(describing: bestBlock))"
//            self.walletInfo.ChainStatus = status
//           self.updateCurrentBalance()
//            self.walletInfo.bestBlockTime = "\(String(describing: bestBlockTimestamp))"
//            }
//
//    }
