//
//  BackupWriteDownViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class BackupWriteDownViewController: UIViewController,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var seed: String! = ""
    var arrWords = Array<String>()
    @IBOutlet weak var topCorneredView: UIView!
    @IBOutlet weak var bottomCorneredView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var generateSeedError: NSError?
        self.seed =  (DcrlibwalletGenerateSeed(&generateSeedError))
        if generateSeedError != nil {
            print("seed generate error: \(String(describing: generateSeedError?.localizedDescription))")
        }
        
        arrWords = (seed.components(separatedBy: " "))
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
            guard let this = self else { return }
            this.tableView?.reloadData()
        }
        
        addNavigationBackButton()
        
        topCorneredView.clipsToBounds = true
        topCorneredView.layer.cornerRadius = 14
        topCorneredView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        bottomCorneredView.clipsToBounds = true
        bottomCorneredView.layer.cornerRadius = 14
        bottomCorneredView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(ceil(Double(arrWords.count) / 2))
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "backupWriteDownTableViewCell") as! BackupWriteDownTableViewCell
        
        if self.arrWords.indices.contains(indexPath.row) {
            cell.countLabel1?.text = String(indexPath.row + 1)
            cell.phaseLabel1?.text = self.arrWords[indexPath.row]
        }

        let secoundColumnIndex = indexPath.row + Int(ceil(Double(arrWords.count) / 2))
        
        if self.arrWords.indices.contains(secoundColumnIndex) {
            cell.countLabel2?.text = String(secoundColumnIndex + 1)
            cell.phaseLabel2?.text = self.arrWords[secoundColumnIndex]
            cell.countLabel2?.isHidden = false
            cell.phaseLabel2?.isHidden = false
        }else {
            cell.countLabel2?.isHidden = true
            cell.phaseLabel2?.isHidden = true
        }
        
        return cell
        
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         let verifySeedVC = segue.destination as! BackupVerifyViewController
         verifySeedVC.prepareSeedForVerification(seedToVerify: self.seed)
    }

    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
   
}