//
//  AWX3DSActionProvider.m
//  Card
//
//  Created by Victor Zhu on 2021/12/2.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWX3DSActionProvider.h"
#import "AWX3DSService.h"
#import "AWXDevice.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXSession.h"
#import "NSObject+logging.h"

@interface AWX3DSActionProvider ()<AWX3DSServiceDelegate>

@property (nonatomic, strong) AWX3DSService *service;

@end

@implementation AWX3DSActionProvider

- (void)handleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    [self.delegate providerDidStartRequest:self];
    [self log:@"Delegate: %@, providerDidStartRequest:", self.delegate.class];

    AWX3DSService *service = [AWX3DSService new];
    service.customerId = self.session.customerId;
    service.intentId = self.session.paymentIntentId;
    service.device = [AWXDevice deviceWithRiskSessionId];
    service.delegate = self;
    [service present3DSFlowWithNextAction:nextAction];
    self.service = service;
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
