//
//  SyncManager.swift
//  Decred Wallet
//
// Copyright (c) 2019-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SyncManager: NSObject {
    static let shared = SyncManager()
    
    var networkLastActive: Date?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var isSyncing: Bool {
        return WalletLoader.shared.multiWallet.isSyncing()
    }
    
    var isSynced: Bool {
        return WalletLoader.shared.multiWallet.isSynced()
    }
    
    var isRescanning: Bool {
        return WalletLoader.shared.multiWallet.isRescanning()
    }
    
    var currentNetworkConnection: Reachability.Connection {
        // Re-trigger app network change listener to ensure correct network status is determined.
        AppDelegate.shared.listenForNetworkChanges()
        return AppDelegate.shared.reachability.connection
    }
    
    override init() {
        super.init()
        WalletLoader.shared.multiWallet.enableSyncLogs()
    }
    
    // run checks if there are wallets that have not completed account discovery.
    // If all wallets have completed account discovery, sync is started.
    // Otherwise, the user is asked to unlock those wallets before sync is started.
    func startSync(allowSyncOnCellular: Bool) {
        let walletsToUnlock = WalletLoader.shared.wallets.filter({ wallet in
            return !wallet.hasDiscoveredAccounts && wallet.isLocked()
        })
        
        if walletsToUnlock.count > 0 {
            self.unlockWalletsForAccountDiscoveryAndStartSync(walletsToUnlock, allowSyncOnCellular)
        } else {
            self.startOrRestartSync(allowSyncOnCellular: allowSyncOnCellular)
        }
    }
    
    private func unlockWalletsForAccountDiscoveryAndStartSync(_ walletsToUnlock: [DcrlibwalletWallet],
                                                              _ allowSyncOnCellular: Bool) {
        
        guard let rootVC = AppDelegate.shared.window?.rootViewController else {
            print("no view controller is currently displayed, cannot sync")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // waitGroup ensures that wallets are unlocked one at a time,
            // by waiting for a wallet to be unlocked before requesting security code for another wallet.
            let waitGroup = DispatchGroup()
            for wallet in walletsToUnlock {
                waitGroup.enter()
                DispatchQueue.main.async {
                    self.requestSpendingCodeAndUnlockWallet(rootVC, wallet, waitGroup)
                }
                waitGroup.wait() // wait for this wallet to be unlocked before proceeding to next wallet
            }

            DispatchQueue.main.async {
                self.startOrRestartSync(allowSyncOnCellular: allowSyncOnCellular)
            }
        }
    }
    
    func requestSpendingCodeAndUnlockWallet(_ rootVC: UIViewController,
                                            _ wallet: DcrlibwalletWallet,
                                            _ waitGroup: DispatchGroup) {
        
        Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: wallet))
            .with(prompt: LocalizedStrings.unlockToResumeRestoration)
            .with(subtext: String(format: LocalizedStrings.unlockWalletForAccountDiscovery, wallet.name))
            .with(submitBtnText: LocalizedStrings.unlock)
            .should(showCancelButton: false)
            .requestCurrentCode(sender: rootVC) { walletSpendingCode, type, dialogDelegate in

                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try wallet.unlock(walletSpendingCode.utf8Bits)
                        wallet.privatePassphraseType = type.type
                        
                        DispatchQueue.main.async {
                            dialogDelegate?.dismissDialog()
                            waitGroup.leave()
                        }
                    } catch let error {
                        
                        DispatchQueue.main.async {
                            if error.isInvalidPassphraseError {
                                let errorMessage = SpendingPinOrPassword.invalidSecurityCodeMessage(for: wallet)
                                dialogDelegate?.displayPassphraseError(errorMessage: errorMessage)
                            } else {
                                dialogDelegate?.displayError(errorMessage: error.localizedDescription)
                            }
                        }
                    }
                }
            }
    }
    
    private func startOrRestartSync(allowSyncOnCellular: Bool) {
        // Check the updated network status before starting/restarting sync.
        if self.currentNetworkConnection == .none {
            self.requestInternetConnectionForSync()
            return
        }
        if self.currentNetworkConnection == .cellular && !allowSyncOnCellular {
            self.requestPermissionToSyncOnCellular()
            return
        }
        
        do {
            if WalletLoader.shared.multiWallet.isSyncing() {
                try WalletLoader.shared.multiWallet.restartSpvSync()
            } else {
                try WalletLoader.shared.multiWallet.spvSync()
            }
        } catch (let syncError) {
            AppDelegate.shared.showOkAlert(message: syncError.localizedDescription, title: LocalizedStrings.syncError)
        }
    }
    
    private func requestInternetConnectionForSync() {
        let noConnectionAlert = UIAlertController(title: LocalizedStrings.internetConnectionRequired,
                                                  message: LocalizedStrings.cannotSyncWithoutNetworkConnection,
                                                  preferredStyle: .alert)
        
        noConnectionAlert.addAction(UIAlertAction(title: LocalizedStrings.ok, style: .default, handler: { _ in
            // Check if a network connection has been established and re-attempt to sync.
            if self.currentNetworkConnection != .none {
                self.startOrRestartSync(allowSyncOnCellular: Settings.syncOnCellular)
            } else if WalletLoader.shared.multiWallet.isSyncing() {
                // Cancel sync if sync was ongoing but there is no internet.
                WalletLoader.shared.multiWallet.cancelSync()
            }
        }))
        
        AppDelegate.shared.window?.rootViewController?.present(noConnectionAlert, animated: false)
    }
    
    private func requestPermissionToSyncOnCellular() {
        // todo this title and message look wrong!
        let syncConfirmationDialog = UIAlertController(title: LocalizedStrings.internetConnectionRequired,
                                                       message: LocalizedStrings.cannotSyncWithoutNetworkConnection,
                                                       preferredStyle: .alert)
        
        // Dialog option to allow sync on cellular just once.
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.allowOnce, style: .default, handler: { _ in
            self.startOrRestartSync(allowSyncOnCellular: true)
        }))
        
        // Dialog option to ALWAYS allow syncing on cellular.
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.alwaysAllow, style: .default, handler: { _ in
            Settings.setBoolValue(true, for: DcrlibwalletSyncOnCellularConfigKey)
            self.startOrRestartSync(allowSyncOnCellular: true)
        }))
        
        // Dialog option to not use cellular network for now.
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.notNow, style: .cancel, handler: { _ in
            if WalletLoader.shared.multiWallet.isSyncing() {
                // Cancel sync if sync was ongoing but user said not to use cellular network.
                WalletLoader.shared.multiWallet.cancelSync()
            }
        }))
        
        AppDelegate.shared.window?.rootViewController?.present(syncConfirmationDialog, animated: true)
    }
}

// extension to react to changes in application state or network connection:
/// - applicationWillEnterBackground:
///   Registers a background task to keep the sync process alive for a few minutes even after app enters background.
/// - applicationEnteredForegroundFromSuspendedState:
///   Accounts for any amount of time lost because the app was suspended causing the ongoing sync to stall.
/// - applicationWillTerminate:
///   Kills any previously registered background task when the app terminates.
/// - networkChanged:
///   Tracks network changes to account for any amount of time lost due to network unavailability causing the ongoing sync to stall.
extension SyncManager: AppLifeCycleDelegate {
    func applicationWillEnterBackground() {
        // Deregister any previous background task before registering a new one.
        // Especially when the user frequently switches between background and foreground states while sync is in progress.
        self.endBackgroundTask()
        
        if self.isSyncing && backgroundTask == .invalid {
            self.registerBackgroundTask()
            if let progress = WalletLoader.shared.multiWallet.generalSyncProgress() {
                fireLocalBackgroundSyncNotificationIfInBackground(with: progress)
            }
        }
    }
    
    func applicationEnteredForegroundFromSuspendedState(_ lastActiveTime: Date) {
        if !self.isSyncing {
            // sync is not currently active, no need to update sync estimation parameters
            return
        }
        
        // Sync was obviously stalled because the app went to sleep.
        var syncLastActive = lastActiveTime
        if self.networkLastActive != nil && self.networkLastActive!.isBefore(lastActiveTime) {
            // Use network last active time if network was lost before app went to sleep.
            syncLastActive = self.networkLastActive!
        }
        
        let totalInactiveSeconds = Date().timeIntervalSince(syncLastActive)
        WalletLoader.shared.multiWallet.syncInactive(forPeriod: Int64(totalInactiveSeconds))
        
        if self.networkLastActive != nil && AppDelegate.shared.reachability.connection == .none {
            // Reset network last active time to current time so that when network connection is restored,
            // previously lost time (that was already accounted for above) would not be re-accounted for.
            self.networkLastActive = Date()
        }
    }
    
    func applicationWillTerminate() {
        print("app terminated")
        if backgroundTask != .invalid {
            endBackgroundTask()
        }
    }
    
    func networkChanged(_ connection: Reachability.Connection) {
        if !self.isSyncing {
            // sync is not currently active, no need to worry about network changes
            return
        }
        
        if connection == .none {
            self.networkLastActive = Date()
            // Network becoming disconnected may cause sync to stall for a while.
            // Unset any previous timer set to track stalled sync since we'd account
            // for this particular stalling below when network becomes active again.
        } else if self.networkLastActive != nil {
            // Account for stalled sync by subtracting lost time from sync estimation parameters.
            let totalInactiveSeconds = Date().timeIntervalSince(self.networkLastActive!)
            WalletLoader.shared.multiWallet.syncInactive(forPeriod: Int64(totalInactiveSeconds))
            self.networkLastActive = nil // Network is active at this point.
        }
    }
    
    private func registerBackgroundTask() {
        self.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            print("Background task expired")
            self?.endBackgroundTask()
        }
        
        assert(backgroundTask != .invalid)
        print("Background task started at: ", Date())
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    private func endBackgroundTask() {
        NotificationsManager.shared.removeSyncInProgressNotification()
        if backgroundTask != .invalid {
            print("Background task ended at: ", Date())
            backgroundTask = .invalid
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
            }
        }
    }

    private func fireLocalBackgroundSyncNotificationIfInBackground(with progress: DcrlibwalletGeneralSyncProgress) {
         DispatchQueue.main.async {
            if !self.isSyncing || UIApplication.shared.applicationState != .background {
                return
            }
            
            let message = String(format: LocalizedStrings.syncTotalProgress,
                                 progress.totalSyncProgress,
                                 progress.totalTimeRemaining)
            NotificationsManager.shared.fireSyncInProgressNotification(with: message)
        }
    }
}
