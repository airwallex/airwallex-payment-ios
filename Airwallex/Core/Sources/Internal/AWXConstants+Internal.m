//
//  AWXConstants+Internal.m
//  Core
//
//  Created by Jin Wang on 5/4/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXConstants+Internal.h"

NSArray<NSString *> *AWXUnsupportedPaymentMethodTypes(void) {
    return @[
        @"googlepay",
        @"ach_direct_debit",
        @"becs_direct_debit",
        @"sepa_direct_debit",
        @"bacs_direct_debit"
    ];
}
