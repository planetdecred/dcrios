//
//  ObserverProxy.h
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

#import <Foundation/Foundation.h>
#import <Wallet/Wallet.h>
#import <objc/runtime.h>

//@interface WalletGetTransactionResponseStruct (ObserverProxy)
//@property(nonatomic, strong)NSMutableArray<NSString*>* transactions;
//- (void) populateTransaction:(NSString*)transaction;
//- (void) refresh;
//@end

@interface WalletGetTransactionResponseStruct (ObserverProxy)
+ (void) swizzle;
- (void) onJsonResult:(NSString *)json;
@end

//
//@implementation WalletTransactionBlockListenerStruct (ObserverProxy)
//- (void)onBlockNotificationError:(NSError*)err{
//    NSLog(@"%@",[error localizedDescription]);
//}
//@end
//
//@implementation WalletTransactionListenerStruct (ObserverProxy)
//- (void)onTransaction:(NSString*)transaction{
//    NSLog(transaction);
//}
//
//- (void)onTransactionRefresh{
//    NSLog("refresh");
//}
//@end
