//
//  AWXProviderDelegateEmpty.m
//  CoreTests
//
//  Created by Hector.Huang on 2024/3/29.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#import "AWXProviderDelegateEmpty.h"

@implementation AWXProviderDelegateEmpty

- (void)provider:(nonnull AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error { 
    // no op
}

- (void)provider:(nonnull AWXDefaultProvider *)provider didInitializePaymentIntentId:(nonnull NSString *)paymentIntentId { 
    // no op
}

- (void)providerDidEndRequest:(nonnull AWXDefaultProvider *)provider { 
    // no op
}

- (void)providerDidStartRequest:(nonnull AWXDefaultProvider *)provider { 
    // no op
}

@end
