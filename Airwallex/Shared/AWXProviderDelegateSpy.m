//
//  AWXProviderDelegateSpy.m
//  ApplePayTests
//
//  Created by Jin Wang on 29/3/2022.
//  Copyright © 2022 Airwallex. All rights reserved.
//

#import "AWXProviderDelegateSpy.h"

@implementation AWXProviderDelegateSpy

- (void)providerDidStartRequest:(AWXDefaultProvider *)provider {
    self.providerDidStartRequestCount += 1;
}

- (void)providerDidEndRequest:(AWXDefaultProvider *)provider {
    self.providerDidEndRequestCount += 1;
}

- (void)provider:(AWXDefaultProvider *)provider didInitializePaymentIntentId:(NSString *)paymentIntentId {
    // no op
}

- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    // no op
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(NSError *)error {
    self.providerDidCompleteWithStatusCount += 1;
    self.lastStatus = status;
    self.lastStatusError = error;

    if (self.statusExpectation) {
        [self.statusExpectation fulfill];
    }
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithPaymentConsentId:(NSString *)Id {
    // no op
}

- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(nullable UIViewController *)controller forceToDismiss:(BOOL)forceToDismiss withAnimation:(BOOL)withAnimation {
    // no op
}

@end
