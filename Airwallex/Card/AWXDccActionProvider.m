//
//  AWXDccActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDccActionProvider.h"
#import "AWXAPIClient.h"
#import "AWXDCCViewController.h"
#import "AWXDccResponse.h"
#import "AWXDevice.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXSession.h"
#import "NSObject+Logging.h"

@interface AWXDccActionProvider ()<AWXDCCViewControllerDelegate>

@end

@implementation AWXDccActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    AWXDccResponse *response = [AWXDccResponse decodeFromJSON:nextAction.payload];

    AWXDCCViewController *controller = [[AWXDCCViewController alloc] initWithNibName:nil bundle:nil];
    controller.session = self.session;
    controller.response = response;
    controller.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.delegate provider:self shouldPresentViewController:nav forceToDismiss:NO withAnimation:YES];
}

- (void)confirmThreeDSWithUseDCC:(BOOL)useDCC {
    [self.delegate providerDidStartRequest:self];
    [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];

    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = self.session.paymentIntentId;
    request.type = AWXDCC;
    request.useDCC = useDCC;

    request.device = [AWXDevice deviceWithRiskSessionId];

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];

    __weak __typeof(self) weakSelf = self;
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             __strong __typeof(weakSelf) strongSelf = weakSelf;
             [strongSelf completeWithResponse:(AWXConfirmPaymentIntentResponse *)response error:error];
         }];
}

#pragma mark - AWXDCCViewControllerDelegate

- (void)dccViewController:(AWXDCCViewController *)controller useDCC:(BOOL)useDCC {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self confirmThreeDSWithUseDCC:useDCC];
}

@end
