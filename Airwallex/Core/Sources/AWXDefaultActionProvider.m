//
//  AWXDefaultActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultActionProvider.h"
#import "AWXUtils.h"

@implementation AWXDefaultActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedStringFromTableInBundle(@"Unknown next action type.", nil, [NSBundle resourceBundle], nil)}]];
}

@end
