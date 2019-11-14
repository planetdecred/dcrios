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
    // Sync Step
    let stepsLabel = UILabel(frame: CGRect.zero) // Current sync operation stage (1,2 or 3)
    let stepDetailLabel = UILabel(frame: CGRect.zero) // Current sync operation description
    
    // Headers fetched
    let headersFetchedLabel = UILabel(frame: CGRect.zero)
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
    
//    convenience init() {
//        self.init(frame: .zero)
//
//    }
    
    // Set component properties and their AutoLayout Constraints relative to each other
    func setupComponents() {
        // setup container holding details
        self.container.layer.backgroundColor = UIColor.init(hex: "#f3f5f6").cgColor
        self.container.layer.cornerRadius = 8
        self.container.translatesAutoresizingMaskIntoConstraints = false
        self.container.clipsToBounds = true
        
        // Current step indicator
        self.stepsLabel.font = UIFont(name: "Source Sans Pro", size: 13)
        self.stepsLabel.text = String(format: LocalizedStrings.syncSteps, 0)
        self.stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.stepsLabel.clipsToBounds = true
        
        // Current step action/progress
        self.stepDetailLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        self.stepDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.stepDetailLabel.clipsToBounds = true
        
        // fetched headers text
        self.headersFetchedLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        self.headersFetchedLabel.text = LocalizedStrings.blockHeadersFetched
        self.headersFetchedLabel.translatesAutoresizingMaskIntoConstraints = false
        self.headersFetchedLabel.clipsToBounds = true
        
        // Fetched headers count
        self.headersFetchedCount.font = UIFont(name: "Source Sans Pro", size: 14)
        self.headersFetchedCount.translatesAutoresizingMaskIntoConstraints = false
        self.headersFetchedCount.clipsToBounds = true
        
        // Syncing progress text
        self.syncProgressLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        self.syncProgressLabel.text = LocalizedStrings.syncingProgress
        self.syncProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.syncProgressLabel.clipsToBounds = true
        
        // block age behind
        self.ledgerAgeLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        self.ledgerAgeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.ledgerAgeLabel.clipsToBounds = true
        
        // Connected peers
        self.numberOfPeersLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        self.numberOfPeersLabel.text = LocalizedStrings.connectedPeersCount
        self.numberOfPeersLabel.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfPeersLabel.clipsToBounds = true
        
        // show connected peers count
        self.numberOfPeersCount.font = UIFont(name: "Source Sans Pro", size: 14)
        self.numberOfPeersCount.text = "0"
        self.numberOfPeersCount.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfPeersCount.clipsToBounds = true
        
        // Add details to container
        self.container.addSubview(self.headersFetchedLabel)
        self.container.addSubview(self.headersFetchedCount) // %headersFetched% of %total header%
        self.container.addSubview(self.syncProgressLabel) // Syncing progress
        self.container.addSubview(self.ledgerAgeLabel) // days behind count
        self.container.addSubview(self.numberOfPeersLabel) // Connected peers count label
        self.container.addSubview(self.numberOfPeersCount) // number of connected peers
        
        // Positioning constraints for full sync details. numbers are from mockup
        NSLayoutConstraint.activate([
            // Headers fetch progress
            self.headersFetchedLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
            self.headersFetchedLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 17),
            self.headersFetchedLabel.heightAnchor.constraint(equalToConstant: 16),
            
            self.headersFetchedCount.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -16),
            self.headersFetchedCount.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 17),
            self.headersFetchedCount.heightAnchor.constraint(equalToConstant: 14),
            
            // Wallet sync progress (i.e ledger current age or days behind)
            self.syncProgressLabel.heightAnchor.constraint(equalToConstant: 16),
            self.syncProgressLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
            self.syncProgressLabel.topAnchor.constraint(equalTo: headersFetchedLabel.bottomAnchor, constant: 18),
            
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
        self.addSubview(stepsLabel)
        self.addSubview(stepDetailLabel)
        self.addSubview(self.container)
        
        NSLayoutConstraint.activate([
            // Current sync step (1,2 or 3)
            self.stepsLabel.heightAnchor.constraint(equalToConstant: 14),
            self.stepsLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.stepsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16), // left margin of 16pts
            
            self.stepDetailLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.stepDetailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            self.stepDetailLabel.heightAnchor.constraint(equalToConstant: 16), // right margin of 16pts
            
            // position view holding details data/text
            self.container.heightAnchor.constraint(equalToConstant: 112), // Height of 112 from mockup
            self.container.topAnchor.constraint(equalTo: self.topAnchor, constant: 56), // 56pts space from top
            self.container.widthAnchor.constraint(equalToConstant: 327), // A padding of 16pts is needed on both sides of this (16 * 2 = 32)
            self.container.centerXAnchor.constraint(equalTo: self.centerXAnchor), // To maintain even right and left margins
        ])
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func attachListeners() {
        // Subscribe to general sync progress changes for use in this component
        // TODO: this only reacts to headersFetchprogress. needs to be refactored to react to address discovery and address rescan actions as well with values below
        // let addressDiscoveryReport = currentOperationProgress as? DcrlibwalletAddressDiscoveryProgressReport
        // let addressRescanReport = currentOperationProgress as? DcrlibwalletHeadersRescanProgressReport
        self.syncManager.syncProgress.subscribePast(with: self) { (generalProgressReport, currentOperationProgress) in
            
            guard currentOperationProgress != nil else {
                return
            }
            
            let headersFetchedReport = currentOperationProgress as? DcrlibwalletHeadersFetchProgressReport // determine if report is headersFetched report
            
            if headersFetchedReport != nil {
                DispatchQueue.main.async {
                    self.headersFetchedCount.text = String(format: LocalizedStrings.fetchedHeaders, headersFetchedReport!.fetchedHeadersCount, headersFetchedReport!.totalHeadersToFetch)
                    
                    if headersFetchedReport!.bestBlockAge != "" {
                        self.ledgerAgeLabel.text = String(format: LocalizedStrings.bestBlockAgebehind, headersFetchedReport!.bestBlockAge)
                        self.ledgerAgeLabel.sizeToFit()
                    }
                }
            }
        }
        // Subscribe to connected peers changes and react in this component only
        self.syncManager.peers.subscribe(with: self) { (peers) in
            DispatchQueue.main.async {
                self.numberOfPeersCount.text = String(peers)
            }
        }
        // Subscribe to changes in synchronization stage and react in this component only
        self.syncManager.syncStage.subscribe(with: self){ (stage, reportText) in
            DispatchQueue.main.async {
                self.stepsLabel.text = String(format: LocalizedStrings.syncSteps, stage)
                self.stepDetailLabel.text = reportText
            }
        }
    }
}
