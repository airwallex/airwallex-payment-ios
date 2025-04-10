//
//  AWXSession+Request.m
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXPaymentIntent+Summary.h"
#import "AWXPlaceDetails+PKContact.h"
#import "AWXSession+Request.h"

@implementation AWXSession (Request)

- (nullable PKPaymentRequest *)makePaymentRequestOrError:(NSError *_Nullable *)error {
    AWXApplePayOptions *options = self.applePayOptions;
    if (!options) {
        if (error) {
            *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Missing Apple Pay options in session.", nil)}];
        }
        return nil;
    }

    if (!options.merchantIdentifier) {
        if (error) {
            *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Missing merchant identifier in apple pay options.", nil)}];
        }
        return nil;
    }

    PKPaymentRequest *request = [PKPaymentRequest new];

    if (self.billing) {
        request.billingContact = [self.billing convertToPaymentContact];
    }

    NSString *validationError = [self validateData];
    if (validationError) {
        if (error) {
            *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: validationError}];
        }
        return nil;
    }

    request.countryCode = self.countryCode;
    request.currencyCode = self.currency;
    request.merchantCapabilities = options.merchantCapabilities;
    request.merchantIdentifier = options.merchantIdentifier;

    PKPaymentSummaryItem *totalPriceItem = [self paymentSummaryItemWithTotalPriceLabel:options.totalPriceLabel];

    if (options.additionalPaymentSummaryItems) {
        request.paymentSummaryItems = [options.additionalPaymentSummaryItems arrayByAddingObject:totalPriceItem];
    } else {
        request.paymentSummaryItems = @[totalPriceItem];
    }

    request.requiredBillingContactFields = options.requiredBillingContactFields;
    request.supportedCountries = options.supportedCountries;
    request.supportedNetworks = options.supportedNetworks;

    return request;
}

- (nullable NSString *)validateData {
    if (!self.countryCode) {
        return NSLocalizedString(@"Missing country code in session.", nil);
    }
    if ([self isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *session = (AWXOneOffSession *)self;
        return [self validatePaymentIntentData:session.paymentIntent];
    }
    if ([self isKindOfClass:[AWXRecurringSession class]]) {
        AWXRecurringSession *session = (AWXRecurringSession *)self;
        if (!session.amount) {
            return NSLocalizedString(@"Missing amount in RecurringSession.", nil);
        }
        if (!session.currency || session.currency.length != 3) {
            return NSLocalizedString(@"RecurringSession currency should be three-letter ISO 4217 currency code.", nil);
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
        return NSLocalizedString(@"PaymentIntent cannot be nil.", nil);
    }
    if (!paymentIntent.amount) {
        return NSLocalizedString(@"Missing amount in PaymentIntent.", nil);
    }

    if (!paymentIntent.currency || paymentIntent.currency.length != 3) {
        return NSLocalizedString(@"PaymentIntent currency should be three-letter ISO 4217 currency code.", nil);
    }

    if (!paymentIntent.Id) {
        return NSLocalizedString(@"Missing id in PaymentIntent.", nil);
    }

    return nil;
}

- (PKPaymentSummaryItem *)paymentSummaryItemWithTotalPriceLabel:(nullable NSString *)label {
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
