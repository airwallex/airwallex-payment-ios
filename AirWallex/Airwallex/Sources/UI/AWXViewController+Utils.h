//
//  AWXViewController+Utils.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/7/8.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXViewController.h"
#import "AWXConstants.h"

@class AWXPlaceDetails;

NS_ASSUME_NONNULL_BEGIN

@interface AWXViewController (Utils)

- (nullable AWXPlaceDetails *)billing;
- (NSArray *)customerPaymentConsents;
- (NSArray *)customerPaymentMethods;
- (nullable NSString *)customerId;
- (NSString *)currency;
- (NSDecimalNumber *)amount;
- (nullable NSString *)paymentIntentId;
- (AirwallexNextTriggerByType)nextTriggerByType;

@end

NS_ASSUME_NONNULL_END
