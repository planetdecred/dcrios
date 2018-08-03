//
//  ObserverProxy.h
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

#import <Foundation/Foundation.h>
#import <Wallet/Wallet.h>


@class TransactionResponse;
@class Transaction;

@protocol TransactionNotificationsObserverProtocol
@property (nonatomic, strong) NSMutableArray<WalletTransactionListener>* transactionNotificationsSubscribers;
- (void) subscribeForUpdateNotifications:(id<WalletTransactionListener>)observer;
- (void) unsubscribeForUpdateNotifications:(id<WalletTransactionListener>)observer;
@end

@protocol TransactionBlockNotificationObserverProtocol
@property (nonatomic, strong) NSMutableArray<WalletBlockNotificationError>* transactionBlockNotificationsSubscribers;
- (void) subscribeForBlockNotifications:(id<WalletBlockNotificationError>)observer;
- (void) unsubscribeForBlockNotifications:(id<WalletBlockNotificationError>)observer;
@end

@protocol GetTransactionObserverProtocol
@property (nonatomic, strong) NSMutableArray<WalletGetTransactionsResponse>* transactionNotificationsSubscribers;
- (void) subscribeForNotifications:(id<WalletGetTransactionsResponse>)observer;
- (void) unsubscribeForNotifications:(id<WalletGetTransactionsResponse>)observer;
@end

@interface GetTransactionObserveHub: NSObject <WalletGetTransactionsResponse, GetTransactionObserverProtocol>
@property (nonatomic, strong) NSMutableArray<WalletGetTransactionsResponse>* transactionNotificationsSubscribers;
- (void) subscribeForNotifications:(id<WalletGetTransactionsResponse>)observer;
- (void) unsubscribeForNotifications:(id<WalletGetTransactionsResponse>)observer;
@end

@interface TransactionBlockNotificationObserveHub : NSObject <WalletBlockNotificationError>
@property (nonatomic, strong) NSMutableArray<WalletBlockNotificationError>* transactionBlockNotificationsSubscribers;
- (void) subscribeForBlockNotifications:(id<WalletBlockNotificationError>)observer;
- (void) unsubscribeForBlockNotifications:(id<WalletBlockNotificationError>)observer;
@end

@interface TransactionNotificationsObserveHub : NSObject <WalletTransactionListener, TransactionNotificationsObserverProtocol>
@property (nonatomic, strong) NSMutableArray<WalletTransactionListener>* transactionNotificationsSubscribers;
- (void) subscribeForUpdateNotifications:(id<WalletTransactionListener>)observer;
- (void) unsubscribeForUpdateNotifications:(id<WalletTransactionListener>)observer;
@end

@interface BlockScanObserverHub : NSObject <WalletBlockScanResponse>
@property (nonatomic, strong) NSMutableArray<WalletBlockScanResponse>* blockScanNotificationsSubscribers;
- (void) subscribeForBlockScanNotifications:(id<WalletBlockScanResponse>)observer;
- (void) unsubscribeForBlockScanNotifications:(id<WalletBlockScanResponse>)observer;
@end
