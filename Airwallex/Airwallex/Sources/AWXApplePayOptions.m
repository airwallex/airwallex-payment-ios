//
//  AWXApplePayOptions.m
//  Airwallex
//
//  Created by Jin Wang on 24/2/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXApplePayOptions.h"
#import "AWXConstants.h"

@implementation AWXApplePayOptions

- (instancetype)initWithMerchantIdentifier:(NSString *)merchantIdentifier
{
    self = [super init];
    if (self) {
        _merchantIdentifier = merchantIdentifier;
        _merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityEMV | PKMerchantCapabilityDebit | PKMerchantCapabilityCredit;
        _shippingType = PKShippingTypeShipping;
        _requiredBillingContactFields = [NSSet new];
    }
    return self;
}

@end
