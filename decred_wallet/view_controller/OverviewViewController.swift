//
//  OverviewViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import SlideMenuControllerSwift
import Dcrlibwallet
import JGProgressHUD
import UserNotifications

class OverviewViewController: UIViewController, DcrlibwalletGetTransactionsResponseProtocol, DcrlibwalletTransactionListenerProtocol,
DcrlibwalletBlockScanResponseProtocol, DcrlibwalletSpvSyncResponseProtocol,PinEnteredProtocol{
    
    weak var delegate : LeftMenuProtocol?
    var pinInput: String?
    var reScan_percentage = 0.1;
    var discovery_percentage = 0.8
    var peerCount = 0
    var bestBlock :Int32?
    var bestBlockTimestamp : Int64?
    @IBOutlet weak var syncProgressbar: UIProgressView!
    @IBOutlet weak var syncContainer: UIView!
    @IBOutlet weak var topAmountContainer: UIStackView!
    @IBOutlet weak var bottomBtnContainer: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbCurrentBalance: UILabel!
    @IBOutlet var viewTableHeader: UIView!
    @IBOutlet var viewTableFooter: UIView!
    @IBOutlet weak var activityIndicator: UIImageView!
    @IBOutlet weak var SendBtn: UIButton!
    @IBOutlet weak var showAllTransactionBtn: UIButton!
    @IBOutlet weak var connetStatus: UILabel!
    @IBOutlet weak var chainStatusText: UILabel!
    @IBOutlet weak var daysbeindText: UILabel!
    @IBOutlet weak var extraTextAll: UILabel!
    @IBOutlet weak var extraTextElapse: UILabel!
    @IBOutlet weak var stageTimesExtra: UILabel!
    @IBOutlet weak var elapseStage: UILabel!
    @IBOutlet weak var peersSyncText: UILabel!
    
    @IBOutlet weak var percentageComplete: UILabel!
    @IBOutlet weak var ReceiveBtn: UIButton!
    var visible = false
    var scanning = false
    var synced = false
    
    
    var mainContens = [Transaction]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerCellNib(DataTableViewCell.self)
        self.tableView.tableHeaderView = viewTableHeader
        self.tableView.tableFooterView = viewTableFooter
        refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:
                #selector(OverviewViewController.handleRefresh(_:)),
                                     for: UIControlEvents.valueChanged)
            refreshControl.tintColor = UIColor.lightGray
            
            return refreshControl
        }()
        self.tableView.addSubview(self.refreshControl)
        self.setupBtn()
        
        
        connectToDecredNetwork()
        
        SingleInstance.shared.wallet?.transactionNotification(self)
        SingleInstance.shared.wallet?.add(self)
        SingleInstance.shared.syncing = true
        self.switchContainers()
        showActivity()
    }
    func switchContainers(){
        DispatchQueue.main.async {
        self.topAmountContainer.isHidden = !self.topAmountContainer.isHidden
        self.bottomBtnContainer.isHidden = !self.bottomBtnContainer.isHidden
        self.syncContainer.isHidden = !self.syncContainer.isHidden
        self.tableView.isHidden = !self.tableView.isHidden
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("low memory")
        
        // Dispose of any resources that can be recreated.
    }
    
    private func showActivity(){
        lbCurrentBalance.isHidden = true
        let image = UIImage.gifImageWithURL(Bundle.main.url(forResource: "progress bar-1s-200px", withExtension: "gif")?.absoluteString ?? "");
        activityIndicator.image = image
    }
    
    private func hideActivityIndicator(){
        activityIndicator.isHidden = true
        lbCurrentBalance.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Overview"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.visible = true
        if(UserDefaults.standard.bool(forKey: "synced") == true){
            if(self.mainContens.count != 0){
                self.tableView.reloadData()
                updateCurrentBalance()
                return
            }
            self.prepareRecent()
            updateCurrentBalance()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.visible = false
    }
    
    @IBAction func onRescan(_ sender: Any) {
        print("rescaning")
    }
    
    func connectToDecredNetwork(){
        let appInstance = UserDefaults.standard
        var passphrase = ""
      //  passphrase = self.pinInput!
      //  let finalPassphraseData = (passphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        if (appInstance.integer(forKey: "network_mode") == 0) {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let _ = self else { return }
                do {
                    SingleInstance.shared.wallet?.add(self)
                    try
                        SingleInstance.shared.wallet?.spvSync(getPeerAddress(appInstance: appInstance))
                    print("done syncing")
                } catch {
                    print(error)
                }
            }
        } else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let this = self else { return }
              /*  do {
                    try
                     //   SingleInstance.shared.wallet?.unlock(finalPassphraseData)
                } catch {
                    print(error)
                }*/
            }
        }
    }
    
    func updateCurrentBalance(){
        var amount = "0"
        var account = GetAccountResponse()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard self != nil else { return }
            do {
                let strAccount = try SingleInstance.shared.wallet?.getAccounts(0)
                account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
                amount = "\((account.Acc.filter({UserDefaults.standard.bool(forKey: "hidden\($0.Number)") != true}).map{$0.dcrTotalBalance}.reduce(0,+)))"
            
                DispatchQueue.main.async {
                    self?.hideActivityIndicator()
                    if(amount != nil){
                        self?.lbCurrentBalance.attributedText = getAttributedString(str: amount, siz: 17.0, TexthexColor: GlobalConstants.Colors.TextAmount)
                    }
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    func prepareRecent(){
        self.mainContens.removeAll()
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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.prepareRecent()
        refreshControl.endRefreshing()
    }
    
    func onResult(_ json: String!) {
        if (self.visible == false) {
            return
        } else {
            let tjson = json
            DispatchQueue.main.async {
                do {
                    let trans = GetTransactionResponse.self
                    let transactions = try JSONDecoder().decode(trans, from: (tjson?.data(using: .utf8)!)!)
                    if (transactions.Transactions.count) > 0 {
                        if transactions.Transactions.count > self.mainContens.count {
                            print(transactions.Transactions.count)
                            self.mainContens.removeAll()
                            for transactionPack in transactions.Transactions {
                                self.mainContens.append(transactionPack)
                            }
                            self.mainContens.reverse()
                            self.tableView.reloadData()
                            self.updateCurrentBalance()
                        }
                    }
                    return
                    
                } catch let error {
                    print(error)
                    return
                }
            }
        }
    }
    
    func onSyncError(_ code: Int, err: Error!) {
        print("sync error")
        print(err)
    }
    
    func onSynced(_ synced: Bool) {
        
        self.synced = synced
        UserDefaults.standard.set(false, forKey: "walletScanning")
        UserDefaults.standard.set(synced, forKey: "synced")
        UserDefaults.standard.synchronize()
        SingleInstance.shared.synced = synced
        SingleInstance.shared.syncing = false
        if (synced) {
            SingleInstance.shared.syncStartPoint = -1
            SingleInstance.shared.syncEndPoint = -1
            SingleInstance.shared.syncCurrentPoint = -1
            SingleInstance.shared.syncRemainingTime = -1
            SingleInstance.shared.fetchHeaderTime = -1
            SingleInstance.shared.syncStatus = ""
            self.switchContainers()
            if !(self.visible){
                return
            }
            else{
                self.prepareRecent()
                self.updateCurrentBalance()
            }
        }
        
    }
    func setupBtn(){
        ReceiveBtn.layer.cornerRadius = 4
        
        ReceiveBtn.layer.borderWidth = 1.5
        ReceiveBtn.layer.borderColor = UIColor(hex: "#596D81", alpha:0.8).cgColor
        SendBtn.layer.cornerRadius = 4
        SendBtn.layer.borderWidth = 1.5
        SendBtn.layer.borderColor = UIColor(hex: "#596D81", alpha:0.8).cgColor
        showAllTransactionBtn.layer.borderWidth = 1.5
        showAllTransactionBtn.layer.borderColor = UIColor(hex: "#596D81", alpha:0.8).cgColor
        showAllTransactionBtn.layer.cornerRadius = 4
    }
    
    @IBAction func sendView(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.delegate!.changeViewController(LeftMenu.send)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
    }
    @IBAction func receiveView(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.delegate!.changeViewController(LeftMenu.receive)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    @IBAction func historyView(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.delegate!.changeViewController(LeftMenu.history)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    func onBlockNotificationError(_ err: Error!) {
        print(err)
    }
    
    func onTransactionConfirmed(_ hash: String!, height: Int32) {
        if(visible == true){
            self.prepareRecent()
            updateCurrentBalance()
        }
    }
    
    func onEnd(_ height: Int32, cancelled: Bool) {
        
    }
    
    func onError(_ code: Int32, message: String!) {
        
    }
    
    func onScan(_ rescannedThrough: Int32) -> Bool {
        UserDefaults.standard.set(true, forKey: "walletScanning")
        UserDefaults.standard.synchronize()
        return true
    }
    
    func onTransactionRefresh() {
        print("refresh")
    }
    
    func onTransaction(_ transaction: String!) {
        
        print("New transaction for onTransaction")
        var transactions = try! JSONDecoder().decode(Transaction.self, from:transaction.data(using: .utf8)!)
        
        if(self.mainContens.contains(where: { $0.Hash == transactions.Hash })){
            return
        }
        
        self.mainContens.append(transactions)
        
        if(transactions.Fee == 0 && UserDefaults.standard.bool(forKey: "pref_notification_switch") == true){
            let content = UNMutableNotificationContent()
            content.title = "New Transaction"
            let tnt = Decimal(transactions.Amount / 100000000.00) as NSDecimalNumber
            content.body = "You received ".appending(tnt.round(8).description).appending(" DCR")
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "TxnIdentifier", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
        transactions.Animate = true
        DispatchQueue.main.async {
            self.mainContens.reverse()
            
            self.mainContens.append(transactions)
            self.mainContens.reverse()
            if(self.visible == false){
                return
            }
            self.tableView.reloadData()
        }
        
        self.updateCurrentBalance()
        return
    }
    func updatePeerCount() {
        if (!SingleInstance.shared.synced && !SingleInstance.shared.syncing) {
            SingleInstance.shared.syncStatus = "Not Synced";
            return
    }
        if (!SingleInstance.shared.syncing) {
            if (SingleInstance.shared.peers == 1) {
                SingleInstance.shared.syncStatus = "Synced with 1 peer";
                
            } else {
                SingleInstance.shared.syncStatus = "Synced with \(SingleInstance.shared.peers) peers "
                }
            
        }else {
            if (SingleInstance.shared.peers == 1) {
                SingleInstance.shared.syncStatus = "Synced with 1 peer"
                
            } else {
                 SingleInstance.shared.syncStatus = "Synced with \(SingleInstance.shared.peers) peers "
            }
        }
    }
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32, state: String!) {}
    var headerTime: Int64 = 0
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64, state: String!) {
        if (!SingleInstance.shared.syncing) {
            // Ignore this call because this function gets called for each peer and
            // we'd want to ignore those calls as far as the wallet is synced.
            return
        } else if (SingleInstance.shared.totalFetchTime != -1) {
            return
        }
        
        
        print("last header time \(lastHeaderTime)")
        let bestblck = SingleInstance.shared.wallet?.getBestBlock()
        let bestblocktemp = Int64(bestblck!)
        let lastblocktime = SingleInstance.shared.wallet?.getBestBlockTimeStamp()
        let currentTime = Date().millisecondsSince1970 / 1000;
        let estimatedBlocks = ((currentTime - lastblocktime!) / 120 ) + bestblocktemp
        
        switch (state) {
        case DcrlibwalletSTART:
            if (SingleInstance.shared.fetchHeaderTime != -1) {
                return
            }
            
            SingleInstance.shared.syncStatus = "Fetching headers...";
            
            SingleInstance.shared.syncStartPoint = Int64((SingleInstance.shared.wallet?.getBestBlock())!);
            SingleInstance.shared.syncEndPoint = estimatedBlocks - SingleInstance.shared.syncStartPoint;
            SingleInstance.shared.syncCurrentPoint =  SingleInstance.shared.syncStartPoint;
            SingleInstance.shared.fetchHeaderTime = Date().millisecondsSince1970
          //  syncProgressBar.setProgress(0)
          //  syncProgressBar.setVisibility(View.VISIBLE);
            break
        case DcrlibwalletPROGRESS:
            if (self.headerTime == lastHeaderTime ){
                print("returning it")
                return
            }
            self.headerTime = lastHeaderTime
            SingleInstance.shared.syncEndPoint = estimatedBlocks - SingleInstance.shared.syncStartPoint
            SingleInstance.shared.syncCurrentPoint += Int64(fetchedHeadersCount)
            var count = SingleInstance.shared.syncCurrentPoint
            if (SingleInstance.shared.syncStartPoint > 0) {
                count -= SingleInstance.shared.syncStartPoint;
            }
            
            let percent =  Float(count) / Float(SingleInstance.shared.syncEndPoint)
            let totalFetchTime = Double((Date().millisecondsSince1970 - SingleInstance.shared.fetchHeaderTime)) / Double(percent)
            let remainingFetchTime = round(totalFetchTime) - Double((Date().millisecondsSince1970 - SingleInstance.shared.fetchHeaderTime));
            let elapsedFetchTime = Double(Date().millisecondsSince1970 - SingleInstance.shared.fetchHeaderTime)
            
            //10% of fetch time is used for estimating both rescan while 80% is used for address discovery time
            let estimatedRescanTime = totalFetchTime * reScan_percentage;
            let estimatedDiscoveryTime = totalFetchTime * discovery_percentage;
            let totalSyncTime = totalFetchTime + estimatedRescanTime + estimatedDiscoveryTime;
            
            SingleInstance.shared.syncRemainingTime = Int64(round(remainingFetchTime + estimatedRescanTime + estimatedDiscoveryTime));
            SingleInstance.shared.syncProgress = Int(( elapsedFetchTime / totalSyncTime) * 100);
            SingleInstance.shared.syncStatus = "Fetching block headers."
            SingleInstance.shared.bestBlockTime = "\(lastHeaderTime)"
            SingleInstance.shared.ChainStatus = "\(SingleInstance.shared.syncEndPoint - count) blocks behind"
                
            let daysBehind = calculateDays(seconds: ((Date().millisecondsSince1970 / 1000) - lastHeaderTime))
            let status = "Fetched \(count) of \(SingleInstance.shared.syncEndPoint) block headers."
            let status2 = "\(round(percent * 100))% through step 1 of 3."
                SingleInstance.shared.syncStatus = status
            let status3 = " Your wallet is \(daysBehind) behind."
            let percentage = getSyncTimeRemaining(millis: SingleInstance.shared.syncRemainingTime, percentageCompleted: Int(SingleInstance.shared.syncProgress), syncView: true)
            
        
            DispatchQueue.main.async {
                self.connetStatus.text = status
                self.percentageComplete.text = percentage
                self.chainStatusText.text = status2
                self.daysbeindText.text = status3
                self.syncProgressbar.progressTintColor = UIColor(hex: "#55EC7E")
                self.syncProgressbar.progress = (Float(SingleInstance.shared.syncProgress) / 100.0)
                print("progress = \(SingleInstance.shared.syncProgress)")
                self.extraTextAll.text = "All Times"
                self.extraTextElapse.text = "elapsed: \(getTime(millis: Int64(elapsedFetchTime))) remain: \(getTime(millis: SingleInstance.shared.syncRemainingTime)) total: \(getTime(millis: Int64(round(totalSyncTime)))) \n"
                self.stageTimesExtra.text = "Stage Times"
                self.elapseStage.text = "elapsed: \(getTime(millis: Int64(elapsedFetchTime))) remain: \(getTime(millis: Int64(remainingFetchTime)))  total: \(getTime(millis: Int64(round(totalFetchTime))))"
                self.peersSyncText.text = "Syncing with \(self.peerCount) on testnet"
                
            }
           
            
            if (SingleInstance.shared.initialSyncEstimate == -1) {
                SingleInstance.shared.initialSyncEstimate = SingleInstance.shared.syncRemainingTime;
            }
            break
        case DcrlibwalletFINISH:
            updatePeerCount();
            SingleInstance.shared.totalFetchTime = Date().millisecondsSince1970 - SingleInstance.shared.fetchHeaderTime;
            SingleInstance.shared.syncStartPoint = -1;
           SingleInstance.shared.syncEndPoint = -1;
           SingleInstance.shared.syncCurrentPoint = -1;
            break;
        default:
            break
        }
    }
    
    
    func onRescan(_ rescannedThrough: Int32, state: String!) {
        if (SingleInstance.shared.syncEndPoint == -1) {
            SingleInstance.shared.syncEndPoint = Int64(SingleInstance.shared.wallet!.getBestBlock());
        }
        
        switch (state) {
        case DcrlibwalletSTART:
            SingleInstance.shared.syncStatus = "Scanning blocks."
            SingleInstance.shared.syncStartPoint = 0;
            SingleInstance.shared.syncCurrentPoint = 0;
            SingleInstance.shared.syncEndPoint = Int64(SingleInstance.shared.wallet!.getBestBlock());
            SingleInstance.shared.rescanTime = Date().millisecondsSince1970;
            break;
        case DcrlibwalletPROGRESS:
            
            let scannedPercentage = ((Double(rescannedThrough) / Double(SingleInstance.shared.syncEndPoint)) * 100)
            
            let elapsedRescanTime = Date().millisecondsSince1970 - SingleInstance.shared.rescanTime;
            let totalScanTime = Double(elapsedRescanTime) / ((Double(rescannedThrough) / Double(SingleInstance.shared.syncEndPoint)))
            let totalSyncTime = Double(SingleInstance.shared.totalFetchTime) + Double(SingleInstance.shared.totalDiscoveryTime) + totalScanTime
            let elapsedTime = (Double(SingleInstance.shared.totalFetchTime) + Double(SingleInstance.shared.totalDiscoveryTime) + Double(elapsedRescanTime))
            
            SingleInstance.shared.syncRemainingTime = Int64(round(totalScanTime)) - elapsedRescanTime
            SingleInstance.shared.syncProgress = Int((Double(elapsedTime) /  Double(totalSyncTime)) * 100.0)
            let status = "Scanning \(rescannedThrough) of \(SingleInstance.shared.syncEndPoint) block headers."
            let status2 = "\(round(scannedPercentage))% through step 3 of 3."
            SingleInstance.shared.syncStatus = status
            
            let percentage = getSyncTimeRemaining(millis: SingleInstance.shared.syncRemainingTime, percentageCompleted: Int(SingleInstance.shared.syncProgress), syncView: true)
            DispatchQueue.main.async {
                self.syncProgressbar.progressTintColor = UIColor(hex: "#55EC7E")
                self.syncProgressbar.progress = (Float(SingleInstance.shared.syncProgress) / 100.0)
                print("progress = \(SingleInstance.shared.syncProgress)")
                self.percentageComplete.text = percentage
                self.chainStatusText.text = status2
                self.connetStatus.text = status
                self.daysbeindText.text = ""
                self.extraTextAll.text = "All Times"
                self.extraTextElapse.text = "elapsed: \(getTime(millis: Int64(round(Double(elapsedTime))))) remain: \(getTime(millis: SingleInstance.shared.syncRemainingTime)) total: \(getTime(millis: Int64(round(totalSyncTime)))) \n"
                self.stageTimesExtra.text = "Stage Times"
                self.elapseStage.text = "elapsed: \(getTime(millis: Int64(round(Double(elapsedRescanTime))))) remain: \(getTime(millis: SingleInstance.shared.syncRemainingTime))  total: \(getTime(millis: Int64(round(totalScanTime))))"
                self.peersSyncText.text = "Syncing with \(self.peerCount) on testnet"
                
            }
            
            SingleInstance.shared.syncStatus = "Scanning blocks."
            
            break;
        default:
            updatePeerCount();
            break;
        }
    }
    
    func onError(_ err: String!) {}
    
    func onDiscoveredAddresses(_ state: String!) {
       // setChainStatus(null);
        if (state.elementsEqual(DcrlibwalletSTART)) {
                    SingleInstance.shared.accountDiscoveryStartTime = Date().millisecondsSince1970;
                    let estimatedRescanTime = round(Double(SingleInstance.shared.totalFetchTime) * Double(reScan_percentage))
                    let estimatedDiscoveryTime = round(Double(SingleInstance.shared.totalFetchTime) * Double(discovery_percentage));

                    var elapsedDiscoveryTime = Date().millisecondsSince1970 - SingleInstance.shared.accountDiscoveryStartTime;
                    
            var totalSyncTime = 0.0
                    if (Double(elapsedDiscoveryTime) > Double(estimatedDiscoveryTime)) {
                    totalSyncTime = Double(SingleInstance.shared.totalFetchTime) + Double(elapsedDiscoveryTime) + estimatedRescanTime
                    } else {
                    totalSyncTime = Double(SingleInstance.shared.totalFetchTime) + estimatedDiscoveryTime + estimatedRescanTime;
                    }
                    
                   var elapsedTime = Double(SingleInstance.shared.totalFetchTime) + Double(elapsedDiscoveryTime);
                    
                    var remainingAccountDiscoveryTime = round(Double(estimatedDiscoveryTime) - Double(elapsedDiscoveryTime))
                    if (remainingAccountDiscoveryTime < 0) {
                    remainingAccountDiscoveryTime = 0;
                    }
                    
            SingleInstance.shared.syncProgress = Int((Double(elapsedTime) / Double( totalSyncTime)) * 100.0)
            SingleInstance.shared.syncRemainingTime = Int64((remainingAccountDiscoveryTime + estimatedRescanTime))
                  /*  SingleInstance.shared.syncVerbose = getString(R.string.sync_status_verbose, getTime(round(elapsedTime)), getTime(walletData.syncRemainingTime),
                    getTime(round(totalSyncTime)), getTime(Math.round(elapsedDiscoveryTime)),
                    getTime(remainingAccountDiscoveryTime), getTime(estimatedDiscoveryTime));*/
                    
                    SingleInstance.shared.syncStatus = "Discovering used addresses."
            
            let percentage = getSyncTimeRemaining(millis: SingleInstance.shared.syncRemainingTime, percentageCompleted: SingleInstance.shared.syncProgress, syncView: true)
            let status = "Discovering used addresses."
            let discoveryProgress = round((Double(elapsedDiscoveryTime) / Double(estimatedDiscoveryTime)) * 100.0);
            var status2 = ""
            if (discoveryProgress > 100) {
                status2 = "\(discoveryProgress)% through step 2 of 3."
                        } else {
                            status2 = "\(discoveryProgress)% through step 2 of 3."
                        }
            DispatchQueue.main.async {
                self.syncProgressbar.progressTintColor = UIColor(hex: "#55EC7E")
                self.syncProgressbar.progress = (Float(SingleInstance.shared.syncProgress) / 100.0)
                print("progress = \(SingleInstance.shared.syncProgress)")
                self.percentageComplete.text = percentage
                self.chainStatusText.text = status2
                self.connetStatus.text = status
                self.daysbeindText.text = ""
                self.extraTextAll.text = "All Times"
                self.extraTextElapse.text = "elapsed: \(getTime(millis: Int64(round(Double(elapsedTime))))) remain: \(getTime(millis: SingleInstance.shared.syncRemainingTime)) total: \(getTime(millis: Int64(round(totalSyncTime)))) \n"
                self.stageTimesExtra.text = "Stage Times"
                self.elapseStage.text = "elapsed: \(getTime(millis: Int64(round(Double(elapsedDiscoveryTime))))) remain: \(getTime(millis: SingleInstance.shared.syncRemainingTime))  total: \(getTime(millis: Int64(round(totalSyncTime))))"
                self.peersSyncText.text = "Syncing with \(self.peerCount) on testnet"
                
            }
     
        } else {
            
            SingleInstance.shared.totalDiscoveryTime = (Date().millisecondsSince1970 - SingleInstance.shared.accountDiscoveryStartTime);
            updatePeerCount();
        }
    }
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32, finished: Bool) {}
    
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64, finished: Bool) {}
    
    func onRescanProgress(_ rescannedThrough: Int32, finished: Bool) {}
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32) {}
    
    func onBlockAttached(_ height: Int32, timestamp: Int64) {
        self.bestBlock = height;
        self.bestBlockTimestamp = timestamp / 1000000000;
        if (!SingleInstance.shared.syncing) {
            let status =  "latest Block \(String(describing: bestBlock))"
            SingleInstance.shared.ChainStatus = status
           self.updateCurrentBalance()
            SingleInstance.shared.bestBlockTime = "\(String(describing: bestBlockTimestamp))"
            }
        
    }
    
    func onBlockAttached(_ height: Int32) {}
    
    func onDiscoveredAddresses(_ finished: Bool) {}
    
    func onFetchMissingCFilters(_ fetchedCFiltersCount: Int32) {}
    
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64) {
       
    }
    
    func onPeerConnected(_ peerCount: Int32) {
        
        self.peerCount = Int(peerCount)
        UserDefaults.standard.set(self.peerCount, forKey: "peercount")
        UserDefaults.standard.synchronize()
        
    }
    
    func onPeerDisconnected(_ peerCount: Int32) {
        
        self.peerCount = Int(peerCount)
        UserDefaults.standard.set(self.peerCount, forKey: "peercount")
        UserDefaults.standard.synchronize()
        
    }
    
    func onRescanProgress(_ rescannedThrough: Int32) {}
}

extension OverviewViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TransactionFullDetailsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
        print(indexPath.row)
        if self.mainContens.count == 0{
            return
        }
        subContentsVC.transaction = self.mainContens[indexPath.row]
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
    
}

extension OverviewViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(self.mainContens.count, 5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.identifier) as! DataTableViewCell
        if self.mainContens.count != 0{
            let data = DataTableViewCellData(trans: self.mainContens[indexPath.row])
            cell.setData(data)
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(self.mainContens.count != 0){
            if(self.mainContens[indexPath.row].Animate){
                cell.blink()
            }
            self.mainContens[indexPath.row].Animate = false
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
}

extension OverviewViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {}
    
    func leftDidOpen() {}
    
    func leftWillClose() {}
    
    func leftDidClose() {}
    
    func rightWillOpen() {}
    
    func rightDidOpen() {}
    
    func rightWillClose() {}
    
    func rightDidClose() {}
}
extension Date {
    var millisecondsSince1970:Int64 {
         return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

