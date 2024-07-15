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

@implementation AWXRedirectActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    [self.delegate provider:self shouldPresentViewController:nil forceToDismiss:YES withAnimation:YES];
    [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusInProgress error:nil];
    [self log:@"Delegate: %@, provider:didCompleteWithStatus:error:  %lu", self.delegate.class, (unsigned long)AirwallexPaymentStatusInProgress];

    NSURL *url = [NSURL URLWithString:nextAction.url];
    if (url) {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success) {
                                     if (url.absoluteString.length > 0) {
                                         if (success) {
                                             [[AWXAnalyticsLogger shared] logPageViewWithName:@"payment_redirect" additionalInfo:@{@"url": url.absoluteString}];
                                         } else {
                                             [[AWXAnalyticsLogger shared] logErrorWithName:@"payment_redirect" additionalInfo:@{@"url": url.absoluteString}];
                                         }
                                     }
                                 }];
    }
}

@end
