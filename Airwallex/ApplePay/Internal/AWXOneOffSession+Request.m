//
//  AWXOneOffSession+Request.m
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXOneOffSession+Request.h"
#import "AWXPaymentIntent+Summary.h"
#import "AWXPlaceDetails+PKContact.h"

@implementation AWXOneOffSession (Request)

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

    PKPaymentRequest *request = [PKPaymentRequest new];

    if (self.billing) {
        request.billingContact = [self.billing convertToPaymentContact];
    }

    if (!self.countryCode) {
        if (error) {
            *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Missing country code in session.", nil)}];
        }
        return nil;
    }
    
    request.countryCode = self.countryCode;
    request.currencyCode = self.currency;
    request.merchantCapabilities = options.merchantCapabilities;
    request.merchantIdentifier = options.merchantIdentifier;

    if (!self.paymentIntent) {
        if (error) {
            *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"paymentIntent cannot be nil.", nil)}];
        }
        return nil;
    }

    NSString *paymentIntentValidationError = [self validatePaymentIntentDataInSession:self.paymentIntent];
    if (paymentIntentValidationError) {
        if (error) {
            *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: paymentIntentValidationError}];
        }
        return nil;
    }

    PKPaymentSummaryItem *totalPriceItem = [self.paymentIntent paymentSummaryItemWithTotalPriceLabel:options.totalPriceLabel];

    if (options.additionalPaymentSummaryItems) {
        request.paymentSummaryItems = [options.additionalPaymentSummaryItems arrayByAddingObject:totalPriceItem];
    } else {
        request.paymentSummaryItems = @[totalPriceItem];
    }

    request.requiredBillingContactFields = options.requiredBillingContactFields;
    request.supportedCountries = options.supportedCountries;
    request.supportedNetworks = AWXApplePaySupportedNetworks();

    return request;
}

- (nullable NSString *)validatePaymentIntentDataInSession:(AWXPaymentIntent *)paymentIntent {
    if (!paymentIntent.amount) {
        return NSLocalizedString(@"Missing amount in PaymentIntent.", nil);
    }

    if (!paymentIntent.currency || paymentIntent.currency.length != 3) {
        return NSLocalizedString(@"Currency code should be three-letter ISO 4217 currency code.", nil);
    }

    if (!paymentIntent.Id) {
        return NSLocalizedString(@"Missing id in PaymentIntent.", nil);
    }

    return nil;
}
@end
