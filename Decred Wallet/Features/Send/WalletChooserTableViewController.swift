//
//  WalletChooserTableViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class WalletChooserTableViewController: UIViewController {

    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    
    let tableView = UITableView()
    let menuHeight = UIScreen.main.bounds.height / 2
    var isPresenting = false
    var walletAccounts: [WalletAccount]!
    var selectedAccount: WalletAccount?

    var didSelectAccount: ((WalletAccount?)-> Void)?

    init(wallets: [WalletAccount], selected: WalletAccount?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        walletAccounts = wallets
        selectedAccount = selected
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 14.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.heightAnchor.constraint(equalToConstant: menuHeight).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        tableView.registerCellNib(WalletInfoTableViewCell.self)
        tableView.registerCellNib(ModalNavBarCell.self)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        didSelectAccount?(nil)
        dismiss(animated: true)
    }
}

extension WalletChooserTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ModalNavBarCell", for: indexPath) as? ModalNavBarCell else {
                return UITableViewCell()
            }
            cell.configure(with: "Sending Account") {
                self.didSelectAccount?(nil)
                self.dismiss(animated: true, completion: nil)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WalletInfoTableViewCell", for: indexPath) as? WalletInfoTableViewCell else{
                return UITableViewCell()
            }
            let wallet = walletAccounts[indexPath.section - 1]
            cell.configure(with: wallet)
//            if let unWrappedPreviouslySelectedAccount = selectedAccount, wallet.Number == unWrappedPreviouslySelectedAccount.Number {
//                cell.accessoryType = .checkmark
//            }
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return walletAccounts.count + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 44 : 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        didSelectAccount?(walletAccounts[indexPath.section - 1])
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Default"
        } else if section == 2 {
            return "Account 2"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .white
    }
}

extension WalletChooserTableViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            tableView.frame.origin.y += menuHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.tableView.frame.origin.y -= self.menuHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.tableView.frame.origin.y += self.menuHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
