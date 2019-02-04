//
//  ObserverProxy.h
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

#import <Foundation/Foundation.h>
#import <Dcrlibwallet/Dcrlibwallet.h>


/*@class TransactionResponse;
@class Transaction;

@protocol TransactionNotificationsObserverProtocol
@property (nonatomic, strong) NSMutableArray<MobilewalletTransactionListener>* transactionNotificationsSubscribers;
- (void) subscribeForUpdateNotifications:(id<MobilewalletTransactionListener>)observer;
- (void) unsubscribeForUpdateNotifications:(id<MobilewalletTransactionListener>)observer;
@end

@protocol TransactionBlockNotificationObserverProtocol
@property (nonatomic, strong) NSMutableArray<MobilewalletBlockNotificationError>* transactionBlockNotificationsSubscribers;
- (void) subscribeForBlockNotifications:(id<MobilewalletBlockNotificationError>)observer;
- (void) unsubscribeForBlockNotifications:(id<MobilewalletBlockNotificationError>)observer;
@end

@protocol GetTransactionObserverProtocol
@property (nonatomic, strong) NSMutableArray<MobilewalletGetTransactionsResponse>* transactionNotificationsSubscribers;
- (void) subscribeForNotifications:(id<MobilewalletGetTransactionsResponse>)observer;
- (void) unsubscribeForNotifications:(id<MobilewalletGetTransactionsResponse>)observer;
@end

@interface GetTransactionObserveHub: NSObject <MobilewalletGetTransactionsResponse, GetTransactionObserverProtocol>
@property (nonatomic, strong) NSMutableArray<MobilewalletGetTransactionsResponse>* transactionNotificationsSubscribers;
- (void) subscribeForNotifications:(id<MobilewalletGetTransactionsResponse>)observer;
- (void) unsubscribeForNotifications:(id<MobilewalletGetTransactionsResponse>)observer;
@end

@interface TransactionBlockNotificationObserveHub : NSObject <MobilewalletBlockNotificationError>
@property (nonatomic, strong) NSMutableArray<MobilewalletBlockNotificationError>* transactionBlockNotificationsSubscribers;
- (void) subscribeForBlockNotifications:(id<MobilewalletBlockNotificationError>)observer;
- (void) unsubscribeForBlockNotifications:(id<MobilewalletBlockNotificationError>)observer;
@end

@interface TransactionNotificationsObserveHub : NSObject <MobilewalletTransactionListener, TransactionNotificationsObserverProtocol>
@property (nonatomic, strong) NSMutableArray<MobilewalletTransactionListener>* transactionNotificationsSubscribers;
- (void) subscribeForUpdateNotifications:(id<MobilewalletTransactionListener>)observer;
- (void) unsubscribeForUpdateNotifications:(id<MobilewalletTransactionListener>)observer;
@end

@interface BlockScanObserverHub : NSObject <MobilewalletBlockScanResponse>
@property (nonatomic, strong) NSMutableArray<MobilewalletBlockScanResponse>* blockScanNotificationsSubscribers;
- (void) subscribeForBlockScanNotifications:(id<MobilewalletBlockScanResponse>)observer;
- (void) unsubscribeForBlockScanNotifications:(id<MobilewalletBlockScanResponse>)observer;
@end*/
