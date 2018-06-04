//
//  ObserverProxy.h
//  Decred Wallet
//
//  Created by Philipp Maluta on 04.06.2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Wallet/Wallet.h>

@interface ObserverProxyProtocol
@property(nonatomic, strong)NSMutableArray<NSString*>* transactions;
- (void) populateTransaction:(NSString*)transaction;
- (void) refresh;
@end

@implementation WalletGetTransactionResponseStruct (ObserverProxy)
- (void)onResult:(NSString *)json {
    NSLog(json);
}

@end
