//
//  AWXDefaultActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultActionProvider.h"

@implementation AWXDefaultActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
    [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown next action type.", nil)}]];
    [self.delegate provider:self shouldPresentViewController:nil forceToDismiss:YES withAnimation:YES];
}

@end
