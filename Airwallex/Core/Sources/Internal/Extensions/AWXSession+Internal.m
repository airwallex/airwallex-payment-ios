//
//  AWXSession+Internal.m
//  Core
//
//  Created by Jin Wang on 5/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXDefaultProvider.h"
#import "AWXPaymentMethod.h"
#import "AWXSession+Internal.h"

@implementation AWXSession (Internal)

- (NSArray<AWXPaymentMethodType *> *)filteredPaymentMethodTypes:(NSArray<AWXPaymentMethodType *> *)items {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
        AWXPaymentMethodType *item = (AWXPaymentMethodType *)evaluatedObject;

        // Filter out anything that doesn't even have a display name
        NSLog(@"%@", item.displayName);
        if (item.displayName == nil) {
            return NO;
        }

        Class class = ClassToHandleFlowForPaymentMethodType(item);

        // If no provider is available or if the provider is not able to handle the particular session,
        // then we should filter this method out.
        if (class == Nil || ![class canHandleSession:self paymentMethod:item]) {
            return NO;
        }

        return [item.transactionMode isEqualToString:self.transactionMode];
    }];

    return [items filteredArrayUsingPredicate:predicate];
}

@end
