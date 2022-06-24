//
//  AWXRedirectActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXRedirectActionProvider.h"
#import "AWXPaymentIntentResponse.h"

@implementation AWXRedirectActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    [self.delegate provider:self shouldPresentViewController:nil forceToDismiss:YES withAnimation:YES];
    [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusInProgress error:nil];

    NSURL *url = [NSURL URLWithString:nextAction.url];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
