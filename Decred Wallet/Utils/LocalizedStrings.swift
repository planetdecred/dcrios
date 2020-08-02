//
//  LocalizedStrings.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
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
    static let introMessage = NSLocalizedString("introMessage", comment: "")
    static let myWallet = NSLocalizedString("myWallet", comment: "")
    static let default_ = NSLocalizedString("default_", comment: "")
    static let migratingWallet = NSLocalizedString("migratingWallet", comment: "")
    
    /* Create New Wallet(Seed display view) */
    static let settingUpYourWallet = NSLocalizedString("settingUpYourWallet", comment: "")
    
    /* Confirm NewWallet Seed */
    static let confirmToShowSeed = NSLocalizedString("confirmToShowSeed", comment: "")
    static let confirmToVerifySeed = NSLocalizedString("confirmToVerifySeed", comment: "")
    
    /* Recover Existing Wallet */
    static let wordNumber = NSLocalizedString("wordNumber", comment: "")
    static let notAllSeedsAreEntered = NSLocalizedString("notAllSeedsAreEntered", comment: "")
    static let incorrectSeedEntered = NSLocalizedString("incorrectSeedEntered", comment: "")
    static let seedRestoreHeader = NSLocalizedString("seedRestoreHeader", comment: "")
    static let seedRestoreInfo = NSLocalizedString("seedRestoreInfo", comment: "")
    static let restore = NSLocalizedString("restore", comment: "")
    static let success = NSLocalizedString("success", comment: "")
    static let getStarted = NSLocalizedString("getStarted", comment: "")
    static let restoreSuccessTitle = NSLocalizedString("restoreSuccessTitle", comment: "")
    
    /* Unlock Wallet Prompt */
    static let unlockWithStartupCode = NSLocalizedString("unlockWithStartupCode", comment: "")
    static let unlock = NSLocalizedString("unlock", comment: "")
    static let wrongSecurityCode = NSLocalizedString("wrongSecurityCode", comment: "")
    
    /* Password Setup */
    static let emptyPasswordNotAllowed = NSLocalizedString("emptyPasswordNotAllowed", comment: "")
    static let passwordsDoNotMatch = NSLocalizedString("passwordsDoNotMatch", comment: "")
    static let createPassword = NSLocalizedString("createPassword", comment: "")
    static let passwordPlaceholder = NSLocalizedString("passwordPlaceholder", comment: "")
    static let confirmPasswordPlaceholder = NSLocalizedString("confirmPasswordPlaceholder", comment: "")

    /* Request Password */
    static let enterCurrentSpendingPassword = NSLocalizedString("enterCurrentSpendingPassword", comment: "")
    static let promptStartupPassword = NSLocalizedString("promptStartupPassword", comment: "")
    static let password = NSLocalizedString("password", comment: "")
    static let invalidInput = NSLocalizedString("invalidInput", comment: "")

    /* Request PIN and PIN Setup */
    static let enterPIN = NSLocalizedString("enterPIN", comment: "")
    static let enterCurrentSpendingPIN = NSLocalizedString("enterCurrentSpendingPIN", comment: "")
    static let promptStartupPIN = NSLocalizedString("promptStartupPIN", comment: "")
    static let createPIN = NSLocalizedString("createPIN", comment: "")
    static let confirmPIN = NSLocalizedString("confirmPIN", comment: "")
    static let pinsDidNotMatch = NSLocalizedString("pinsDidNotMatch", comment: "")
    static let pin = NSLocalizedString("pin", comment: "")
    static let next = NSLocalizedString("next", comment: "")
    static let create = NSLocalizedString("create", comment: "")

    /* Request Biometric */
    static let promptStartupPassOrPIN = NSLocalizedString("promptStartupPassOrPIN", comment: "")
    static let promptTouchIDUsageUsage = NSLocalizedString("promptTouchIDUsageUsage", comment: "")
    static let promptFaceIDUsageUsage = NSLocalizedString("promptFaceIDUsageUsage", comment: "")
    static let useFaceID = NSLocalizedString("useFaceID", comment: "")
    static let useTouchId = NSLocalizedString("useTouchId", comment: "")
    static let enableWithStartupCode = NSLocalizedString("enableWithStartupCode", comment: "")
    
    /* Overview - unlock wallets for account discovery */
    static let unlockToResumeRestoration = NSLocalizedString("unlockToResumeRestoration", comment: "")
    static let unlockWalletForAccountDiscovery = NSLocalizedString("unlockWalletForAccountDiscovery", comment: "")
    
    /* NavigationMenu / Sync progress */
    static let cannotSyncWithoutNetworkConnection = NSLocalizedString("cannotSyncWithoutNetworkConnection", comment: "")
    static let internetConnectionRequired = NSLocalizedString("internetConnectionRequired", comment: "")
    static let restartingSync = NSLocalizedString("restartingSync", comment: "")
    static let waitingForOtherWallets = NSLocalizedString("waitingForOtherWallets", comment: "")
    static let discoveringUsedAddresses = NSLocalizedString("discoveringUsedAddresses", comment: "")
    static let syncError = NSLocalizedString("syncError", comment: "")
    static let now = NSLocalizedString("now", comment: "")
    static let secondsAgo = NSLocalizedString("secondsAgo", comment: "")
    static let minAgo = NSLocalizedString("minAgo", comment: "")
    static let hrsAgo = NSLocalizedString("hrsAgo", comment: "")
    static let daysAgo = NSLocalizedString("daysAgo", comment: "")
    static let weeksAgo = NSLocalizedString("weeksAgo", comment: "")
    static let monthsAgo = NSLocalizedString("monthsAgo", comment: "")
    static let yearsAgo = NSLocalizedString("yearsAgo", comment: "")
    static let totalBalance = NSLocalizedString("totalBalance", comment: "")
    static let loading = NSLocalizedString("loading", comment: "")
    static let fetchedHeaders = NSLocalizedString("fetchedHeaders", comment: "")
    static let headersFetchProgress = NSLocalizedString("headersFetchProgress", comment: "")
    static let bestBlockAgebehind = NSLocalizedString("bestBlockAgebehind", comment: "")
    static let addressDiscoveryProgressOver = NSLocalizedString("addressDiscoveryProgressOver", comment: "")
    static let addressDiscoveryProgressThrough = NSLocalizedString("addressDiscoveryProgressThrough", comment: "")
    static let scanningTotalHeaders = NSLocalizedString("scanningTotalHeaders", comment: "")
    static let synchronizing = NSLocalizedString("synchronizing", comment: "")
    static let syncTotalProgress = NSLocalizedString("syncTotalProgress", comment: "")
    static let total = NSLocalizedString("total", comment: "")
    static let latestBlockAge = NSLocalizedString("latestBlockAge", comment: "")
    static let blockHeadersFetched = NSLocalizedString("blockHeadersFetched", comment: "")
    static let syncProgressComplete = NSLocalizedString("syncProgressComplete", comment: "")
    static let syncTimeLeft = NSLocalizedString("syncTimeLeft", comment: "")
    static let syncSteps = NSLocalizedString("syncSteps", comment: "")
    static let syncingProgress = NSLocalizedString("syncingProgress", comment: "")
    static let disconnect = NSLocalizedString("disconnect", comment: "")
    static let reconnect = NSLocalizedString("reconnect", comment: "")
    static let waitForSync = NSLocalizedString("waitForSync", comment: "")
    static let scannedBlocks = NSLocalizedString("scannedBlocks", comment: "")
    static let rescanningBlocks = NSLocalizedString("rescanningBlocks", comment: "")
    static let blocksLeft = NSLocalizedString("blocksLeft", comment: "")
    static let errorSyncInProgress = NSLocalizedString("errorSyncInProgress", comment: "")
    static let errorRescanInProgress = NSLocalizedString("errorRescanInProgress", comment: "")
    static let rescanProgressNotification = NSLocalizedString("rescanProgressNotification", comment: "")
    
    /* Navigation Menu Items */
    static let overview = NSLocalizedString("overview", comment: "")
    static let transactions = NSLocalizedString("transactions", comment: "")
    static let wallets = NSLocalizedString("wallets", comment: "")
    static let more = NSLocalizedString("more", comment: "")
    
    /* Overview */
    static let oneWalletNeedBackup = NSLocalizedString("oneWalletNeedBackup", comment: "")
    static let walletsNeedBackup = NSLocalizedString("walletsNeedBackup", comment: "")
    static let currentTotalBalance = NSLocalizedString("currentTotalBalance", comment: "")
    static let recentTransactions = NSLocalizedString("recentTransactions", comment: "")
    static let seeAll = NSLocalizedString("seeAll", comment: "")
    static let walletStatus = NSLocalizedString("walletStatus", comment: "")
    static let walletSynced = NSLocalizedString("walletSynced", comment: "")
    static let walletNotSynced = NSLocalizedString("walletNotSynced", comment: "")
    static let connectedTo = NSLocalizedString("connectedTo", comment: "")
    static let noConnectedPeer = NSLocalizedString("noConnectedPeer", comment: "")
    static let online = NSLocalizedString("online", comment: "")
    static let offline = NSLocalizedString("offline", comment: "")
    static let showDetails = NSLocalizedString("showDetails", comment: "")
    static let hideDetails = NSLocalizedString("hideDetails", comment: "")
    static let connectedPeersCount = NSLocalizedString("connectedPeersCount", comment: "")
    static let peers = NSLocalizedString("peers", comment: "")
    static let blockHeaderFetched = NSLocalizedString("blockHeaderFetched", comment: "")
    static let blockHeaderScanned = NSLocalizedString("blockHeaderScanned", comment: "")
    static let headersScannedProgress = NSLocalizedString("headersScannedProgress", comment: "")
    static let walletCreated = NSLocalizedString("walletCreated", comment: "")
    static let backUpYourWalletsReminder = NSLocalizedString("backUpYourWalletsReminder", comment: "")
    
    /* Transactions */
    static let pending = NSLocalizedString("pending", comment: "")
    static let confirmed = NSLocalizedString("confirmed", comment: "")
    static let voted = NSLocalizedString("voted", comment: "")
    static let ticket = NSLocalizedString("ticket", comment: "")
    static let live = NSLocalizedString("live", comment: "")
    static let immature = NSLocalizedString("immature", comment: "")
    static let noTransactions = NSLocalizedString("noTransactions", comment: "")
    static let sent = NSLocalizedString("sent", comment: "")
    static let received = NSLocalizedString("received", comment: "")
    static let yourself = NSLocalizedString("yourself", comment: "")
    static let staking = NSLocalizedString("staking", comment: "")
    static let coinbase = NSLocalizedString("coinbase", comment: "")
    static let all = NSLocalizedString("all", comment: "")
    static let today = NSLocalizedString("today", comment: "")
    static let yesterday = NSLocalizedString("yesterday", comment: "")
    static let days = NSLocalizedString("days", comment: "")
    static let newest = NSLocalizedString("newest", comment: "")
    static let oldest = NSLocalizedString("oldest", comment: "")
    
    /* Transaction Details */
    static let transactionDetails = NSLocalizedString("transactionDetails", comment: "")
    static let viewOnDcrdata = NSLocalizedString("viewOnDcrdata", comment: "")
    static let sgCopied = NSLocalizedString("sgCopied", comment: "")
    static let amount = NSLocalizedString("amount", comment: "")
    static let fee = NSLocalizedString("fee", comment: "")
    static let type = NSLocalizedString("type", comment: "")
    static let lastBlockValid = NSLocalizedString("lastBlockValid", comment: "")
    static let version = NSLocalizedString("version", comment: "")
    static let voteBits = NSLocalizedString("voteBits", comment: "")
    static let external = NSLocalizedString("external", comment: "")
    static let `internal` = NSLocalizedString("internal", comment: "")
    static let imported = NSLocalizedString("imported", comment: "")
    static let nullData = NSLocalizedString("nullData", comment: "")
    static let script = NSLocalizedString("script", comment: "")
    static let stakegen = NSLocalizedString("stakegen", comment: "")
    static let inputsConsumed = NSLocalizedString("inputsConsumed", comment: "")
    static let outputsCreated = NSLocalizedString("outputsCreated", comment: "")
    static let confirmations = NSLocalizedString("confirmations", comment: "")
    static let transactionID = NSLocalizedString("transactionID", comment: "")
    static let transferred = NSLocalizedString("transferred", comment: "")
    static let includedInBlock = NSLocalizedString("includedInBlock", comment: "")
    static let howToCopy = NSLocalizedString("howToCopy", comment: "")
    static let tapOnBlueText = NSLocalizedString("tapOnBlueText", comment: "")
    static let gotIt = NSLocalizedString("gotIt", comment: "")
    static let toAccountDetail = NSLocalizedString("toAccountDetail", comment: "")
    static let toDetail = NSLocalizedString("toDetail", comment: "")
    static let fromAccountDetail = NSLocalizedString("fromAccountDetail", comment: "")
    static let fromDetail = NSLocalizedString("fromDetail", comment: "")

    /* Send view */
    static let invalidAmount = NSLocalizedString("invalidAmount", comment: "")
    static let amount8Decimal = NSLocalizedString("amount8Decimal", comment: "")
    static let amountMaximumAllowed = NSLocalizedString("amountMaximumAllowed", comment: "")
    static let notEnoughFunds = NSLocalizedString("notEnoughFunds", comment: "")
    static let notEnoughFundsOrNotConnected = NSLocalizedString("notEnoughFundsOrNotConnected", comment: "")
    static let errorGettingMaxSpendable = NSLocalizedString("errorMaxSpendable", comment: "")
    static let notConnected = NSLocalizedString("notConnected", comment: "")
    static let invalidTesnetAddress = NSLocalizedString("invalidTesnetAddress", comment: "")
    static let invalidMainnetAddress = NSLocalizedString("invalidMainnetAddress", comment: "")
    static let invalidDestAddr = NSLocalizedString("invalidDestAddr", comment: "")
    static let from = NSLocalizedString("from", comment: "")
    static let sendHeaderInfo = NSLocalizedString("sendHeaderInfo", comment: "")
    static let destAddr = NSLocalizedString("destAddr", comment: "")
    static let exchangeRateNotFetched = NSLocalizedString("exchangeRateNotFetched", comment: "")
    static let confirmToSend = NSLocalizedString("confirmToSend", comment: "")
    static let sendDCR = NSLocalizedString("sendDCR", comment: "")
    static let paste = NSLocalizedString("paste", comment: "")
    static let selectFromAccount = NSLocalizedString("selectFromAccount", comment: "")
    static let failedToSendTryAgain = NSLocalizedString("failedToSendTryAgain", comment: "")
    static let sendToSelf = NSLocalizedString("sendToSelf", comment: "")
    static let sendToOthers = NSLocalizedString("sendToOthers", comment: "")
    static let transactionFee = NSLocalizedString("transactionFee", comment: "")
    static let processingTime = NSLocalizedString("processingTime", comment: "")
    static let feeRate = NSLocalizedString("feeRate", comment: "")
    static let transactionSize = NSLocalizedString("transactionSize", comment: "")
    static let totalCost = NSLocalizedString("totalCost", comment: "")
    static let balanceAfterSend = NSLocalizedString("balanceAfterSend", comment: "")
    static let sendWarning = NSLocalizedString("sendWarning", comment: "")
    static let sendingAccount = NSLocalizedString("sendingAccount", comment: "")
    static let toDestinationAddress = NSLocalizedString("toDestinationAddress", comment: "")
    static let destinationAddress = NSLocalizedString("destinationAddress", comment: "")
    static let toSelf = NSLocalizedString("toSelf", comment: "")
    static let transactionSent = NSLocalizedString("transactionSent", comment: "")
    
    /* Recieve */
    static let copyOnTap = NSLocalizedString("copyOnTap", comment: "")
    static let walletAddrCopied = NSLocalizedString("walletAddrCopied", comment: "")
    static let genNewAddr = NSLocalizedString("genNewAddr", comment: "")
    static let receiveDCR = NSLocalizedString("receiveDCR", comment: "")
    static let receivingAccount = NSLocalizedString("receivingAccount", comment: "")
    static let receiveInfo = NSLocalizedString("receiveInfo", comment: "")
    
    /* Wallets -> Add new wallet */
    static let createOrImportWallet = NSLocalizedString("createOrImportWallet", comment: "")
    static let confirmToCreateNewWallet = NSLocalizedString("confirmToCreateNewWallet", comment: "")
    static let confirmToImportWallet = NSLocalizedString("confirmToImportWallet", comment: "")
    static let walletsLimitError = NSLocalizedString("walletsLimitError", comment: "")
    static let import_ = NSLocalizedString("import_", comment: "")
    static let keyIsInvalid = NSLocalizedString("keyIsInvalid", comment: "")
    static let extendedPublicKey = NSLocalizedString("extendedPublicKey", comment: "")
    static let createWatchOnlyWallet = NSLocalizedString("createWatchOnlyWallet", comment: "")
    static let importAWatchOnlyWallet = NSLocalizedString("importAWatchOnlyWallet", comment: "")
    static let walletNameExists = NSLocalizedString("walletNameExists", comment: "")
    static let walletNameReserved = NSLocalizedString("walletNameReserved", comment: "")
    static let disconnectAddWallet = NSLocalizedString("disconnectAddWallet", comment: "")
    
    /* Wallets -> Sign message */
    static let signMessage = NSLocalizedString("signMessage", comment: "")
    
    /* Wallets -> Verify message */
    static let verifyMessage = NSLocalizedString("verifyMessage", comment: "")
    
    /* Wallets -> View property */
    static let viewProperty = NSLocalizedString("viewProperty", comment: "")
    
    /* Wallets -> Rename wallet */
    static let rename = NSLocalizedString("rename", comment: "")
    static let renameWallet = NSLocalizedString("renameWallet", comment: "")
    static let walletName = NSLocalizedString("walletName", comment: "")
    static let walletRenamed = NSLocalizedString("walletRenamed", comment: "")
    
    /* Wallet Settings -> Change Spending PIN/Password */
    static let changeSpendingPinPass = NSLocalizedString("changeSpendingPinPass", comment: "")
    static let confirmToChange = NSLocalizedString("confirmToChange", comment: "")
    static let spendingPinPassChanged = NSLocalizedString("spendingPinPassChanged", comment: "")
    
    /* Wallet Settings -> Notifications */
    static let incomingTransactions = NSLocalizedString("incomingTransactions", comment: "")
    static let silent = NSLocalizedString("silent", comment: "")
    static let vibrationOnly = NSLocalizedString("vibrationOnly", comment: "")
    static let soundOnly = NSLocalizedString("soundOnly", comment: "")
    static let soundAndVibration = NSLocalizedString("soundAndVibration", comment: "")

    /* Wallet Settings -> Remove wallet */
    static let removeWalletFromDevice = NSLocalizedString("removeWalletFromDevice", comment: "")
    static let removeWalletWarning = NSLocalizedString("removeWalletWarning", comment: "")
    static let confirmToRemove = NSLocalizedString("confirmToRemove", comment: "")
    static let walletRemoved = NSLocalizedString("walletRemoved", comment: "")
    static let disconnectDeleteWallet = NSLocalizedString("disconnectDeleteWallet", comment: "")
    static let removeWatchWalletPrompt = NSLocalizedString("removeWatchWalletPrompt", comment: "")
    
     /* Wallets -> Account */
    static let spendable = NSLocalizedString("spendable", comment: "")
    static let immatureRewards = NSLocalizedString("immatureRewards", comment: "")
    static let lockedByTickets = NSLocalizedString("lockedByTickets", comment: "")
    static let votingAuthority = NSLocalizedString("votingAuthority", comment: "")
    static let immatureStakeGeneration = NSLocalizedString("immatureStakeGeneration", comment: "")
    static let showProperties = NSLocalizedString("showProperties", comment: "")
    static let properties = NSLocalizedString("properties", comment: "")
    static let accountNumber = NSLocalizedString("accountNumber", comment: "")
    static let hDPath = NSLocalizedString("hDPath", comment: "")
    static let keys = NSLocalizedString("keys", comment: "")
    static let hideProperties = NSLocalizedString("hideProperties", comment: "")
    static let renameAccount = NSLocalizedString("renameAccount", comment: "")
    static let accountRenamed = NSLocalizedString("accountRenamed", comment: "")
    static let noWalletSelected = NSLocalizedString("noWalletSelected", comment: "")
    static let tapToSelectAccount = NSLocalizedString("tapToSelectAccount", comment: "")
    static let selectAccount = NSLocalizedString("selectAccount", comment: "")
    
    /* Wallets -> Account -> Add new account */
    static let addNewAccount = NSLocalizedString("addNewAccount", comment: "")
    static let accountName = NSLocalizedString("accountName", comment: "")
    static let createNewAccount = NSLocalizedString("createNewAccount", comment: "")
    static let accountCreated = NSLocalizedString("accountCreated", comment: "")
    
    /* Security Tools */
    static let securityTools = NSLocalizedString("securityTools", comment: "")
    static let securityToolsInfo = NSLocalizedString("securityToolsInfo", comment: "")
    static let validateAddresses = NSLocalizedString("validateAddresses", comment: "")
    static let validAddress = NSLocalizedString("validAddress", comment: "")
    static let validate = NSLocalizedString("validate", comment: "")
    static let invalidSignature = NSLocalizedString("invalidSignature", comment: "")
    static let verifiedSignature = NSLocalizedString("verifiedSignature", comment: "")
    static let verifyMsgHeaderInfo = NSLocalizedString("verifyMsgHeaderInfo", comment: "")
    static let verify = NSLocalizedString("verify", comment: "")
    static let address = NSLocalizedString("address", comment: "")
    static let message = NSLocalizedString("message", comment: "")
    static let signature = NSLocalizedString("signature", comment: "")
    static let validOwnAddr = NSLocalizedString("validOwnAddr", comment: "")
    static let validNotOwnAddr = NSLocalizedString("validNotOwnAddr", comment: "")
    static let invalidAddr = NSLocalizedString("invalidAddr", comment: "")
    static let verifyMessagepageInfo = NSLocalizedString("verifyMessagepageInfo", comment: "")
    static let signMsgHeaderInfo = NSLocalizedString("signMsgHeaderInfo", comment: "")
    static let signMsgPageInfo = NSLocalizedString("signMsgPageInfo", comment: "")
    static let signSuccesMessage = NSLocalizedString("signSuccesMessage", comment: "")
    static let signFailedMessage = NSLocalizedString("signFailedMessage", comment: "")
    
    /* Settings */
    static let startupPinPass = NSLocalizedString("startupPinPass", comment: "")
    static let changeStatupPinPass = NSLocalizedString("changeStatupPinPass", comment: "")
    static let spendUnconfirmedFund = NSLocalizedString("spendUnconfirmedFund", comment: "")
    static let currencyConversion = NSLocalizedString("currencyConversion", comment: "")
    static let beepForNewBlocks = NSLocalizedString("beepForNewBlocks", comment: "")
    static let connectIpDesc = NSLocalizedString("connectIpDesc", comment: "")
    static let syncOnWifiDesc = NSLocalizedString("syncOnWifiDesc", comment: "")
    static let userAgent = NSLocalizedString("userAgent", comment: "")
    static let userAgentInfo = NSLocalizedString("userAgentInfo", comment: "")
    static let setupUserAgent = NSLocalizedString("setupUserAgent", comment: "")
    static let buildDate = NSLocalizedString("buildDate", comment: "")
    static let walletLog = NSLocalizedString("walletLog", comment: "")
    static let none = NSLocalizedString("none", comment: "")
    static let rescanConfirm = NSLocalizedString("rescanConfirm", comment: "")
    static let rescanBlockchain = NSLocalizedString("rescanBlockchain", comment: "")
    static let general = NSLocalizedString("general", comment: "")
    static let connection = NSLocalizedString("connection", comment: "")
    static let about = NSLocalizedString("about", comment: "")
    static let debug = NSLocalizedString("debug", comment: "")
    static let checkStatistics = NSLocalizedString("checkStatistics", comment: "")
    static let statistics = NSLocalizedString("statistics", comment: "")
    static let seconds = NSLocalizedString("seconds", comment: "")
    static let minutes = NSLocalizedString("minutes", comment: "")
    static let hours = NSLocalizedString("hours", comment: "")
    static let weeks = NSLocalizedString("weeks", comment: "")
    static let months = NSLocalizedString("months", comment: "")
    static let years = NSLocalizedString("years", comment: "")
    static let net = NSLocalizedString("net", comment: "")

    /* Change startup/spending pin/pass */
    static let newPasswordPlaceholder = NSLocalizedString("newPasswordPlaceholder", comment: "")
    static let newPINPlaceholder = NSLocalizedString("newPINPlaceholder", comment: "")
    static let confirmNewPasswordPlaceholder = NSLocalizedString("confirmNewPasswordPlaceholder", comment: "")
    static let confirmNewPINPlaceholder = NSLocalizedString("confirmNewPINPlaceholder", comment: "")
    static let change = NSLocalizedString("change", comment: "")
    
    /* IP set */
    static let connectToPeer = NSLocalizedString("connectToPeer", comment: "")
    static let peerAddressIsInvalid = NSLocalizedString("peerAddressIsInvalid", comment: "")
    
    /* License */
    static let license = NSLocalizedString("license", comment: "")
    
    /* Wallet Log */
    static let copy = NSLocalizedString("copy", comment: "")
    static let walletLogCopied = NSLocalizedString("walletLogCopied", comment: "")
    
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
    static let clear = NSLocalizedString("clear", comment: "")
    static let error = NSLocalizedString("error", comment: "")
    static let retry = NSLocalizedString("retry", comment: "")
    static let ok = NSLocalizedString("ok", comment: "")
    static let confirm = NSLocalizedString("confirm", comment: "")
    static let remove = NSLocalizedString("remove", comment: "")
    static let cancel = NSLocalizedString("cancel", comment: "")
    static let back = NSLocalizedString("back", comment: "")
    static let clearFields =  NSLocalizedString("clearFields", comment: "")
    static let copiedSuccessfully = NSLocalizedString("copiedSuccessfully", comment: "")
    static let addrCopied = NSLocalizedString("addrCopied", comment: "")
    static let previousOutpointCopied = NSLocalizedString("previousOutpointCopied", comment: "")
    static let delete = NSLocalizedString("delete", comment: "")
    static let allowOnce = NSLocalizedString("allowOnce", comment: "")
    static let alwaysAllow = NSLocalizedString("alwaysAllow", comment: "")
    static let notNow = NSLocalizedString("notNow", comment: "")

    /* Other text */
    static let security = NSLocalizedString("security", comment: "")
    static let send = NSLocalizedString("send", comment: "")
    static let receive = NSLocalizedString("receive", comment: "")
    static let settings = NSLocalizedString("settings", comment: "")
    static let help = NSLocalizedString("help", comment: "")
    static let helpInfo = NSLocalizedString("helpInfo", comment: "")
    static let notifications = NSLocalizedString("notifications", comment: "")
    
    /* Seed Backup */
    static let failedToVerify = NSLocalizedString("failedToVerify", comment: "")
    
    /* Statistics */
    static let accounts = NSLocalizedString("accounts", comment: "")
    static let chainData = NSLocalizedString("chainData", comment: "")
    static let walletFile = NSLocalizedString("walletFile", comment: "")
    static let bestBlockAge = NSLocalizedString("bestBlockAge", comment: "")
    static let bestBlockTimestamp = NSLocalizedString("bestBlockTimestamp", comment: "")
    static let bestBlock = NSLocalizedString("bestBlock", comment: "")
    static let network = NSLocalizedString("network", comment: "")
    static let uptime = NSLocalizedString("uptime", comment: "")
    static let peersConnected = NSLocalizedString("peersConnected", comment: "")
    static let build = NSLocalizedString("build", comment: "")
}
