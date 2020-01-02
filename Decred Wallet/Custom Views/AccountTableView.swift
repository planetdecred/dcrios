//
//  ReceiveAccountListView.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
//

import UIKit
import Dcrlibwallet

class AccountTableView: UIView, UITableViewDelegate, UITableViewDataSource {

    var bgView : UIView?
    var tableView : UITableView?
        
    var listData : [[DcrlibwalletAccount]]?
    
    var selectedAccount: ((DcrlibwalletAccount,String) -> ())?
    
    var hide: (() -> ())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.listData = Array()
        
        self.setAccount()
        
        self.backgroundColor = UIColor.init(hex: "000000", alpha: 0.4)
        
        let tapView = UIView.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height-300))
        self.addSubview(tapView)
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(hideView))
        tapView.addGestureRecognizer(tapGes)
        
        self.bgView = UIView.init(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: 300))
        self.bgView?.backgroundColor = UIColor.white
        self.addSubview(self.bgView!)

        let maskPath = UIBezierPath(roundedRect: self.bgView!.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bgView!.bounds
        maskLayer.path = maskPath.cgPath
        self.bgView?.layer.mask = maskLayer
        
        let closeBtn = UIButton.init(type: .custom)
        closeBtn.frame = CGRect(x: 8, y: 4.5, width: 40, height: 40)
        closeBtn.setImage(UIImage(named: "ic_close"), for: .normal)
        self.bgView?.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(self.hideView), for: .touchUpInside)

        let titleLab = UILabel.init(frame: CGRect(x: closeBtn.frame.maxX+10, y: 0, width: 200, height: 49))
        titleLab.font = .systemFont(ofSize: 20)
        titleLab.textColor = UIColor.init(red: 0.04, green: 0.08, blue: 0.25, alpha: 1)
        titleLab.text = LocalizedStrings.receivingAccount
        self.bgView?.addSubview(titleLab)
        
        let line = UIView.init(frame: CGRect(x: 0, y: titleLab.frame.maxY, width: frame.width, height: 1))
        line.backgroundColor = .init(red: 0.9, green: 0.92, blue: 0.93, alpha: 1)
        self.bgView?.addSubview(line)
        
        self.tableView = UITableView.init(frame: CGRect(x: 0, y: 50, width: frame.width, height: (self.bgView?.frame.height)!-50), style: .grouped)
        self.tableView?.backgroundColor = .white
        self.tableView?.delegate = self as UITableViewDelegate
        self.tableView?.dataSource = self as UITableViewDataSource
        self.bgView?.addSubview(self.tableView!)
        self.tableView?.separatorStyle = .none
        self.tableView?.register(UINib.init(nibName: "AccountTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountTableViewCell")
        
        self.showView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setAccount() {
        let acc = AppDelegate.walletLoader.wallet?.walletAccounts(confirmations: 0)
        
        let defaultAccount = acc?.filter({ $0.isDefault}).first
        if (defaultAccount != nil) {
            let defaultAcc: [DcrlibwalletAccount] = [defaultAccount!]
            self.listData?.append(defaultAcc)
            
            let walletAccountsArr: [DcrlibwalletAccount] = (acc?.filter({!$0.isHidden && $0.number != INT_MAX }))!
            self.listData?.append(walletAccountsArr)
        }else{
           let walletAccountsArr: [DcrlibwalletAccount] = (acc?.filter({!$0.isHidden && $0.number != INT_MAX }))!
           self.listData?.append(walletAccountsArr)
        }
        
        self.tableView?.reloadData()
    }
    
    //MARK: tableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.listData!.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let walletAccountsArr: [DcrlibwalletAccount]? = self.listData![section]
        
        return walletAccountsArr!.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AccountTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as! AccountTableViewCell
        
        let cellBgView: UIView? = UIView.init()
        cellBgView?.backgroundColor = .white
        cell.selectedBackgroundView = cellBgView
        
        let walletAccountsArr: [DcrlibwalletAccount] = (self.listData?[indexPath.section])!
        let  walletAccount = walletAccountsArr[indexPath.row]
        
        cell.setAccount(walletAccount)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let walletAccountsArr: [DcrlibwalletAccount] = (self.listData?[indexPath.section])!
        let  walletAccount = walletAccountsArr[indexPath.row]

        let walletName = indexPath.section==0 ? "Default":"Wallets"
        
        self.selectedAccount!(walletAccount,walletName)
        
        self.hideView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        header.backgroundColor = .white
        
        let lab = UILabel.init(frame: CGRect(x: 16, y: 14, width: tableView.frame.width-30, height: 16))
        lab.font = .systemFont(ofSize: 14)
        lab.textColor = .init(red: 0.24, green: 0.35, blue: 0.45, alpha: 1)
        lab.text = section==0 ? "Deafult":"Wallets"
        header.addSubview(lab)
        
        return header
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    @objc func hideView() {
        self.hide!()
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView?.frame = CGRect(x: 0, y: self.frame.height, width: (self.bgView?.frame.width)!, height: (self.bgView?.frame.height)!)
        }, completion: { (isFinsh) in
            
            self.isHidden = true
        })
    }
    func showView() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView?.frame = CGRect(x: 0, y: self.frame.height-(self.bgView?.frame.height)!, width: (self.bgView?.frame.width)!, height: (self.bgView?.frame.height)!)
        }, completion: { (isFinsh) in
        })
    }
}
