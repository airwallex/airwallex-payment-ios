//
//  AWXPaymentIntent+Summary.m
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentIntent+Summary.h"

@implementation AWXPaymentIntent (Summary)

- (PKPaymentSummaryItem *)paymentSummaryItemWithTotalPriceLabel:(nullable NSString *)label
{
    PKPaymentSummaryItem *item = [PKPaymentSummaryItem new];
    item.type = PKPaymentSummaryItemTypeFinal;
    item.amount = self.amount;
    if (label) {
        item.label = label;
    } else {
        item.label = @"";
    }
    
    return item;
}

@end
