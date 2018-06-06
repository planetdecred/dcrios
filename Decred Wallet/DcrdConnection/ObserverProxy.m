//
//  ObserverProxy.m
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

#import "ObserverProxy.h"

@implementation WalletGetTransactionResponseStruct (ObserverProxy)
+ (void) swizzle {
    Class thisClass = self;
    SEL onResultSEL = @selector(onResult:);
    Method onResultMethod = class_getInstanceMethod(thisClass, onResultSEL);
    
    SEL onJsonResultSEL = @selector(onJsonResult:);
    Method onJsonResultMethod = class_getInstanceMethod(thisClass, onJsonResultSEL);
    method_exchangeImplementations(onJsonResultMethod, onResultMethod);
}

- (void) onJsonResult:(NSString *)json{
    NSLog(@"Swizzled: %@\n", json);
}
@end

