//
//  SyncDetailsComponent.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Signals
import Dcrlibwallet

class SyncDetailsComponent: UIView {
    
    let syncManager: SyncManager = SyncManager.shared
    
    var container = UIView(frame: CGRect.zero)
    
    // Separator
    let separator = UIView(frame: CGRect.zero)
    
    // Sync Step
    let stepsLabel = UILabel(frame: CGRect.zero) // Current sync operation stage (1,2 or 3)
    let stepDetailLabel = UILabel(frame: CGRect.zero) // Current sync operation description
    
    // Headers fetched
    let stepStageProgressLabel = UILabel(frame: CGRect.zero)
    let headersFetchedCount = UILabel(frame: CGRect.zero)
    
    // General Sync Progress
    let syncProgressLabel = UILabel(frame: CGRect.zero)
    let ledgerAgeLabel = UILabel(frame: CGRect.zero)
    
    // Connected Peers
    let numberOfPeersLabel = UILabel(frame: CGRect.zero)
    let numberOfPeersCount = UILabel(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupComponents()
        self.attachListeners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Set component properties and their AutoLayout Constraints relative to each other
    func setupComponents() {
        // setup container holding details
        self.container.layer.backgroundColor = UIColor.appColors.offWhite.cgColor
        self.container.layer.cornerRadius = 8
        self.container.translatesAutoresizingMaskIntoConstraints = false
        self.container.clipsToBounds = true
        
        // setup separator
        self.separator.backgroundColor = UIColor.appColors.gray
        self.separator.translatesAutoresizingMaskIntoConstraints = false
        self.separator.clipsToBounds = true
        
        // current step indicator
        self.stepsLabel.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        self.stepsLabel.text = String(format: LocalizedStrings.syncSteps, 0)
        self.stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.stepsLabel.clipsToBounds = true
        self.stepsLabel.textColor = UIColor.appColors.bluishGray
        
        // current step action/progress
        self.stepDetailLabel.font = UIFont(name: "SourceSansPro-Regular", size: 15)
        self.stepDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.stepDetailLabel.clipsToBounds = true
        self.stepDetailLabel.textColor = UIColor.appColors.darkBlue
        
        // fetched headers text
        self.stepStageProgressLabel.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        self.stepStageProgressLabel.text = LocalizedStrings.blockHeadersFetched
        self.stepStageProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.stepStageProgressLabel.clipsToBounds = true
        self.stepStageProgressLabel.textColor = UIColor.appColors.bluishGray
        
        // Fetched headers count
        self.headersFetchedCount.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        self.headersFetchedCount.translatesAutoresizingMaskIntoConstraints = false
        self.headersFetchedCount.clipsToBounds = true
        self.headersFetchedCount.textColor = UIColor.appColors.darkBlue
        
        // Syncing progress text
        self.syncProgressLabel.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        self.syncProgressLabel.text = LocalizedStrings.syncingProgress
        self.syncProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.syncProgressLabel.clipsToBounds = true
        self.syncProgressLabel.textColor = UIColor.appColors.bluishGray
        
        // block age behind
        self.ledgerAgeLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        self.ledgerAgeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.ledgerAgeLabel.clipsToBounds = true
        self.ledgerAgeLabel.textColor = UIColor.appColors.darkBlue
        
        // Connected peers
        self.numberOfPeersLabel.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        self.numberOfPeersLabel.text = LocalizedStrings.connectedPeersCount
        self.numberOfPeersLabel.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfPeersLabel.clipsToBounds = true
        self.numberOfPeersLabel.textColor = UIColor.appColors.bluishGray
        
        // show connected peers count
        self.numberOfPeersCount.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        self.numberOfPeersCount.text = "0"
        self.numberOfPeersCount.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfPeersCount.clipsToBounds = true
        self.numberOfPeersCount.textColor = UIColor.appColors.darkBlue
        
        // Add details to container
        self.container.addSubview(self.stepStageProgressLabel)
        self.container.addSubview(self.headersFetchedCount) // %headersFetched% of %total header%
        self.container.addSubview(self.syncProgressLabel) // Syncing progress
        self.container.addSubview(self.ledgerAgeLabel) // days behind count
        self.container.addSubview(self.numberOfPeersLabel) // Connected peers count label
        self.container.addSubview(self.numberOfPeersCount) // number of connected peers
        
        // Positioning constraints for full sync details. numbers are from mockup
        NSLayoutConstraint.activate([
            // Headers fetch progress
            self.stepStageProgressLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
            self.stepStageProgressLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 17),
            self.stepStageProgressLabel.heightAnchor.constraint(equalToConstant: 16),
            
            self.headersFetchedCount.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -16),
            self.headersFetchedCount.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 17),
            self.headersFetchedCount.heightAnchor.constraint(equalToConstant: 14),
            
            // Wallet sync progress (i.e ledger current age or days behind)
            self.syncProgressLabel.heightAnchor.constraint(equalToConstant: 16),
            self.syncProgressLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
            self.syncProgressLabel.topAnchor.constraint(equalTo: stepStageProgressLabel.bottomAnchor, constant: 18),
            
            self.ledgerAgeLabel.topAnchor.constraint(equalTo: headersFetchedCount.bottomAnchor, constant: 16),
            self.ledgerAgeLabel.heightAnchor.constraint(equalToConstant: 16),
            self.ledgerAgeLabel.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -16),
            
            // Number of peers currently connected
            self.numberOfPeersLabel.heightAnchor.constraint(equalToConstant: 16),
            self.numberOfPeersLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
            self.numberOfPeersLabel.topAnchor.constraint(equalTo: self.syncProgressLabel.bottomAnchor, constant: 18),
            self.numberOfPeersCount.topAnchor.constraint(equalTo: self.ledgerAgeLabel.bottomAnchor, constant: 16), // 16pts below ledger age label
            self.numberOfPeersCount.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -16), // 16pts from right edge of container
            self.numberOfPeersCount.heightAnchor.constraint(equalToConstant: 16), // height of 16pts
        ])
        
        // bring all the components together
        self.addSubview(separator)
        self.addSubview(stepsLabel)
        self.addSubview(stepDetailLabel)
        self.addSubview(self.container)
        
        NSLayoutConstraint.activate([
            
            // separator contraints
           self.separator.heightAnchor.constraint(equalToConstant: 0.5),
           self.separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
           self.separator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
           self.separator.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            
            // Current sync step (1,2 or 3)
            self.stepsLabel.heightAnchor.constraint(equalToConstant: 16),
            self.stepsLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.stepsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16), // left margin of 16pts
            
            self.stepDetailLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.stepDetailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            self.stepDetailLabel.heightAnchor.constraint(equalToConstant: 16), // right margin of 16pts
            
            // position view holding details data/text
            self.container.heightAnchor.constraint(equalToConstant: 112), // Height of 112 from mockup
            self.container.topAnchor.constraint(equalTo: self.topAnchor, constant: 56), // 56pts space from top
            self.container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
        ])
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func attachListeners() {
        // Subscribe to general sync progress changes for use in this component
        self.syncManager.syncProgress.subscribePast(with: self) { (generalProgressReport, currentOperationProgress) in
            
            guard currentOperationProgress != nil else {
                return
            }

            switch (currentOperationProgress) {
            case is DcrlibwalletHeadersFetchProgressReport:
                let headersFetchedReport = currentOperationProgress as? DcrlibwalletHeadersFetchProgressReport
                if headersFetchedReport != nil {
                    DispatchQueue.main.async {
                        self.stepStageProgressLabel.text = LocalizedStrings.blockHeadersFetched
                        self.headersFetchedCount.text = String(format: LocalizedStrings.fetchedHeaders, headersFetchedReport!.fetchedHeadersCount, headersFetchedReport!.totalHeadersToFetch)
                        self.stepDetailLabel.text = String(format: LocalizedStrings.headersFetchProgress, headersFetchedReport!.headersFetchProgress)
                        self.stepsLabel.text = String(format: LocalizedStrings.syncSteps, 1)
                        if headersFetchedReport!.bestBlockAge != "" {
                            self.syncProgressLabel.text = LocalizedStrings.syncingProgress
                            self.ledgerAgeLabel.text = String(format: LocalizedStrings.bestBlockAgebehind, headersFetchedReport!.bestBlockAge)
                            self.ledgerAgeLabel.sizeToFit()
                        }
                    }
                }
            case is DcrlibwalletAddressDiscoveryProgressReport:
                let addressDiscoveryReport = currentOperationProgress as? DcrlibwalletAddressDiscoveryProgressReport
                if addressDiscoveryReport != nil {
                    let isOverHundred = addressDiscoveryReport!.addressDiscoveryProgress > 100
                    let addressOverHundred = String(format: LocalizedStrings.addressDiscoveryProgressOver, addressDiscoveryReport!.addressDiscoveryProgress)
                    let addressUnderHundred = String(format: LocalizedStrings.addressDiscoveryProgressThrough, addressDiscoveryReport!.addressDiscoveryProgress)
                    let details = isOverHundred ? addressOverHundred: addressUnderHundred
                    DispatchQueue.main.async {
                        self.headersFetchedCount.text = details
                        self.stepDetailLabel.text = "\(LocalizedStrings.discoveringUsedAddresses) \(addressDiscoveryReport!.addressDiscoveryProgress)%"
                        self.stepStageProgressLabel.text = LocalizedStrings.discoveringUsedAddresses
                        self.stepsLabel.text = String(format: LocalizedStrings.syncSteps, 2)
                        self.syncProgressLabel.text = ""
                        self.ledgerAgeLabel.text = ""
                        self.ledgerAgeLabel.sizeToFit()
                    }
                }
                break
            case is DcrlibwalletHeadersRescanProgressReport:
                let addressRescanReport = currentOperationProgress as? DcrlibwalletHeadersRescanProgressReport
                if addressRescanReport != nil {
                    DispatchQueue.main.async {
                        self.headersFetchedCount.text = String(format: LocalizedStrings.scanningTotalHeaders, addressRescanReport!.currentRescanHeight, addressRescanReport!.totalHeadersToScan)
                        self.stepStageProgressLabel.text = LocalizedStrings.blockHeaderScanned
                        self.stepDetailLabel.text = String(format: LocalizedStrings.headersScannedProgress, addressRescanReport!.rescanProgress)
                        self.stepsLabel.text = String(format: LocalizedStrings.syncSteps, 3)
                        self.syncProgressLabel.text = ""
                        self.ledgerAgeLabel.text = ""
                        self.ledgerAgeLabel.sizeToFit()
                        }
                    }
            case .none:
                break
            case .some(_):
                break
            }
        }
            
        // Subscribe to connected peers changes and react in this component only
        self.syncManager.peers.subscribePast(with: self) { (peers) in
            DispatchQueue.main.async {
                self.numberOfPeersCount.text = String(peers)
            }
        }
    }
}
