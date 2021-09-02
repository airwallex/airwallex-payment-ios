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

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
    NSURL *url = [NSURL URLWithString:nextAction.payload[@"url"]];
    [self.delegate provider:self shouldPresentViewController:nil forceToDismiss:YES];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
