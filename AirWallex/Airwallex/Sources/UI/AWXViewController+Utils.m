//
//  AWXViewController+Utils.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/7/8.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXViewController+Utils.h"
#import "AWXUIContext.h"
#import "AWXPlaceDetails.h"
#import "AWXPaymentIntent.H"

@implementation AWXViewController (Utils)

- (nullable AWXPlaceDetails *)billing
{
    return self.session.billing;
}

- (NSArray *)customerPaymentConsents
{
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self.session;
        return session.paymentIntent.paymentConsents;
    }
    if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
        return session.paymentIntent.paymentConsents;
    }
    return @[];
}

- (NSArray *)customerPaymentMethods
{
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self.session;
        return session.paymentIntent.paymentMethods;
    }
    if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
        return session.paymentIntent.paymentMethods;
    }
    return @[];
}

- (nullable NSString *)customerId
{
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self.session;
        return session.paymentIntent.customerId;
    }
    if ([self.session isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self.session;
        return session.customerId;
    }
    if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
        return session.paymentIntent.customerId;
    }
    return nil;
}

- (NSString *)currency
{
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self.session;
        return session.paymentIntent.currency;
    }
    if ([self.session isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self.session;
        return session.currency;
    }
    if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
        return session.paymentIntent.currency;
    }
    return @"";
}

- (NSDecimalNumber *)amount
{
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self.session;
        return session.paymentIntent.amount;
    }
    if ([self.session isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self.session;
        return session.amount;
    }
    if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
        return session.paymentIntent.amount;
    }
    return nil;
}

- (nullable NSString *)paymentIntentId
{
    if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self.session;
        return session.paymentIntent.Id;
    }
    if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
        return session.paymentIntent.Id;
    }
    return nil;
}

- (AirwallexNextTriggerByType)nextTriggerByType
{
    if ([self.session isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self.session;
        return session.nextTriggerBy;
    }
    if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self.session;
        return session.nextTriggerBy;
    }
    return AirwallexNextTriggerByCustomerType;
}

@end
