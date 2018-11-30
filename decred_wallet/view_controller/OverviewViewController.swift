//
//  OverviewViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import SlideMenuControllerSwift
import Mobilewallet
import MBProgressHUD

class OverviewViewController: UIViewController, MobilewalletGetTransactionsResponseProtocol, MobilewalletTransactionListenerProtocol, MobilewalletBlockNotificationErrorProtocol,
MobilewalletBlockScanResponseProtocol, MobilewalletSpvSyncResponseProtocol {
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbCurrentBalance: UILabel!
    @IBOutlet var viewTableHeader: UIView!
    @IBOutlet var viewTableFooter: UIView!
    @IBOutlet weak var activityIndicator: UIImageView!
    
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
        
        
        connectToDecredNetwork()
        print("adding observer")
        
        SingleInstance.shared.wallet?.transactionNotification(self)
        showActivity()
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
            prepareRecent()
            updateCurrentBalance()
            
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.visible = false
        // self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRescan(_ sender: Any) {
        print("rescaning")
        //AppContext.instance.decrdConnection?.rescan(rescanHeight:0)
        //AppContext.instance.decrdConnection?.rescan(rescanHeight:  UserDefaults.standard.integer(forKey: "rescan_height"))
    }
    
    func connectToDecredNetwork(){
        let appInstance = UserDefaults.standard
        var passphrase = ""
        passphrase = appInstance.string(forKey: "password")!
        //print(appInstance.string(forKey: "passphrase")!)
        let finalPassphrase = passphrase as NSString
        let finalPassphraseData = finalPassphrase .data(using: String.Encoding.utf8.rawValue)!
        
        if(appInstance.integer(forKey: "network_mode") == 0){
            print("starting SPV")
            print("syncing")
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let _ = self else { return }
                do {
                    try
                        SingleInstance.shared.wallet?.spvSync(self, peerAddresses: getPeerAddress(appInstance: appInstance), discoverAccounts: true, privatePassphrase: finalPassphraseData)
                    print("done syncing")
                    
                } catch {
                    print("there was an error")
                    print(error)
                }
            }
        }
        else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let this = self else { return }
                do {
                    try
                        SingleInstance.shared.wallet?.unlock(finalPassphraseData)
                } catch {
                    print(error)
                }
                this.connectToRPCServer()
                // self.updateCurrentBalance()
            }
        }
    }
    
    func connectToRPCServer(){
        let appInstance = UserDefaults.standard
        let certificate = try? Data(contentsOf: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/rpc.cert"))
        let username = UserDefaults.standard.string(forKey: "pref_user_name")
        let password = UserDefaults.standard.string(forKey: "pref_user_passwd")
        let address  = UserDefaults.standard.string(forKey: "pref_server_ip")
        guard certificate != nil else {print("no certificate"); return }
        let pHeight = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        pHeight.pointee = -1
        
        var i:Int = 0
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let _ = self else { return }
            
            do {
                while true {
                    do {
                        i += 1
                        print("connecting attempt".appending(String(i)))
                        try
                            SingleInstance.shared.wallet?.startRPCClient(address, rpcUser: username, rpcPass: password, certs: certificate)
                        break
                        
                    } catch {
                        print("RPC Connection Failed:")
                        print(error)
                    }
                    Thread.sleep(forTimeInterval: 2.5) }
                print("Subscribe to block notification")
                try
                    SingleInstance.shared.wallet?.subscribe(toBlockNotifications: self)
                print("discovering Used Address")
                try
                    SingleInstance.shared.wallet?.discoverActiveAddresses()
                try
                    SingleInstance.shared.wallet?.loadActiveDataFilters()
                print("fetching headers")
                
                try SingleInstance.shared.wallet?.fetchHeaders(pHeight)
                print("pointer at")
                print(pHeight.pointee)
                if pHeight.pointee != -1 {
                    print(pHeight.pointee)
                    appInstance.set(pHeight.pointee, forKey: "rescan_height")
                }
                print("Publish Unmined Transactions")
                try SingleInstance.shared.wallet?.publishUnminedTransactions()
                print("connected to remote node")
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let this = self else { return }
                    let blockHeight = SingleInstance.shared.wallet?.getBestBlock()
                    print("best block")
                    print(blockHeight as Any)
                    SingleInstance.shared.wallet?.rescan(0, response: this)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32, finished: Bool) {
        
    }
    
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64, finished: Bool) {
        
    }
    
    func onRescanProgress(_ rescannedThrough: Int32, finished: Bool) {
        
    }
    
    func onFetchMissingCFilters(_ missingCFitlersStart: Int32, missingCFitlersEnd: Int32) {
        print("fetching missing filter")
    }
    
    func onBlockAttached(_ height: Int32, timestamp: Int64) {
        
    }
    
    func onBlockAttached(_ height: Int32) {
        
    }
    
    func onDiscoveredAddresses(_ finished: Bool) {
        
    }
    
    func onFetchMissingCFilters(_ fetchedCFiltersCount: Int32) {
        
    }
    
    func onFetchedHeaders(_ fetchedHeadersCount: Int32, lastHeaderTime: Int64) {
        
    }
    
    func onPeerConnected(_ peerCount: Int32) {
        
    }
    
    func onPeerDisconnected(_ peerCount: Int32) {
        
    }
    
    func onRescanProgress(_ rescannedThrough: Int32) {
        
    }
    
    func updateCurrentBalance(){
        var amount = "0"
        var account = GetAccountResponse()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard self != nil else { return }
            do {
                let strAccount = try SingleInstance.shared.wallet?.getAccounts(0)
                account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
                amount =
                "\((account.Acc.first?.dcrTotalBalance)!)"
                DispatchQueue.main.async {
                    self?.hideActivityIndicator()
                    if(amount != nil){
                        self?.lbCurrentBalance.attributedText = getAttributedString(str: amount, siz: 15.0)
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
                print("done getting transaction")
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
        print("on result")
        if(self.visible == false){
            print("on result returning")
            return
        }
        else{
            let tjson = json
            print("on result running")
            DispatchQueue.main.async {
                do {
                    let trans = GetTransactionResponse.self
                    let transactions = try JSONDecoder().decode(trans, from: (tjson?.data(using: .utf8)!)!)
                    print("on result decoded")
                    if (transactions.Transactions.count) > 0 {
                        print("on result decoded")
                        if transactions.Transactions.count > self.mainContens.count {
                            print(transactions.Transactions.count)
                            print("new transaction OnResult")
                            print(self)
                            self.mainContens.removeAll()
                            print("decoding")
                            for transactionPack in transactions.Transactions {
                                self?.mainContens.append(transactionPack)
                                /* for creditTransaction in transactionPack.Credits {
                                 this.mainContens.append("\(creditTransaction.dcrAmount) DCR")
                                 }
                                 for debitTransaction in transactionPack.Debits {
                                 this.mainContens.append("-\(debitTransaction.dcrAmount) DCR")
                                 }*/
                            }
                            self.mainContens.reverse()
                            self.tableView.reloadData()
                            self.updateCurrentBalance()
                        }
                    }
                    return
                    
                } catch let error {
                    print("onresult error")
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
        print("synced wallet")
        UserDefaults.standard.set(false, forKey: "walletScanning")
        UserDefaults.standard.set(synced, forKey: "synced")
        UserDefaults.standard.synchronize()
        if(self.visible == false){
            return
        }
        if(synced == true){
            if(visible == true){
                self.prepareRecent()
                self.updateCurrentBalance()
            }
        }
    }
    
    func onBlockNotificationError(_ err: Error!) {
        print("Block notify error")
        print(err)
    }
    
    func onTransactionConfirmed(_ hash: String!, height: Int32) {
        print("incoming")
        if(visible == true){
            updateCurrentBalance()
        }
    }
    
    func onEnd(_ height: Int32, cancelled: Bool) {
        
    }
    
    func onError(_ code: Int32, message: String!) {
        
    }
    
    func onScan(_ rescannedThrough: Int32) -> Bool {
        UserDefaults.standard.set(true, forKey: "walletScanning")
        return true
    }
    
    func onTransactionRefresh() {
        print("refresh")
        
    }
    
    func onTransaction(_ transaction: String!) {
        print("New transaction for onTransaction")
        
        if(visible == false){
            return
        }
        /*   for creditTransaction in transactions.Credits{
         
         
         }
         for debitTransaction in transactions.Debits{
         self.mainContens.append("-\(debitTransaction.dcrAmount) DCR")
         }*/
        let transactions = try! JSONDecoder().decode(Transaction.self, from:transaction.data(using: .utf8)!)
        self.mainContens.append(transactions)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        self.updateCurrentBalance()
        return
    }
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
        return min(self.mainContens.count, 6)
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
}

extension OverviewViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
        
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}
