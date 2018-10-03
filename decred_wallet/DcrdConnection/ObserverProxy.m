//
//  ObserverProxy.m
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

#import "ObserverProxy.h"

/*@implementation GetTransactionObserveHub
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transactionNotificationsSubscribers = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void) subscribeForNotifications:(id<MobilewalletGetTransactionsResponse>)observer{
    [self.transactionNotificationsSubscribers addObject:observer];
}

- (void) unsubscribeForNotifications:(id<MobilewalletGetTransactionsResponse>)observer{
    [self.transactionNotificationsSubscribers removeObject:observer];
}

- (void)onResult:(NSString *)json {
    for (id<MobilewalletGetTransactionsResponse> observer in self.transactionNotificationsSubscribers) {
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
- (void) subscribeForBlockNotifications:(id<MobilewalletBlockNotificationError>)observer{
    [self.transactionBlockNotificationsSubscribers addObject:observer];
}
- (void) unsubscribeForBlockNotifications:(id<MobilewalletBlockNotificationError>)observer{
    [self.transactionBlockNotificationsSubscribers removeObject:observer];
}
- (void)onBlockNotificationError:(NSError *)err {
    for (id<MobilewalletBlockNotificationError> observer in self.transactionBlockNotificationsSubscribers) {
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

- (void) subscribeForUpdateNotifications:(id<MobilewalletTransactionListener>)observer{
    [self.transactionNotificationsSubscribers addObject:observer];
    
}

- (void) unsubscribeForUpdateNotifications:(id<MobilewalletTransactionListener>)observer{
    [self.transactionNotificationsSubscribers removeObject:observer];
}

- (void)onTransaction:(NSString *)transaction {
    for (id<MobilewalletTransactionListener> observer in self.transactionNotificationsSubscribers) {
        [observer onTransaction:transaction];
    }
}

- (void)onTransactionConfirmed:(NSString*)hash height:(int32_t)height; {
    for (id<MobilewalletTransactionListener> observer in self.transactionNotificationsSubscribers) {
        [observer onTransactionConfirmed:hash height:height];
    }
}
@end

@implementation BlockScanObserverHub
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.blockScanNotificationsSubscribers = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void) subscribeForBlockScanNotifications:(id<MobilewalletBlockScanResponse>)observer{
    [self.blockScanNotificationsSubscribers addObject:observer];
}

- (void) unsubscribeForBlockScanNotifications:(id<MobilewalletBlockScanResponse>)observer{
    [self.blockScanNotificationsSubscribers removeObject:observer];
}

- (void)onEnd:(int32_t)height cancelled:(BOOL)cancelled{
    for (id<MobilewalletBlockScanResponse> observer in self.blockScanNotificationsSubscribers) {
        [observer onEnd:height cancelled:cancelled];
    }
}
- (void)onError:(int32_t)code message:(NSString*)message{
    for (id<MobilewalletBlockScanResponse> observer in self.blockScanNotificationsSubscribers) {
        [observer onError:code message:message];
    }
}
- (BOOL)onScan:(int32_t)rescannedThrough{
    for (id<MobilewalletBlockScanResponse> observer in self.blockScanNotificationsSubscribers) {
        [observer onScan:rescannedThrough];
    }
    return true;
}

@end*/


