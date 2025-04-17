//
//  AWXApplePayOptions.m
//  Core
//
//  Created by Jin Wang on 22/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXApplePayOptions.h"
#import "AWXConstants.h"

@implementation AWXApplePayOptions

- (instancetype)initWithMerchantIdentifier:(NSString *)merchantIdentifier {
    self = [super init];
    if (self) {
        _merchantIdentifier = merchantIdentifier;
        _merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityEMV | PKMerchantCapabilityDebit | PKMerchantCapabilityCredit;
        _requiredBillingContactFields = [NSSet new];
        _supportedNetworks = AWXApplePaySupportedNetworks();
    }
    return self;
}

@end
