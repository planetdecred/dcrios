// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
//  ObserverProxy.m
//  Decred Wallet

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

- (void) subscribeForNotifications:(id<DcrlibwalletGetTransactionsResponse>)observer{
    [self.transactionNotificationsSubscribers addObject:observer];
}

- (void) unsubscribeForNotifications:(id<DcrlibwalletGetTransactionsResponse>)observer{
    [self.transactionNotificationsSubscribers removeObject:observer];
}

- (void)onResult:(NSString *)json {
    for (id<DcrlibwalletGetTransactionsResponse> observer in self.transactionNotificationsSubscribers) {
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
- (void) subscribeForBlockNotifications:(id<DcrlibwalletBlockNotificationError>)observer{
    [self.transactionBlockNotificationsSubscribers addObject:observer];
}
- (void) unsubscribeForBlockNotifications:(id<DcrlibwalletBlockNotificationError>)observer{
    [self.transactionBlockNotificationsSubscribers removeObject:observer];
}
- (void)onBlockNotificationError:(NSError *)err {
    for (id<DcrlibwalletBlockNotificationError> observer in self.transactionBlockNotificationsSubscribers) {
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

- (void) subscribeForUpdateNotifications:(id<DcrlibwalletTransactionListener>)observer{
    [self.transactionNotificationsSubscribers addObject:observer];
    
}

- (void) unsubscribeForUpdateNotifications:(id<DcrlibwalletTransactionListener>)observer{
    [self.transactionNotificationsSubscribers removeObject:observer];
}

- (void)onTransaction:(NSString *)transaction {
    for (id<DcrlibwalletTransactionListener> observer in self.transactionNotificationsSubscribers) {
        [observer onTransaction:transaction];
    }
}

- (void)onTransactionConfirmed:(NSString*)hash height:(int32_t)height; {
    for (id<DcrlibwalletTransactionListener> observer in self.transactionNotificationsSubscribers) {
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

- (void) subscribeForBlockScanNotifications:(id<DcrlibwalletBlockScanResponse>)observer{
    [self.blockScanNotificationsSubscribers addObject:observer];
}

- (void) unsubscribeForBlockScanNotifications:(id<DcrlibwalletBlockScanResponse>)observer{
    [self.blockScanNotificationsSubscribers removeObject:observer];
}

- (void)onEnd:(int32_t)height cancelled:(BOOL)cancelled{
    for (id<DcrlibwalletBlockScanResponse> observer in self.blockScanNotificationsSubscribers) {
        [observer onEnd:height cancelled:cancelled];
    }
}
- (void)onError:(int32_t)code message:(NSString*)message{
    for (id<DcrlibwalletBlockScanResponse> observer in self.blockScanNotificationsSubscribers) {
        [observer onError:code message:message];
    }
}
- (BOOL)onScan:(int32_t)rescannedThrough{
    for (id<DcrlibwalletBlockScanResponse> observer in self.blockScanNotificationsSubscribers) {
        [observer onScan:rescannedThrough];
    }
    return true;
}

@end*/


