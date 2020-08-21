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
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var politeiaTableView: UITableView!
    @IBOutlet weak var progressView: PlainHorizontalProgressBar!
    
    var politeia: DcrlibwalletPoliteia = DcrlibwalletPoliteia.init()
    var processTimer: Timer?
    var allPoliteia = [Politeia]()
    let limit: Int32 = 20
    var offset: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getProposalsPoliteia()
        self.setupView()
    }
    
    func setupView() {
        self.politeiaTableView.autoResizeCell(estimatedHeight: 140)
        self.politeiaTableView.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
    }
    
    func getProposalsPoliteia() {
        self.showLoading()
        DispatchQueue.global(qos: .userInitiated).async {
            if let allPolis = self.politeia.getPoliteia(offset: self.offset, limit: self.limit, newestFirst: true), !allPolis.isEmpty {
             print("politeia result: ", allPolis)
                self.allPoliteia = allPolis
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                    self.politeiaTableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                }
            }
        }
    }
    
    func showLoading() {
        self.processTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(incrementPercent), userInfo: nil, repeats: true)
    }
    
    @objc func incrementPercent() {
        self.progressView.progress += 0.05
        print("process: ", self.progressView.progress)
        if self.progressView.progress > 1 {
            self.processTimer?.invalidate()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
        self.navigationController?.navigationBar.barTintColor = UIColor.red//UIColor.appColors.offWhite
           //Remove shadow from navigation bar
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPoliteia.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let politeiaCell = self.politeiaTableView.dequeueReusableCell(withIdentifier: PoliteiaTableViewCell.politeiaIdentifier) as! PoliteiaTableViewCell
        let politeiaItem = self.allPoliteia[indexPath.row]
        politeiaCell.displayInfo(politeiaItem)
        return politeiaCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("======================================")
    }
    
}
