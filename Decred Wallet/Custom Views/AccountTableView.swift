//
//  AccountTableView.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
//

import UIKit
import Dcrlibwallet

class AccountTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    let bgViewHeight: CGFloat = 300
    let bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = UIColor.white
        return bgView
    }()
    let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .plain)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(UINib.init(nibName: "AccountTableViewCell", bundle: nil), forCellReuseIdentifier: "AccountTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
        
    var listData = [[DcrlibwalletAccount]]()
    var onAccountSelected: ((_ selectedAccount:DcrlibwalletAccount, _ walletName: String) -> ())?
    var hide: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setAccount()
        
        self.backgroundColor = UIColor.init(hex: "000000", alpha: 0.4)
        
        let tapView = UIView()
        self.addSubview(tapView)
        tapView.translatesAutoresizingMaskIntoConstraints = false
        tapView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        tapView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        tapView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tapView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.bgViewHeight).isActive = true
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(hideView))
        tapView.addGestureRecognizer(tapGes)
        
        self.addSubview(self.bgView)
        self.bgView.translatesAutoresizingMaskIntoConstraints = false
        self.bgView.topAnchor.constraint(equalTo: self.topAnchor, constant: frame.height).isActive = true
        self.bgView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.bgView.heightAnchor.constraint(equalToConstant: self.bgViewHeight).isActive = true
        self.bgView.layer.cornerRadius = 10.0
        self.bgView.isHidden = true
        
        let closeBtn = UIButton.init(type: .custom)
        closeBtn.setImage(UIImage(named: "ic_close"), for: .normal)
        self.bgView.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(self.hideView), for: .touchUpInside)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.topAnchor.constraint(equalTo: self.bgView.topAnchor, constant: 4.5).isActive = true
        closeBtn.leftAnchor.constraint(equalTo: self.bgView.leftAnchor, constant: 8).isActive = true
        closeBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        closeBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let titleLab = UILabel()
        titleLab.font = UIFont(name: "SourceSansPro-Regular", size: 20)
        titleLab.textColor = UIColor.appColors.darkBlue
        titleLab.text = LocalizedStrings.receivingAccount
        self.bgView.addSubview(titleLab)
        titleLab.translatesAutoresizingMaskIntoConstraints = false
        titleLab.topAnchor.constraint(equalTo: self.bgView.topAnchor, constant: 0).isActive = true
        titleLab.leftAnchor.constraint(equalTo: closeBtn.rightAnchor, constant: 10).isActive = true
        titleLab.trailingAnchor.constraint(equalTo: self.bgView.trailingAnchor, constant: -16).isActive = true
        titleLab.heightAnchor.constraint(equalToConstant: 49).isActive = true
        
        let line = UIView()
        line.backgroundColor = UIColor.appColors.gray
        self.bgView.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.topAnchor.constraint(equalTo: titleLab.bottomAnchor, constant: 0).isActive = true
        line.leftAnchor.constraint(equalTo: self.bgView.leftAnchor, constant: 0).isActive = true
        line.trailingAnchor.constraint(equalTo: self.bgView.trailingAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        self.bgView.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 0).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.bgView.leftAnchor, constant: 0).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.bgView.bottomAnchor, constant: 0).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.bgView.trailingAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func setAccount() {
        let acc = AppDelegate.walletLoader.wallet?.walletAccounts(confirmations: 0)
        
        if let defaultAccount = acc?.filter({ $0.isDefault}).first {
            self.listData.append([defaultAccount])
        }
        if let walletAccountsArr = acc?.filter({!$0.isHidden && $0.number != INT_MAX }) {
            self.listData.append(walletAccountsArr)
        }
        
        self.tableView.reloadData()
    }
    
    //MARK: tableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.listData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listData[section].count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AccountTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell", for: indexPath) as! AccountTableViewCell
        
        let cellBgView = UIView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        cellBgView.backgroundColor = .white
        cell.selectedBackgroundView = cellBgView
        
        cell.setAccount(self.listData[indexPath.section][indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let walletAccountsArr: [DcrlibwalletAccount] = (self.listData[indexPath.section])
        let walletAccount = walletAccountsArr[indexPath.row]

        let walletName = indexPath.section==0 ? LocalizedStrings.defaultAccount : LocalizedStrings.wallet
        
        self.onAccountSelected?(walletAccount, walletName)
        
        self.hideView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        header.backgroundColor = .white
        
        let lab = UILabel.init(frame: CGRect(x: 16, y: 14, width: tableView.frame.width-30, height: 16))
        lab.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        lab.textColor = UIColor.appColors.darkBluishGray
        lab.text = section==0 ? LocalizedStrings.defaultAccount : LocalizedStrings.wallet
        header.addSubview(lab)
        
        return header
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    @objc func hideView() {
        self.hide?()
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.frame = CGRect(x: 0, y: self.frame.height, width: self.bgView.frame.width, height: self.bgView.frame.height)
        }, completion: { _ in
            self.isHidden = true
        })
    }
    func showView() {
        self.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.frame = CGRect(x: 0, y: self.frame.height-self.bgViewHeight, width: self.bgView.frame.width, height: self.bgView.frame.height)
        }, completion: {_ in
            self.bgView.isHidden = false
            self.bgView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.frame.height-self.bgViewHeight).isActive = true
        })
    }
}
