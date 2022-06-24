//
//  AWXSession+Internal.m
//  Core
//
//  Created by Jin Wang on 5/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXConstants+Internal.h"
#import "AWXDefaultProvider.h"
#import "AWXPaymentMethod.h"
#import "AWXSession+Internal.h"

@implementation AWXSession (Internal)

- (NSArray<AWXPaymentMethodType *> *)filteredPaymentMethodTypes:(NSArray<AWXPaymentMethodType *> *)items {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
        AWXPaymentMethodType *item = (AWXPaymentMethodType *)evaluatedObject;

        // Filter out unsupported payment methods.
        if ([AWXUnsupportedPaymentMethodTypes() containsObject:item.name]) {
            return NO;
        }

        Class class = ClassToHandleFlowForPaymentMethodType(item);

        // If no provider is available or if the provider is not able to handle the particular session,
        // then we should filter this method out.
        if (class == nil || ![class canHandleSession:self]) {
            return NO;
        }

        return [item.transactionMode isEqualToString:self.transactionMode];
    }];

    return [items filteredArrayUsingPredicate:predicate];
}

@end
