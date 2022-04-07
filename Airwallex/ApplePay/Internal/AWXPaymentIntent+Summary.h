//
//  AWXPaymentIntent+Summary.h
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import <PassKit/PassKit.h>
#import "AWXPaymentIntent.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXPaymentIntent (Summary)

- (PKPaymentSummaryItem *)paymentSummaryItemWithTotalPriceLabel:(nullable NSString *)label;

@end

NS_ASSUME_NONNULL_END
