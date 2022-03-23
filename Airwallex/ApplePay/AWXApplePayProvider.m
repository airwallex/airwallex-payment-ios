//
//  AWXApplePayProvider.m
//  ApplePay
//
//  Created by Jin Wang on 23/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXApplePayProvider.h"
#import "AWXSession.h"

@implementation AWXApplePayProvider

+ (BOOL)canHandleSession:(AWXSession *)session
{
    if ([session isKindOfClass:[AWXOneOffSession class]]) {
        AWXOneOffSession *oneOffSession = (AWXOneOffSession *)session;
        if (oneOffSession.applePayOptions == nil) {
            return NO;
        }
        return [PKPaymentAuthorizationController canMakePaymentsUsingNetworks:AWXApplePaySupportedNetworks()
                                                                 capabilities:oneOffSession.applePayOptions.merchantCapabilities];
    } else {
        return NO;
    }
}

- (void)handleFlow
{
    // TODO: This will be replaced with real implementation.
    [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusSuccess error: nil];
}

@end
