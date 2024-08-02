//
//  AWXDefaultActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDefaultActionProvider.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation AWXDefaultActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    [self.delegate provider:self didCompleteWithStatus:AirwallexPaymentStatusFailure error:[NSError errorForAirwallexSDKWith:-1 localizedDescription:NSLocalizedString(@"Unknown next action type.", nil)]];
}

@end
