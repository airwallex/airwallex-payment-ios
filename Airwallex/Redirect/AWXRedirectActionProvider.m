//
//  AWXRedirectActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXRedirectActionProvider.h"
#import "AWXAnalyticsLogger.h"
#import "AWXPaymentIntentResponse.h"
#import "NSObject+Logging.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation AWXRedirectActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    [self.delegate provider:self shouldPresentViewController:nil forceToDismiss:YES withAnimation:YES];

    NSURL *url = [NSURL URLWithString:nextAction.url];
    if (url) {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success) {
                                     if (url.absoluteString.length > 0) {
                                         if (success) {
                                             [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusInProgress error:nil];
                                             [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu", self.delegate.class, AirwallexPaymentStatusInProgress];
                                             [[AWXAnalyticsLogger shared] logPageViewWithName:@"payment_redirect" additionalInfo:@{@"url": url.absoluteString}];
                                         } else {
                                             NSError *error = [NSError errorForAirwallexSDKWith:[NSString stringWithFormat:NSLocalizedString(@"Redirect to app failed. %@", nil), url.absoluteString]];
                                             [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:error];
                                             [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu  %@", self.delegate.class, AirwallexPaymentStatusFailure, error.description];
                                             NSDictionary *info = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Redirect to app failed.", nil), NSURLErrorKey: url.absoluteString};

                                             [[AWXAnalyticsLogger shared] logErrorWithName:@"payment_redirect" additionalInfo:info];
                                         }
                                     }
                                 }];
    }
}

@end
