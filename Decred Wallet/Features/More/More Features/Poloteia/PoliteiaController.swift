//
//  PoliteiaController.swift
//  Decred Wallet
//
//  Created by JustinDo on 8/14/20.
//  Copyright © 2020 Decred. All rights reserved.
//

import Foundation
import UIKit
import Dcrlibwallet

class PoliteiaController: UIViewController {
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var filterCategoryMenu: DropMenuButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var politeiaTableView: UITableView!
    @IBOutlet weak var progressView: PlainHorizontalProgressBar!
    private var refreshControl: UIRefreshControl!
    
    var politeia: DcrlibwalletPoliteia = DcrlibwalletPoliteia()
    var processTimer: Timer?
    var allPoliteia = [Politeia]()
    let limit: Int32 = 20
    var offset: Int32 = 0
    var currentCategory: PoliteiaCategory = .all
    var isLoading: Bool = false
    var isFirstLoad: Bool = true
    var isMore: Bool = true
    
    var noTxsLabel: UILabel {
        let noTxsLabel = UILabel(frame: self.politeiaTableView.frame)
        noTxsLabel.text = LocalizedStrings.noPoliteia
        noTxsLabel.font = UIFont(name: "Source Sans Pro", size: 16)
        noTxsLabel.textColor = UIColor.appColors.lightBluishGray
        noTxsLabel.textAlignment = .center
        return noTxsLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getProposalsPoliteia(category: PoliteiaCategory.all)
        self.setupView()
        self.getArrayFilter()
        self.isFirstLoad = false
    }
    
    func setupView() {
        self.loadingView.isHidden = true
        self.politeiaTableView.autoResizeCell(estimatedHeight: 140)
        self.politeiaTableView.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self,
                                      action: #selector(self.reloadCurrentPoliteia),
                                      for: UIControl.Event.valueChanged)

        self.politeiaTableView.addSubview(self.refreshControl)
    }
    
    func getArrayFilter() {
        guard let politeia = WalletLoader.shared.multiWallet.politeia else {
            print("PoliteiaController.setupFilter get politeia instance false")
            return
        }
        var filterOptions: [String] = []
        
        filterOptions.append(politeia.categoryCount(category: .all))
        filterOptions.append(politeia.categoryCount(category: .pre))
        filterOptions.append(politeia.categoryCount(category: .active))
        filterOptions.append(politeia.categoryCount(category: .approved))
        filterOptions.append(politeia.categoryCount(category: .rejected))
        filterOptions.append(politeia.categoryCount(category: .abandoned))
        
        self.filterCategoryMenu.initMenu(filterOptions) { [weak self] index, value in
//            print("index: \(index) --- value: \(value)")
            if let category = PoliteiaCategory(rawValue: Int32(index+1)) {
                self?.offset = 0
                self?.isMore = true
                self?.getProposalsPoliteia(category: category)
                self?.currentCategory = category
            }
        }
    }
    
    @objc func reloadCurrentPoliteia() {
        self.isMore = true
        self.offset = 0
        self.getProposalsPoliteia(category: self.currentCategory)
    }
    
    func getProposalsPoliteia(category: PoliteiaCategory) {
        if self.isLoading || !self.isMore { return }
        self.isLoading = true
        if isFirstLoad {
//            self.showLoading()
        }
        if self.offset > 0 {
            self.footerView.isHidden = false
        }
        DispatchQueue.global(qos: .userInitiated).async {
            if let politeias = WalletLoader.shared.multiWallet.politeia?.getPoliteias(category: category, offset: self.offset, newestFirst: true), !politeias.isEmpty {
                self.isMore = politeias.count >= 20
                if self.offset > 0 {
                    self.allPoliteia.append(contentsOf: politeias)
                } else {
                    self.allPoliteia.removeAll()
                    self.allPoliteia = politeias
                }
                self.offset += 20
                self.isLoading = false
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.loadingView.isHidden = true
                    self.politeiaTableView.reloadData()
                    self.footerView.isHidden = true
                }
            } else {
                self.isLoading = false
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.loadingView.isHidden = true
                    self.footerView.isHidden = true
                }
            }
        }
    }
    
//    func showLoading() {
//        self.processTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(incrementPercent), userInfo: nil, repeats: true)
//    }

//    @objc func incrementPercent() {
//        self.progressView.progress += 0.05
//        print("process: ", self.progressView.progress)
//        if self.progressView.progress > 1 {
//            self.processTimer?.invalidate()
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
        
        let icon = self.navigationController?.modalPresentationStyle == .fullScreen ?  UIImage(named: "ic_close") : UIImage(named: "left-arrow")
        let closeButton = UIBarButtonItem(image: icon,
                                          style: .done,
                                          target: self,
                                          action: #selector(self.dismissView))
        
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.politeia, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.appColors.darkBlue
        
        self.navigationItem.leftBarButtonItems =  [closeButton, barButtonTitle]
    }
}

extension PoliteiaController: UITableViewDelegate, UITableViewDataSource {
    
    func navigatePoliteiaDetail(politeia: Politeia) {
        let storyboard = UIStoryboard(name: "Politeia", bundle: nil)
        if let politeiaVC = storyboard.instantiateViewController(withIdentifier: "PoliteiaDetailController") as? PoliteiaDetailController {
            politeiaVC.politeia = politeia
            navigationController?.pushViewController(politeiaVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPoliteia.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let politeiaCell = self.politeiaTableView.dequeueReusableCell(withIdentifier: PoliteiaTableViewCell.politeiaIdentifier) as! PoliteiaTableViewCell
        let politeiaItem = self.allPoliteia[indexPath.row]
        politeiaCell.displayInfo(politeiaItem)
        if indexPath.row == self.allPoliteia.count - 1 {
            self.getProposalsPoliteia(category: self.currentCategory)
        }
        return politeiaCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigatePoliteiaDetail(politeia: self.allPoliteia[indexPath.row])
    }
    
}
