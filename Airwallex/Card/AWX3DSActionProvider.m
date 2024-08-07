//
//  AWX3DSActionProvider.m
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWX3DSActionProvider.h"
#import "AWX3DSService.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXSecurityService.h"
#import "AWXSession.h"
#import "NSObject+Logging.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWX3DSActionProvider ()<AWX3DSServiceDelegate>

@property (nonatomic, strong) AWX3DSService *service;

@end

@implementation AWX3DSActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    [self.delegate providerDidStartRequest:self];
    [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];
    __weak __typeof(self) weakSelf = self;
    [[AWXSecurityService sharedService] doProfile:self.session.paymentIntentId
                                       completion:^(NSString *_Nullable sessionId) {
                                           __strong __typeof(weakSelf) strongSelf = weakSelf;

                                           AWXDevice *device = [[AWXDevice alloc] initWithDeviceId:sessionId];

                                           AWX3DSService *service = [AWX3DSService new];
                                           service.customerId = strongSelf.session.customerId;
                                           service.intentId = strongSelf.session.paymentIntentId;
                                           service.device = device;
                                           service.delegate = strongSelf;
                                           [service present3DSFlowWithNextAction:nextAction];
                                           strongSelf.service = service;
                                       }];
}

- (void)threeDSService:(nonnull AWX3DSService *)service shouldPresentViewController:(nonnull UIViewController *)controller {
    if ([self.delegate respondsToSelector:@selector(hostViewController)]) {
        [[self.delegate hostViewController] presentViewController:controller animated:YES completion:nil];
    } else {
        if ([self.delegate respondsToSelector:@selector(provider:shouldPresentViewController:forceToDismiss:withAnimation:)]) {
            [self.delegate provider:self shouldPresentViewController:controller forceToDismiss:NO withAnimation:YES];
        }
    }
}

- (void)threeDSService:(AWX3DSService *)service shouldInsertViewController:(UIViewController *)controller {
    if ([self.delegate respondsToSelector:@selector(hostViewController)]) {
        UIViewController *hostViewController = [self.delegate hostViewController];
        [hostViewController addChildViewController:controller];
        controller.view.frame = CGRectInset(hostViewController.view.frame, 0, CGRectGetMaxY(hostViewController.view.bounds));
        [hostViewController.view addSubview:controller.view];
        [controller didMoveToParentViewController:hostViewController];
    } else {
        if ([self.delegate respondsToSelector:@selector(provider:shouldInsertViewController:)]) {
            [self.delegate provider:self shouldInsertViewController:controller];
        }
    }
}

- (void)threeDSService:(nonnull AWX3DSService *)service didFinishWithResponse:(nullable AWXConfirmPaymentIntentResponse *)response error:(nullable NSError *)error {
    [self completeWithResponse:response error:error];
}

@end
