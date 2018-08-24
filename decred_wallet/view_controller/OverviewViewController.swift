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
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbCurrentBalance: UILabel!
    @IBOutlet var viewTableHeader: UIView!
    @IBOutlet var viewTableFooter: UIView!
    var progressHud = MBProgressHUD()
    var visible = false
    var scanning = false
    var synced = false
   
    
    var mainContens = [Transaction]()
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(OverviewViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.lightGray
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerCellNib(DataTableViewCell.self)
        self.tableView.tableHeaderView = viewTableHeader
        self.tableView.tableFooterView = viewTableFooter
        
        self.tableView.addSubview(self.refreshControl)
        
        
           connectToDecredNetwork()
            print("adding observer")
        AppContext.instance.decrdConnection?.wallet?.transactionNotification(self)
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("low memory")
        //AppContext.instance.decrdConnection?.wallet?.runGC()
        // Dispose of any resources that can be recreated.
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
            updateCurrentBalance()
            prepareRecent()
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
        print(appInstance.string(forKey: "passphrase")!)
        let finalPassphrase = passphrase as NSString
        let finalPassphraseData = finalPassphrase .data(using: String.Encoding.utf8.rawValue)!
        
        if(appInstance.integer(forKey: "network_mode") == 0){
            print("starting SPV")
            print("syncing")
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let _ = self else { return }
                do {
                    try
                        AppContext.instance.decrdConnection?.wallet?.spvSync(self, peerAddresses: getPeerAddress(appInstance: appInstance), discoverAccounts: true, privatePassphrase: finalPassphraseData)
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
                        AppContext.instance.decrdConnection?.wallet?.unlock(finalPassphraseData)
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
                            AppContext.instance.decrdConnection?.wallet?.startRPCClient(address, rpcUser: username, rpcPass: password, certs: certificate)
                        break
                        
                    } catch {
                        print("RPC Connection Failed:")
                        print(error)
                    }
                    Thread.sleep(forTimeInterval: 2.5) }
                print("Subscribe to block notification")
                try
                    AppContext.instance.decrdConnection?.wallet?.subscribe(toBlockNotifications: self)
                print("discovering Used Address")
                try
                    AppContext.instance.decrdConnection?.wallet?.discoverActiveAddresses()
                try
                    AppContext.instance.decrdConnection?.wallet?.loadActiveDataFilters()
                print("fetching headers")
                
                try AppContext.instance.decrdConnection?.wallet?.fetchHeaders(pHeight)
                print("pointer at")
                print(pHeight.pointee)
                if pHeight.pointee != -1 {
                    print(pHeight.pointee)
                    appInstance.set(pHeight.pointee, forKey: "rescan_height")
                }
                print("Publish Unmined Transactions")
                try AppContext.instance.decrdConnection?.wallet?.publishUnminedTransactions()
                print("connected to remote node")
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let this = self else { return }
                    let blockHeight = AppContext().decrdConnection?.wallet?.getBestBlock()
                    print("best block")
                    print(blockHeight as Any)
                    AppContext().decrdConnection?.wallet?.rescan(0, response: this)
                    
               /* if(appInstance.integer(forKey: "rescan_height") < blockHeight!){
                    AppContext.init().decrdConnection?.wallet?.rescan(self.pHeight.pointee, response: self)
                    print("done")
                     
                }*/
                }
                // rescanBlocks();
                // startBlockUpdate();
            } catch {
                print(error)
            }
        }
    }

    
    func updateCurrentBalance(){
        var amount = "0"
        var account :GetAccountResponse?
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let this = self else { return }
            do {
                let strAccount = try AppContext.instance.decrdConnection?.wallet?.getAccounts(0)
                account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
                amount =
                    "\((account?.Acc.first?.dcrTotalBalance)!) DCR"
            } catch let error {
                print(error)
            }
            DispatchQueue.main.async {
                self?.lbCurrentBalance.attributedText = getAttributedString(str: amount)
            }
        }
        
    }
    
    
    func prepareRecent(){
        self.mainContens.removeAll()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let this = self else { return }
            do {
                try
                    AppContext.instance.decrdConnection?.wallet?.getTransactions(this)
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
            print("on result running")
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                do {
                    let trans = GetTransactionResponse.self
                    let transactions = try JSONDecoder().decode(trans, from: json.data(using: .utf8)!)
                    print("on result decoded")
                    if (transactions.Transactions.count) > 0 {
                        print("on result decoded")
                        if transactions.Transactions.count > this.mainContens.count {
                            print(transactions.Transactions.count)
                            print("new transaction OnResult")
                            print(this.mainContens.count)
                            this.mainContens.removeAll()
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
                            this.mainContens.reverse()
                            this.tableView.reloadData()
                            this.updateCurrentBalance()
                        }
                    }
                    
                } catch let error {
                    print("onresult error")
                    print(error)
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
        if(self.visible == false){
            return
        }
        if(synced == true){
            self.prepareRecent()
            self.updateCurrentBalance()
        }
        
        
    }
    
    func onBlockNotificationError(_ err: Error!) {
        print("Block notify error")
        print(err)
    }
    
    func onTransactionConfirmed(_ hash: String!, height: Int32) {
        print("incoming")
        updateCurrentBalance()
   
        
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
        
        let transactions = try! JSONDecoder().decode(Transaction.self, from:transaction.data(using: .utf8)!)
        self.mainContens.append(transactions)
     /*   for creditTransaction in transactions.Credits{
            
            
        }
        for debitTransaction in transactions.Debits{
            self.mainContens.append("-\(debitTransaction.dcrAmount) DCR")
        }*/
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        self.updateCurrentBalance()
    }
}

extension OverviewViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DataTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TransactionFullDetailsViewController", bundle: nil)
        let subContentsVC = storyboard.instantiateViewController(withIdentifier: "TransactionFullDetailsViewController") as! TransactionFullDetailsViewController
        subContentsVC.transaction = self.mainContens[indexPath.row]
        
        self.navigationController?.pushViewController(subContentsVC, animated: true)
    }
}

extension OverviewViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(self.mainContens.count, 4)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: DataTableViewCell.identifier) as! DataTableViewCell
        print("about to crash")
        let data = DataTableViewCellData(trans: self.mainContens[indexPath.row])
        print("pass")
        cell.setData(data)
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
