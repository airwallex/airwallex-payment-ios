//
//  AWX3DSActionProvider.m
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWX3DSActionProvider.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXSecurityService.h"
#import "AWXSession.h"
#import "AWXDevice.h"
#import "AWX3DSService.h"
#import "AWXRedirect3DSResponse.h"

@interface AWX3DSActionProvider () <AWX3DSServiceDelegate>

@property (nonatomic, strong) AWX3DSService *service;

@end

@implementation AWX3DSActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
    [self.delegate providerDidStartRequest:self];
    __weak __typeof(self)weakSelf = self;
    [[AWXSecurityService sharedService] doProfile:self.session.paymentIntentId completion:^(NSString * _Nullable sessionId) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        AWXDevice *device = [AWXDevice new];
        device.deviceId = sessionId;

        AWXRedirect3DSResponse *response = [AWXRedirect3DSResponse decodeFromJSON:nextAction.payload[@"data"]];
        [strongSelf handle3DSAction:response url:nextAction.url device:device];
    }];
}

- (void)handle3DSAction:(AWXRedirect3DSResponse *)response url:(NSURL *)url device:(AWXDevice *)device
{
    AWX3DSService *service = [AWX3DSService new];
    service.customerId = self.session.customerId;
    service.intentId = self.session.paymentIntentId;
    service.device = device;
    service.delegate = self;
    [service presentThreeDSFlowWithServerJwt:response.jwt url:url];
    self.service = service;
}

- (void)threeDSService:(nonnull AWX3DSService *)service shouldPresentViewController:(nonnull UIViewController *)controller
{
    [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:NO withAnimation:YES];
}

- (void)threeDSService:(nonnull AWX3DSService *)service didFinishWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response error:(nullable NSError *)error
{
    [self completeWithResponse:response error:error];
}

@end
