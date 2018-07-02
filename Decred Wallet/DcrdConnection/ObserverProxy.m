//
//  ObserverProxy.m
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

#import "ObserverProxy.h"

@implementation GetTransactionObserveHub
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transactionNotificationsSubscribers = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void) subscribeForNotifications:(id<WalletGetTransactionsResponse>)observer{
    [self.transactionNotificationsSubscribers addObject:observer];
}

- (void) unsubscribeForNotifications:(id<WalletGetTransactionsResponse>)observer{
    [self.transactionNotificationsSubscribers removeObject:observer];
}

- (void)onResult:(NSString *)json {
    for (id<WalletGetTransactionsResponse> observer in self.transactionNotificationsSubscribers) {
        [observer onResult:json];
    }
}

@end

@implementation TransactionBlockNotificationObserveHub
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transactionBlockNotificationsSubscribers = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}
- (void) subscribeForBlockNotifications:(id<WalletBlockNotificationError>)observer{
    [self.transactionBlockNotificationsSubscribers addObject:observer];
}
- (void) unsubscribeForBlockNotifications:(id<WalletBlockNotificationError>)observer{
    [self.transactionBlockNotificationsSubscribers removeObject:observer];
}
- (void)onBlockNotificationError:(NSError *)err {
    for (id<WalletBlockNotificationError> observer in self.transactionBlockNotificationsSubscribers) {
        [observer onBlockNotificationError:err];
    }
}

@end

@implementation TransactionNotificationsObserveHub
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transactionNotificationsSubscribers = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void) subscribeForUpdateNotifications:(id<WalletTransactionListener>)observer{
    [self.transactionNotificationsSubscribers addObject:observer];
    
}

- (void) unsubscribeForUpdateNotifications:(id<WalletTransactionListener>)observer{
    [self.transactionNotificationsSubscribers removeObject:observer];
}

- (void)onTransaction:(NSString *)transaction {
    for (id<WalletTransactionListener> observer in self.transactionNotificationsSubscribers) {
        [observer onTransaction:transaction];
    }
}

- (void)onTransactionConfirmed:(NSString*)hash height:(int32_t)height; {
    for (id<WalletTransactionListener> observer in self.transactionNotificationsSubscribers) {
        [observer onTransactionConfirmed:hash height:height];
    }
}

@end
