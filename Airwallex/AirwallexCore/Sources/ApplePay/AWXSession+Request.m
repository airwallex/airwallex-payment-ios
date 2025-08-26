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
#import "AWXUtils.h"

@implementation AWXSession (Request)

- (nullable PKPaymentRequest *)makePaymentRequestOrError:(NSError *_Nullable *)error {
    AWXApplePayOptions *options = self.applePayOptions;
    if (!options) {
        if (error) {
            *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Missing Apple Pay options in session."}];
        }
        return nil;
    }

    if (!options.merchantIdentifier) {
        if (error) {
            *error = [NSError errorWithDomain:AWXSDKErrorDomain
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Missing merchant identifier in apple pay options."}];
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
