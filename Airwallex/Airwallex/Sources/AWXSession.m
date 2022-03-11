//
//  AWXSession.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/11.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXSession.h"
#import "AWXPaymentIntentRequest.h"

static NSString *const oneoff = @"oneoff";
static NSString *const recurring = @"recurring";

@interface AWXSession ()

@property (nonatomic, strong, nullable) NSString *initialPaymentIntentId;

@end

@implementation AWXSession

- (NSString *)transactionMode
{
    return oneoff;
}

@end

@implementation AWXSession (Utils)

- (void)updateInitialPaymentIntentId:(NSString *)initialPaymentIntentId
{
    self.initialPaymentIntentId = initialPaymentIntentId;
}

- (NSArray *)customerPaymentMethods
{
    if ([self isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self;
        return session.paymentIntent.paymentMethods;
    }
    if ([self isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self;
        return session.paymentIntent.paymentMethods;
    }
    return @[];
}

- (NSArray *)customerPaymentConsents
{
    if ([self isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self;
        return session.paymentIntent.paymentConsents;
    }
    if ([self isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self;
        return session.paymentIntent.paymentConsents;
    }
    return @[];
}

- (nullable NSString *)customerId
{
    if ([self isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self;
        return session.paymentIntent.customerId;
    }
    if ([self isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self;
        return session.customerId;
    }
    if ([self isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self;
        return session.paymentIntent.customerId;
    }
    return nil;
}

- (NSString *)currency
{
    if ([self isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self;
        return session.paymentIntent.currency;
    }
    if ([self isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self;
        return session.currency;
    }
    if ([self isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self;
        return session.paymentIntent.currency;
    }
    return @"";
}

- (NSDecimalNumber *)amount
{
    if ([self isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self;
        return session.paymentIntent.amount;
    }
    if ([self isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self;
        return session.amount;
    }
    if ([self isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self;
        return session.paymentIntent.amount;
    }
    return nil;
}

- (nullable NSString *)paymentIntentId
{
    if ([self isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self;
        return session.paymentIntent.Id;
    }
    if ([self isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self;
        return session.initialPaymentIntentId;
    }
    if ([self isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self;
        return session.paymentIntent.Id;
    }
    return nil;
}

- (BOOL)requiresCVC
{
    if ([self isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self;
        return session.requiresCVC;
    }
    if ([self isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self;
        return session.requiresCVC;
    }
    return NO;
}

- (BOOL)autoCapture
{
    if ([self isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self;
        return session.autoCapture;
    }
    if ([self isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self;
        return session.autoCapture;
    }
    return YES;
}

@end

@implementation AWXOneOffSession

@end

@implementation AWXRecurringSession

- (NSString *)transactionMode
{
    return recurring;
}

@end

@implementation AWXRecurringWithIntentSession

- (NSString *)transactionMode
{
    return recurring;
}

@end
