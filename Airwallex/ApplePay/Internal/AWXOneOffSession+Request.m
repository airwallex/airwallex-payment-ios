//
//  AWXOneOffSession+Request.m
//  ApplePay
//
//  Created by Jin Wang on 25/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXOneOffSession+Request.h"
#import "AWXPaymentIntent+Summary.h"

@implementation AWXOneOffSession (Request)

- (nullable PKPaymentRequest *)makePaymentRequestOrError:(NSError * _Nullable *)error
{
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
    request.paymentSummaryItems = [self.paymentIntent paymentSummaryItemsWithTotalPriceLabel:options.totalPriceLabel];
    request.merchantIdentifier = options.merchantIdentifier;
    request.merchantCapabilities = options.merchantCapabilities;
    request.countryCode = self.countryCode;
    request.currencyCode = self.currency;
    request.supportedNetworks = AWXApplePaySupportedNetworks();
    request.shippingContact = options.shippingContact;
    request.shippingType = options.shippingType;
    request.shippingMethods = options.shippingMethods;
    request.billingContact = options.billingContact;
    request.requiredBillingContactFields = options.requiredBillingContactFields;
    request.requiredShippingContactFields = options.requiredShippingContactFields;
    request.supportedCountries = options.supportedCountries;
    
    return request;
}

@end
