//
//  AWXSession.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/11.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXSession.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXUtils.h"

@interface AWXSession ()

@property (nonatomic, strong, nullable) NSString *initialPaymentIntentId;

@end

@implementation AWXSession

- (instancetype)init {
    if (self = [super init]) {
        self.requiredBillingContactFields = AWXRequiredBillingContactFieldName;
        self.lang = [[[NSBundle mainBundle] preferredLocalizations] firstObject] ?: NSLocale.currentLocale.languageCode;
    }

    return self;
}

- (NSString *)transactionMode {
    return AWXPaymentTransactionModeOneOff;
}

- (void)updateInitialPaymentIntentId:(NSString *)initialPaymentIntentId {
    self.initialPaymentIntentId = initialPaymentIntentId;
}

- (NSArray *)customerPaymentMethods {
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

- (NSArray *)customerPaymentConsents {
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

- (nullable NSString *)customerId {
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

- (NSString *)currency {
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

- (NSDecimalNumber *)amount {
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

- (nullable NSString *)paymentIntentId {
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

- (BOOL)requiresCVC {
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

- (nullable NSString *)validateData {
    if (!self.countryCode) {
        return @"Missing country code in session.";
    }
    if ([self isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self;
        return [self validatePaymentIntentData:session.paymentIntent];
    }
    if ([self isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self;
        if (!session.amount) {
            return @"Missing amount in RecurringSession.";
        }
        if (!session.currency || session.currency.length != 3) {
            return @"RecurringSession currency should be three-letter ISO 4217 currency code.";
        }
    }
    if ([self isKindOfClass:[AWXRecurringWithIntentSession class]]) {
        AWXRecurringWithIntentSession *session = (AWXRecurringWithIntentSession *)self;
        return [self validatePaymentIntentData:session.paymentIntent];
    }
    return nil;
}

- (nullable NSString *)validatePaymentIntentData:(nullable AWXPaymentIntent *)paymentIntent {
    if (!paymentIntent) {
        return @"PaymentIntent cannot be nil.";
    }
    if (!paymentIntent.amount) {
        return @"Missing amount in PaymentIntent.";
    }

    if (!paymentIntent.currency || paymentIntent.currency.length != 3) {
        return @"PaymentIntent currency should be three-letter ISO 4217 currency code.";
    }

    if (!paymentIntent.Id) {
        return @"Missing id in PaymentIntent.";
    }

    return nil;
}

@end

@implementation AWXOneOffSession

- (instancetype)init {
    if (self = [super init]) {
        self.autoCapture = YES;
        self.autoSaveCardForFuturePayments = YES;
    }
    return self;
}

@end

@implementation AWXRecurringSession

- (NSString *)transactionMode {
    return AWXPaymentTransactionModeRecurring;
}

@end

@implementation AWXRecurringWithIntentSession

- (instancetype)init {
    if (self = [super init]) {
        self.autoCapture = YES;
    }

    return self;
}

- (NSString *)transactionMode {
    return AWXPaymentTransactionModeRecurring;
}

@end
