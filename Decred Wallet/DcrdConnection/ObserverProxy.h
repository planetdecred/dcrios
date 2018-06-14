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

//@protocol WalletBlockNotificationError <NSObject>
//- (void)onBlockNotificationError:(NSError*)err;
//@end
//
//@protocol WalletGetTransactionsResponse <NSObject>
//- (void)onResult:(NSString*)json;
//@end
//
//@protocol WalletTransactionListener <NSObject>
//- (void)onTransaction:(NSString*)transaction;
//- (void)onTransactionRefresh;
//@end

@protocol TransactionNotificationsObserverProtocol
@property (nonatomic, strong) NSMutableArray<WalletTransactionListener>* transactionNotificationsSubscribers;
- (void) subscribeForNotifications:(id<WalletTransactionListener>)observer;
- (void) unsubscribeForNotifications:(id<WalletTransactionListener>)observer;
@end

@protocol TransactionBlockNotificationObserverProtocol
@property (nonatomic, strong) NSMutableArray<WalletBlockNotificationError>* transactionBlockNotificationsSubscribers;
- (void) subscribeForNotifications:(id<WalletBlockNotificationError>)observer;
- (void) unsubscribeForNotifications:(id<WalletBlockNotificationError>)observer;
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
- (void) subscribeForNotifications:(id<WalletBlockNotificationError>)observer;
- (void) unsubscribeForNotifications:(id<WalletBlockNotificationError>)observer;
@end

@interface TransactionNotificationsObserveHub : NSObject <WalletTransactionListener, TransactionNotificationsObserverProtocol>
@property (nonatomic, strong) NSMutableArray<WalletTransactionListener>* transactionNotificationsSubscribers;
- (void) subscribeForNotifications:(id<WalletTransactionListener>)observer;
- (void) unsubscribeForNotifications:(id<WalletTransactionListener>)observer;
@end
