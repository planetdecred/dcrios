//
//  LocalizedStrings.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation

struct LocalizedStrings {
    /* StartScreenViewController */
    static let openingWallet = NSLocalizedString("openingWallet", comment: "")
    
    /* Wallet Setup */
    static let createNewWallet = NSLocalizedString("createNewWallet", comment: "")
    static let restoreExistingWallet = NSLocalizedString("restoreExistingWallet", comment: "")
    static let wallet = NSLocalizedString("wallet", comment: "")
    
    /* Create New Wallet(Seed display view) */
    static let settingUpYourWallet = NSLocalizedString("settingUpYourWallet", comment: "")
    static let seedHeaderInfo = NSLocalizedString("seedHeaderInfo", comment: "")
    static let seedWarningInfo = NSLocalizedString("seedWarningInfo", comment: "")
    static let iCopiedTheSeedPhrase = NSLocalizedString("iCopiedTheSeedPhrase", comment: "")
    
    /* Confirm NewWallet Seed */
    static let seedDoesNotMatch = NSLocalizedString("seedDoesNotMatch", comment: "")
    static let seedPhraseVerification = NSLocalizedString("seedPhraseVerification", comment: "")
    static let confirmSeedInfo = NSLocalizedString("confirmSeedInfo", comment: "")
    
    /* Recover Existing Wallet */
    static let wordNumber = NSLocalizedString("wordNumber", comment: "")
    static let notAllSeedsAreEntered = NSLocalizedString("notAllSeedsAreEntered", comment: "")
    static let incorrectSeedEntered = NSLocalizedString("incorrectSeedEntered", comment: "")
    static let walletRecoveryError = NSLocalizedString("walletRecoveryError", comment: "")
    static let seedRestoreHeader = NSLocalizedString("seedRestoreHeader", comment: "")
    static let seedRestoreInfo = NSLocalizedString("seedRestoreInfo", comment: "")
    static let confirm = NSLocalizedString("confirm", comment: "")
    
    /* Drop Down Search Field */
    static let tapToSelect = NSLocalizedString("tapToSelect", comment: "")
    
    /* Wallet Setup Base */
    static let settingUpWallet = NSLocalizedString("settingUpWallet", comment: "")
    static let errorSettingUpWallet = NSLocalizedString("errorSettingUpWallet", comment: "")
    
    /*Security Prompt */
    static let enterStartupPassword = NSLocalizedString("enterStartupPassword", comment: "")
    static let incorrectSecurityInfo = NSLocalizedString("incorrectSecurityInfo", comment: "")
    
    /* Password Setup */
    static let emptyPasswordNotAllowed = NSLocalizedString("emptyPasswordNotAllowed", comment: "")
    static let passwordMatch = NSLocalizedString("passwordMatch", comment: "")
    static let passwordsDoNotMatch = NSLocalizedString("passwordsDoNotMatch", comment: "")
    static let createPassword = NSLocalizedString("createPassword", comment: "")
    static let passwordStrength = NSLocalizedString("passwordStrength", comment: "")
    static let confirmPassword = NSLocalizedString("confirmPassword", comment: "")
    
    /* Request Password */
    static let enterPassword = NSLocalizedString("enterPassword", comment: "")
    static let promptSpendingPassword = NSLocalizedString("promptSpendingPassword", comment: "")
    static let promptStartupPassword = NSLocalizedString("promptStartupPassword", comment: "")
    static let securityTypeNotSpecified = NSLocalizedString("securityTypeNotSpecified", comment: "")
    static let password = NSLocalizedString("password", comment: "")
    static let proceed = NSLocalizedString("proceed", comment: "")
    static let passwordEmpty = NSLocalizedString("passwordEmpty", comment: "")
    static let invalidInput = NSLocalizedString("invalidInput", comment: "")
    static let passwordInvalid = NSLocalizedString("passwordInvalid", comment: "")
    
    /* Request PIN and PIN Setup */
    static let createPIN = NSLocalizedString("createPIN", comment: "")
    static let enterPIN = NSLocalizedString("enterPIN", comment: "")
    static let confirmPIN = NSLocalizedString("confirmPIN", comment: "")
    static let pinsDidNotMatch = NSLocalizedString("pinsDidNotMatch", comment: "")
    static let pin = NSLocalizedString("pin", comment: "")
    static let pinStrength = NSLocalizedString("pinStrength", comment: "")
    
    /* Change Spendind PIN/Password */
    static let enterCurrentSpendingPassword = NSLocalizedString("enterCurrentSpendingPassword", comment: "")
    static let changingSpendingPINPass = NSLocalizedString("changingSpendingPINPass", comment: "")
    
    /* Changing Startup PIN/Password */
    static let changingStartupPINPass = NSLocalizedString("changingStartupPINPass", comment: "")
    static let removingStartupPINPass = NSLocalizedString("removingStartupPINPass", comment: "")
    static let settingStartupPINPass = NSLocalizedString("settingStartupPINPass", comment: "")
    
    /* NavigationMenu / Sync progress */
    static let cannotSyncWithoutNetworkConnection = NSLocalizedString("cannotSyncWithoutNetworkConnection", comment: "")
    static let internetConnectionRequired = NSLocalizedString("internetConnectionRequired", comment: "")
    static let connectToWiFiToSync = NSLocalizedString("connectToWiFiToSync", comment: "")
    static let restartingSync = NSLocalizedString("restartingSync", comment: "")
    static let connectingToPeers = NSLocalizedString("connectingToPeers", comment: "")
    static let syncedWith =  NSLocalizedString("syncedWith", comment: "")
    static let fetchingBlockHeaders = NSLocalizedString("fetchingBlockHeaders", comment: "")
    static let blocksBehind = NSLocalizedString("blocksBehind", comment: "")
    static let bestBlockAgeAgo = NSLocalizedString("bestBlockAgeAgo", comment: "")
    static let discoveringUsedAddresses = NSLocalizedString("discoveringUsedAddresses", comment: "")
    static let generalSyncProgressCompletedleft = NSLocalizedString("generalSyncProgressCompletedleft", comment: "")
    static let scanningBlocks = NSLocalizedString("scanningBlocks", comment: "")
    static let rescanProgress = NSLocalizedString("rescanProgress", comment: "")
    static let syncCanceled = NSLocalizedString("syncCanceled", comment: "")
    static let syncError = NSLocalizedString("syncError", comment: "")
    static let latestBlock = NSLocalizedString("latestBlock", comment: "")
    static let now = NSLocalizedString("now", comment: "")
    static let secondsAgo = NSLocalizedString("secondsAgo", comment: "")
    static let minAgo = NSLocalizedString("minAgo", comment: "")
    static let hrsAgo = NSLocalizedString("hrsAgo", comment: "")
    static let daysAgo = NSLocalizedString("daysAgo", comment: "")
    static let weeksAgo = NSLocalizedString("weeksAgo", comment: "")
    static let monthsAgo = NSLocalizedString("monthsAgo", comment: "")
    static let yearsAgo = NSLocalizedString("yearsAgo", comment: "")
    static let totalBalance = NSLocalizedString("totalBalance", comment: "")
    static let restartingSynchronization = NSLocalizedString("restartingSynchronization", comment: "")
    static let startingSynchronization = NSLocalizedString("startingSynchronization", comment: "")
    static let loading = NSLocalizedString("loading", comment: "")
    static let numberOfConnectedPeers = NSLocalizedString("numberOfConnectedPeers", comment: "")
    static let numberOfConnectedPeer = NSLocalizedString("numberOfConnectedPeer", comment: "")
    static let syncingWithPeersOnNetwork = NSLocalizedString("syncingWithPeersOnNetwork", comment: "")
    static let fetchedHeaders = NSLocalizedString("fetchedHeaders", comment: "")
    static let headersFetchProgress = NSLocalizedString("headersFetchProgress", comment: "")
    static let bestBlockAgebehind = NSLocalizedString("bestBlockAgebehind", comment: "")
    static let addressDiscoveryProgressOver = NSLocalizedString("addressDiscoveryProgressOver", comment: "")
    static let addressDiscoveryProgressThrough = NSLocalizedString("addressDiscoveryProgressThrough", comment: "")
    static let scanningTotalHeaders = NSLocalizedString("scanningTotalHeaders", comment: "")
    static let stepThreeRescanProgress = NSLocalizedString("stepThreeRescanProgress", comment: "")
    static let synchronizing = NSLocalizedString("synchronizing", comment: "")
    static let synchronizationCanceled = NSLocalizedString("synchronizationCanceled", comment: "")
    static let synchronizationError = NSLocalizedString("synchronizationError", comment: "")
    static let syncTotalProgress = NSLocalizedString("syncTotalProgress", comment: "")
    static let allTimes = NSLocalizedString("allTimes", comment: "")
    static let elapsed = NSLocalizedString("elapsed", comment: "")
    static let remain = NSLocalizedString("remain", comment: "")
    static let total = NSLocalizedString("total", comment: "")
    static let stageTimes = NSLocalizedString("stageTimes", comment: "")
    static let tapToViewInformation = NSLocalizedString("tapToViewInformation", comment: "")
    static let latestBlockAge = NSLocalizedString("latestBlockAge", comment: "")
    static let blockHeadersFetched = NSLocalizedString("blockHeadersFetched", comment: "")
    static let syncProgressComplete = NSLocalizedString("syncProgressComplete", comment: "")
    static let syncTimeLeft = NSLocalizedString("syncTimeLeft", comment: "")
    static let syncSteps = NSLocalizedString("syncSteps", comment: "")
    static let syncingProgress = NSLocalizedString("syncingProgress", comment: "")
    static let cannotSyncWithoutNetworkConnection = NSLocalizedString("cannotSyncWithoutNetworkConnection", comment: "")
    static let internetConnectionRequired = NSLocalizedString("internetConnectionRequired", comment: "")
    static let connectToWiFiToSync = NSLocalizedString("connectToWiFiToSync", comment: "")
    static let restartingSync = NSLocalizedString("restartingSync", comment: "")
    static let connectingToPeers = NSLocalizedString("connectingToPeers", comment: "")
    static let syncedWith =  NSLocalizedString("syncedWith", comment: "")
    static let fetchingBlockHeaders = NSLocalizedString("fetchingBlockHeaders", comment: "")
    static let blocksBehind = NSLocalizedString("blocksBehind", comment: "")
    static let bestBlockAgeAgo = NSLocalizedString("bestBlockAgeAgo", comment: "")
    static let discoveringUsedAddresses = NSLocalizedString("discoveringUsedAddresses", comment: "")
    static let generalSyncProgressCompletedleft = NSLocalizedString("generalSyncProgressCompletedleft", comment: "")
    static let scanningBlocks = NSLocalizedString("scanningBlocks", comment: "")
    static let rescanProgress = NSLocalizedString("rescanProgress", comment: "")
    static let syncCanceled = NSLocalizedString("syncCanceled", comment: "")
    static let syncError = NSLocalizedString("syncError", comment: "")
    static let latestBlock = NSLocalizedString("latestBlock", comment: "")
    static let now = NSLocalizedString("now", comment: "")
    static let secondsAgo = NSLocalizedString("secondsAgo", comment: "")
    static let minAgo = NSLocalizedString("minAgo", comment: "")
    static let hrsAgo = NSLocalizedString("hrsAgo", comment: "")
    static let daysAgo = NSLocalizedString("daysAgo", comment: "")
    static let weeksAgo = NSLocalizedString("weeksAgo", comment: "")
    static let monthsAgo = NSLocalizedString("monthsAgo", comment: "")
    static let yearsAgo = NSLocalizedString("yearsAgo", comment: "")
    static let totalBalance = NSLocalizedString("totalBalance", comment: "")
    static let restartingSynchronization = NSLocalizedString("restartingSynchronization", comment: "")
    static let startingSynchronization = NSLocalizedString("startingSynchronization", comment: "")
    static let reconnect = NSLocalizedString("reconnect", comment: "")
    static let disconnnect = NSLocalizedString("disconnect", comment: "")
    
    /* Navigation Menu Items */
    static let overview = NSLocalizedString("overview", comment: "")
    static let transactions = NSLocalizedString("transactions", comment: "")
    static let wallets = NSLocalizedString("wallets", comment: "")
    static let more = NSLocalizedString("more", comment: "")
    
    /* New Wallet Dialog */
    static let newWalletMsg = NSLocalizedString("newWalletMsg", comment: "")
    static let welcomeToDecredWallet = NSLocalizedString("welcomeToDecredWallet", comment: "")
    static let syncStageDescription = NSLocalizedString("syncStageDescription", comment: "")
    
    /* Overview */
    static let currentTotalBalance = NSLocalizedString("currentTotalBalance", comment: "")
    static let recentTransactions = NSLocalizedString("recentTransactions", comment: "")
    static let showAllTransactions = NSLocalizedString("showAllTransactions", comment: "")
    static let backupSeedPhrase = NSLocalizedString("backupSeedPhrase", comment: "")
    static let walletStatus = NSLocalizedString("walletStatus", comment: "")
    static let walletSynced = NSLocalizedString("walletSynced", comment: "")
    static let walletNotSynced = NSLocalizedString("walletNotSynced", comment: "")
    static let backupWarningText = NSLocalizedString("backupWarningText", comment: "")
    static let connectedTo = NSLocalizedString("connectedTo", comment: "")
    static let online = NSLocalizedString("online", comment: "")
    static let offline = NSLocalizedString("offline", comment: "")
    static let showDetails = NSLocalizedString("showDetails", comment: "")
    static let hideDetails = NSLocalizedString("hideDetails", comment: "")
    static let connectedPeersCount = NSLocalizedString("connectedPeersCount", comment: "")
    static let peers = NSLocalizedString("peers", comment: "")
    static let seeAll = NSLocalizedString("seeAll", comment: "")
    
    /* Transaction List/ History */
    static let pending = NSLocalizedString("pending", comment: "")
    static let confirmed = NSLocalizedString("confirmed", comment: "")
    static let vote = NSLocalizedString("vote", comment: "")
    static let ticket = NSLocalizedString("ticket", comment: "")
    static let confirmedLive = NSLocalizedString("confirmedLive", comment: "")
    static let confirmedImmature = NSLocalizedString("confirmedImmature", comment: "")
    static let noTransactions = NSLocalizedString("noTransactions", comment: "")
    static let sent = NSLocalizedString("sent", comment: "")
    static let received = NSLocalizedString("received", comment: "")
    static let yourself = NSLocalizedString("yourself", comment: "")
    static let staking = NSLocalizedString("staking", comment: "")
    static let coinbase = NSLocalizedString("coinbase", comment: "")
    static let all = NSLocalizedString("all", comment: "")
    
    /* Transaction Details */
    static let transactionDetails = NSLocalizedString("transactionDetails", comment: "")
    static let copyTransactionHash = NSLocalizedString("copyTransactionHash", comment: "")
    static let copyRawTransaction = NSLocalizedString("copyRawTransaction", comment: "")
    static let viewOnDcrdata = NSLocalizedString("viewOnDcrdata", comment: "")
    static let copied = NSLocalizedString("copied", comment: "")
    static let ticketPurchase = NSLocalizedString("ticketPurchase", comment: "")
    static let date = NSLocalizedString("date", comment: "")
    static let status = NSLocalizedString("status", comment: "")
    static let amount = NSLocalizedString("amount", comment: "")
    static let fee = NSLocalizedString("fee", comment: "")
    static let type = NSLocalizedString("type", comment: "")
    static let confirmation = NSLocalizedString("confirmation", comment: "")
    static let lastBlockValid = NSLocalizedString("lastBlockValid", comment: "")
    static let version = NSLocalizedString("version", comment: "")
    static let voteBits = NSLocalizedString("voteBits", comment: "")
    static let inputs = NSLocalizedString("inputs", comment: "")
    static let outputs = NSLocalizedString("outputs", comment: "")
    static let external = NSLocalizedString("external", comment: "")
    static let `internal` = NSLocalizedString("internal", comment: "")
    static let imported = NSLocalizedString("imported", comment: "")
    static let nullData = NSLocalizedString("nullData", comment: "")
    static let script = NSLocalizedString("script", comment: "")
    static let stakegen = NSLocalizedString("stakegen", comment: "")
    
    /* Send view */
    static let invalidAmount = NSLocalizedString("invalidAmount", comment: "")
    static let amount8Decimal = NSLocalizedString("amount8Decimal", comment: "")
    static let amountMaximumAllowed = NSLocalizedString("amountMaximumAllowed", comment: "")
    static let notEnoughFunds = NSLocalizedString("notEnoughFunds", comment: "")
    static let notEnoughFundsOrNotConnected = NSLocalizedString("notEnoughFundsOrNotConnected", comment: "")
    static let rateUnavailableTap  = NSLocalizedString("rateUnavailableTap", comment: "")
    static let sendToAccount = NSLocalizedString("sendToAccount", comment: "")
    static let sendToAddress = NSLocalizedString("sendToAddress", comment: "")
    static let errorGettingMaxSpendable = NSLocalizedString("errorMaxSpendable", comment: "")
    static let pleaseWaitNetworkSync = NSLocalizedString("pleaseWaitNetworkSync", comment: "")
    static let notConnected = NSLocalizedString("notConnected", comment: "")
    static let amountCantBeZero = NSLocalizedString("amountCantBeZero", comment: "")
    static let unexpectedError = NSLocalizedString("unexpectedError", comment: "")
    static let sendingTransaction = NSLocalizedString("sendingTransaction", comment: "")
    static let failedTransaction = NSLocalizedString("failedTransaction", comment: "")
    static let walletAddressShort = NSLocalizedString("walletAddressShort", comment: "")
    static let walletAddressLong = NSLocalizedString("walletAddressLong", comment: "")
    static let invalidTesnetAddress = NSLocalizedString("invalidTesnetAddress", comment: "")
    static let invalidMainnetAddress = NSLocalizedString("invalidMainnetAddress", comment: "")
    static let invalidDestAddr = NSLocalizedString("invalidDestAddr", comment: "")
    static let emptyDestAddr = NSLocalizedString("emptyDestAddr", comment: "")
    static let sendingDecred = NSLocalizedString("sendingDecred", comment: "")
    static let from = NSLocalizedString("from", comment: "")
    static let sendHeaderInfo = NSLocalizedString("sendHeaderInfo", comment: "")
    static let destAddr = NSLocalizedString("destAddr", comment: "")
    static let tapToPaste = NSLocalizedString("tapToPaste", comment: "")
    static let sendInUSD = NSLocalizedString("sendInUSD", comment: "")
    static let sendInDCR = NSLocalizedString("sendInDCR", comment: "")
    static let sendMax = NSLocalizedString("sendMax", comment: "")
    static let feeDesc = NSLocalizedString("feeDesc", comment: "")
    static let estimateSize = NSLocalizedString("estimateSize", comment: "")
    static let balanceAfter = NSLocalizedString("balanceAfter", comment: "")
    static let exchangeRate = NSLocalizedString("exchangeRate", comment: "")
    
    /* Confirm Send Fund */
    static let sending = NSLocalizedString("sending", comment: "")
    static let withFee = NSLocalizedString("withFee", comment: "")
    static let to = NSLocalizedString("to", comment: "")
    static let toAccount = NSLocalizedString("toAccount", comment: "")
    static let passwordHint = NSLocalizedString("passwordHint", comment: "")
    
    /* Send Complete */
    static let hashCopied = NSLocalizedString("hashCopied", comment: "")
    static let hash = NSLocalizedString("hash", comment: "")
    static let view = NSLocalizedString("view", comment: "");
    static let transactionSuccessful = NSLocalizedString("transactionSuccessful", comment: "");
    
    /* Recieve */
    static let receivingDecred = NSLocalizedString("receivingDecred", comment: "")
    static let receiveHeaderInfo = NSLocalizedString("receiveHeaderInfo", comment: "")
    static let accountDesc = NSLocalizedString("accountDesc", comment: "")
    static let copyOnTap = NSLocalizedString("copyOnTap", comment: "")
    static let walletAddrCopied = NSLocalizedString("walletAddrCopied", comment: "")
    static let genNewAddr = NSLocalizedString("genNewAddr", comment: "")
    
    /* Account View */
    static let hidden = NSLocalizedString("hidden", comment: "")
    static let spendable = NSLocalizedString("spendable", comment: "")
    
    /* Account Data cell */
    static let details = NSLocalizedString("details", comment: "")
    static let immatureRewards = NSLocalizedString("immatureRewards", comment: "")
    static let lockedByTickets = NSLocalizedString("lockedByTickets", comment: "")
    static let votingAuhtority = NSLocalizedString("votingAuhtority", comment: "")
    static let immatureStakeGeneration = NSLocalizedString("immatureStakeGeneration", comment: "")
    static let properties = NSLocalizedString("properties", comment: "")
    static let accountNumber = NSLocalizedString("accountNumber", comment: "")
    static let hDPath = NSLocalizedString("hDPath", comment: "")
    static let keys = NSLocalizedString("keys", comment: "")
    static let walletSettings = NSLocalizedString("walletSettings", comment: "")
    static let hideThisWallet = NSLocalizedString("hideThisWallet", comment: "")
    static let walletBalanceWillBeIgnored = NSLocalizedString("walletBalanceWillBeIgnored", comment: "")
    static let defaultWallet = NSLocalizedString("defaultWallet", comment: "")
    static let makeWalletDefaultDesc = NSLocalizedString("makeWalletDefaultDesc", comment: "")
    
    /* Add Account */
    static let inputAccountName = NSLocalizedString("inputAccountName", comment: "")
    static let creatingAccount = NSLocalizedString("creatingAccount", comment: "")
    static let addAccount = NSLocalizedString("addAccount", comment: "")
    static let addAccountInfo = NSLocalizedString("addAccountInfo", comment: "")
    static let accountName = NSLocalizedString("accountName", comment: "")
    static let createAccount = NSLocalizedString("createAccount", comment: "")
    static let privatePassphrase = NSLocalizedString("privatePassphrase", comment: "")
    
    /* Security Menu */
    static let validOwnAddr = NSLocalizedString("validOwnAddr", comment: "")
    static let validNotOwnAddr = NSLocalizedString("validNotOwnAddr", comment: "")
    static let invalidAddr = NSLocalizedString("invalidAddr", comment: "")
    static let verifiedSignature = NSLocalizedString("verifiedSignature", comment: "")
    static let invalidSignature = NSLocalizedString("invalidSignature", comment: "")
    static let signingMessage = NSLocalizedString("signingMessage", comment: "")
    static let address = NSLocalizedString("address", comment: "")
    static let message = NSLocalizedString("message", comment: "")
    static let signature = NSLocalizedString("signature", comment: "")
    static let signMessage = NSLocalizedString("signMessage", comment: "")
    static let secureMenuSyncInfo = NSLocalizedString("secureMenuSyncInfo", comment: "")
    static let secureMenuHeaderInfo = NSLocalizedString("secureMenuHeaderInfo", comment: "")
    
    /* Help */
    static let forMoreInformationPleaseVisit = NSLocalizedString("forMoreInformationPleaseVisit", comment: "")
    
    /* Settings */
    static let changeSpendingPinPass = NSLocalizedString("changeSpendingPinPass", comment: "")
    static let spendingPinPassInfo = NSLocalizedString("spendingPinPassInfo", comment: "")
    static let startupPinPass = NSLocalizedString("startupPinPass", comment: "")
    static let changeStatupPinPass = NSLocalizedString("changeStatupPinPass", comment: "")
    static let startupPinPassInfo = NSLocalizedString("startupPinPassInfo", comment: "")
    static let spendUnconfirmedFund = NSLocalizedString("spendUnconfirmedFund", comment: "")
    static let incomingTxNotification = NSLocalizedString("incomingTxNotification", comment: "")
    static let currencyConversion = NSLocalizedString("currencyConversion", comment: "")
    static let networkMode = NSLocalizedString("networkMode", comment: "")
    static let serverAddress = NSLocalizedString("serverAddress", comment: "")
    static let connectIpDesc = NSLocalizedString("connectIpDesc", comment: "")
    static let certificate = NSLocalizedString("certificate", comment: "")
    static let syncOnWifiDesc = NSLocalizedString("syncOnWifiDesc", comment: "")
    static let buildDate = NSLocalizedString("buildDate", comment: "")
    static let walletLog = NSLocalizedString("walletLog", comment: "")
    static let deleteWallet = NSLocalizedString("deleteWallet", comment: "")
    static let spv = NSLocalizedString("spv", comment: "")
    static let remoteFullNode = NSLocalizedString("remoteFullNode", comment: "")
    static let none = NSLocalizedString("none", comment: "")
    static let rescanConfirm = NSLocalizedString("rescanConfirm", comment: "")
    static let rescanBlockchain = NSLocalizedString("rescanBlockchain", comment: "")
    static let syncProgressAlert = NSLocalizedString("syncProgressAlert", comment: "")
    static let scanInProgress = NSLocalizedString("scanInProgress", comment: "")
    static let scanStartedAlready = NSLocalizedString("scanStartedAlready", comment: "")
    static let rescanFailed = NSLocalizedString("rescanFailed", comment: "")
    static let deletingWallet = NSLocalizedString("deletingWallet", comment: "")
    static let deleteWalletFailed = NSLocalizedString("deleteWalletFailed", comment: "")
    static let general = NSLocalizedString("general", comment: "")
    static let connection = NSLocalizedString("connection", comment: "")
    static let about = NSLocalizedString("about", comment: "")
    static let debug = NSLocalizedString("debug", comment: "")
    
    /* IP set */
    static let connectToPeer = NSLocalizedString("connectToPeer", comment: "")
    static let peerAddressIsInvalid = NSLocalizedString("peerAddressIsInvalid", comment: "")
    static let remoteAddressIsInvalid = NSLocalizedString("remoteAddressIsInvalid", comment: "")
    
    /* Certificate */
    static let certificateInfo = NSLocalizedString("certificateInfo", comment: "")
    
    /* License */
    static let license = NSLocalizedString("license", comment: "")
    
    /* Wallet Log */
    static let copy = NSLocalizedString("copy", comment: "")
    static let walletLogCopied = NSLocalizedString("walletLogCopied", comment: "")
    
    /* Delete Wallet */
    static let confirmDeleteInfo = NSLocalizedString("confirmDeleteInfo", comment: "")
    static let confirmDeleteDesc = NSLocalizedString("confirmDeleteDesc", comment: "")
    
    /* Transaction Notification */
    static let newTransaction = NSLocalizedString("newTransaction", comment: "")
    static let youReceived = NSLocalizedString("youReceived", comment: "")
    
    /* View controller sender */
    static let spending = NSLocalizedString("spending", comment: "")
    static let startup = NSLocalizedString("startup", comment: "")
    static let current = NSLocalizedString("current", comment: "")
    
    /* Dcrlibwallet extension */
    static let lessThanOneday = NSLocalizedString("lessThanOneday", comment: "")
    static let oneDay = NSLocalizedString("oneDay", comment: "")
    static let mutlipleDays = NSLocalizedString("mutlipleDays", comment: "")
    static let minRemaining = NSLocalizedString("minRemaining", comment: "")
    static let secRemaining = NSLocalizedString("secRemaining", comment: "")
    
    /* Pop Ups */
    static let error = NSLocalizedString("error", comment: "")
    static let retry = NSLocalizedString("retry", comment: "")
    static let ok = NSLocalizedString("ok", comment: "")
    static let tryAgain = NSLocalizedString("tryAgain", comment: "")
    static let cancel = NSLocalizedString("cancel", comment: "")
    static let clearFields =  NSLocalizedString("clearFields", comment: "")
    static let copiedSuccessfully = NSLocalizedString("copiedSuccessfully", comment: "")
    static let invalidRequest = NSLocalizedString("invalidRequest", comment: "")
    static let addrCopied = NSLocalizedString("addrCopied", comment: "")
    static let previousOutpointCopied = NSLocalizedString("previousOutpointCopied", comment: "")
    static let errorMsg = NSLocalizedString("errorMsg", comment: "")
    static let info = NSLocalizedString("info", comment: "")
    static let delete = NSLocalizedString("delete", comment: "")
    static let allowOnce = NSLocalizedString("allowOnce", comment: "")
    static let alwaysAllow = NSLocalizedString("alwaysAllow", comment: "")
    static let notNow = NSLocalizedString("notNow", comment: "")

    /* Other text */
    static let security = NSLocalizedString("security", comment: "")
    static let send = NSLocalizedString("send", comment: "")
    static let receive = NSLocalizedString("receive", comment: "")
    static let history = NSLocalizedString("history", comment: "")
    static let settings = NSLocalizedString("settings", comment: "")
    static let help = NSLocalizedString("help", comment: "")
}
