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
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXSecurityService.h"
#import "AWXSession.h"
#import "NSObject+Logging.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

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
    __weak __typeof(self) weakSelf = self;
    [self.delegate providerDidStartRequest:self];
    [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];

    [[AWXSecurityService sharedService] doProfile:self.session.paymentIntentId
                                       completion:^(NSString *_Nullable sessionId) {
                                           __strong __typeof(weakSelf) strongSelf = weakSelf;

                                           AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
                                           request.requestId = NSUUID.UUID.UUIDString;
                                           request.intentId = strongSelf.session.paymentIntentId;
                                           request.type = AWXDCC;
                                           request.useDCC = useDCC;

                                           AWXDevice *device = [AWXDevice new];
                                           device.deviceId = sessionId;
                                           request.device = device;

                                           AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
                                           __weak __typeof(self) weakSelf = self;
                                           [client send:request
                                                handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
                                                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                    [strongSelf completeWithResponse:(AWXConfirmPaymentIntentResponse *)response error:error];
                                                }];
                                       }];
}

#pragma mark - AWXDCCViewControllerDelegate

- (void)dccViewController:(AWXDCCViewController *)controller useDCC:(BOOL)useDCC {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self confirmThreeDSWithUseDCC:useDCC];
}

@end
