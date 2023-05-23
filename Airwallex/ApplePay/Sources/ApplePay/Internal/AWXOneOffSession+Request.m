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

@end
