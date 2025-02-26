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

- (instancetype)init {
    if (self = [super init]) {
        self.isBillingInformationRequired = YES;
    }

    return self;
}

- (AWXPlaceDetails *)billing {
    if (!self.isBillingInformationRequired) {
        return nil;
    }

    return _billing;
}

- (NSString *)transactionMode {
    return oneoff;
}

@end

@implementation AWXSession (Utils)

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

@end

@implementation AWXOneOffSession

- (instancetype)init {
    if (self = [super init]) {
        self.autoCapture = YES;
        self.isCardSavingEnabledByDefault = YES;
    }

    return self;
}

@end

@implementation AWXRecurringSession

- (NSString *)transactionMode {
    return recurring;
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
    return recurring;
}

@end
