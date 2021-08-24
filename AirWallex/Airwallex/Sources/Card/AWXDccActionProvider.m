//
//  AWXDccActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXDccActionProvider.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXDccResponse.h"
#import "AWXDCCViewController.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXSession.h"
#import "AWXAPIClient.h"

@interface AWXDccActionProvider () <AWXDCCViewControllerDelegate>

@end

@implementation AWXDccActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
    AWXDccResponse *response = [AWXDccResponse decodeFromJSON:nextAction.payload[@"dcc_data"]];
    
    AWXDCCViewController *controller = [[AWXDCCViewController alloc] initWithNibName:nil bundle:nil];
    controller.session = self.session;
    controller.response = response;
    controller.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.delegate provider:self shouldPresentViewController:nav forceToDismiss:NO];
}

- (void)confirmThreeDSWithUseDCC:(BOOL)useDCC
{
    [self.delegate providerDidStartRequest:self];
    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = self.session.paymentIntentId;
    request.type = AWXDCC;
    request.useDCC = useDCC;
    request.device = self.device;
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf completeWithResponse:response error:error];
    }];
}

#pragma mark - AWXDCCViewControllerDelegate

- (void)dccViewController:(AWXDCCViewController *)controller useDCC:(BOOL)useDCC
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self confirmThreeDSWithUseDCC:useDCC];
}

@end
