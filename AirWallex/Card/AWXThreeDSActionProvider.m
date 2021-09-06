//
//  AWXThreeDSActionProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/24.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXThreeDSActionProvider.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXDevice.h"
#import "AWXSession.h"
#import "AWXRedirectThreeDSResponse.h"
#import "AWXThreeDSService.h"
#import "AWXSecurityService.h"

@interface AWXThreeDSActionProvider () <AWXThreeDSServiceDelegate>

@property (nonatomic, strong) AWXThreeDSService *service;

@end

@implementation AWXThreeDSActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
    [self.delegate providerDidStartRequest:self];
    __weak __typeof(self)weakSelf = self;
    [[AWXSecurityService sharedService] doProfile:self.session.paymentIntentId completion:^(NSString * _Nullable sessionId) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        AWXDevice *device = [AWXDevice new];
        device.deviceId = sessionId;
        
        AWXRedirectThreeDSResponse *response = [AWXRedirectThreeDSResponse decodeFromJSON:nextAction.payload[@"data"]];
        [strongSelf handleThreeDSAction:response device:device];
    }];
}

- (void)handleThreeDSAction:(AWXRedirectThreeDSResponse *)response device:(AWXDevice *)device
{
    AWXThreeDSService *service = [AWXThreeDSService new];
    service.customerId = self.session.customerId;
    service.intentId = self.session.paymentIntentId;
    service.device = device;
    service.delegate = self;
    [service presentThreeDSFlowWithServerJwt:response.jwt];
    self.service = service;
}

#pragma mark - AWXThreeDSServiceDelegate

- (void)threeDSService:(AWXThreeDSService *)service shouldPresentViewController:(UIViewController *)controller
{
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:NO];
}

- (void)threeDSService:(AWXThreeDSService *)service didFinishWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response error:(nullable NSError *)error
{
    [self completeWithResponse:response error:error];
}

@end
