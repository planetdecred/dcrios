//  AccountViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

protocol  AccountDetailsCellProtocol{
    func setup(account:AccountsEntity)
}



class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    var myBalances:[AccountsData] = [AccountsData]()
    var account :GetAccountResponse?
    var visible = false

    @IBOutlet var tableAccountData: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("account loaded")
        tableAccountData
            .hideEmptyAndExtraRows()
            .registerCellNib(AccountDataCell.self)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        navigationItem.title = "Account"
         print("account will appear")
       // self.account = AppContext.instance.decrdConnection?.getAccounts()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.visible = false
      // self.dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("disposing mem")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.visible = true
        prepareData()
       
    }

    func prepareData(){
        if !(self.isViewLoaded){
            return
        }
        if(visible == false)
        {
            return
        }
        DispatchQueue.global(qos: .background).async{
        self.account?.Acc.removeAll()
        self.myBalances.removeAll()
            do{
                let strAccount = try AppContext.instance.decrdConnection?.wallet?.getAccounts(0)
                self.account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
                self.myBalances = {
                    let colors = [#colorLiteral(red: 0.1807299256, green: 0.8454471231, blue: 0.6397696137, alpha: 1),#colorLiteral(red: 0.1593483388, green: 0.4376987219, blue: 1, alpha: 1),#colorLiteral(red: 0.992682755, green: 0.4418484569, blue: 0.2896475494, alpha: 1),#colorLiteral(red: 0.9992011189, green: 0.7829756141, blue: 0.3022021651, alpha: 1),#colorLiteral(red: 0.7991421819, green: 0.7997539639, blue: 0.7992369533, alpha: 1)]
                    var colorCount = -1
                    return self.account!.Acc.map({
                        colorCount += 1
                        return AccountsData(entity: $0, color: colors[colorCount])
                    })
                    
                }()
            } catch let error{
                print(error)
            }
        
            DispatchQueue.main.async {
                print("refreshing list")
                self.tableAccountData.reloadData()
            }
        }
    }


    func numberOfSections(in _: UITableView) -> Int {
         print("account returning number of section")
        return myBalances.count
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AccountsHeaderView.loadNib()
        print("account inputing headerView data")
        let data = myBalances[section]
        headerView.hightLithColor = data.color
        headerView.title = data.title
        headerView.totalBalance = data.totalBalance
        headerView.spendableBalance = data.spendableBalance
        headerView.headerIndex = section

        headerView.exapndOrCollapse = { [weak self] index in
            guard let strongSelf = self else { return }

            strongSelf.myBalances[index].isExpanded.toggle()
            strongSelf.tableAccountData.reloadData()
        }
        print("account returning header view")
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (myBalances[section].isExpanded == true) ? 1 : 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 540.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt rowIndex: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountDataCell") as! AccountDetailsCellProtocol
        print("account creating cells")
        cell.setup(account:(self.account!.Acc[rowIndex.row]))
        return cell as! UITableViewCell
    }
}
