//
//  AWXUIContext.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXUIContext.h"
#import "AWXCardProvider.h"
#import "AWXDefaultActionProvider.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodListViewController.h"
#import "AWXPaymentViewController.h"
#import "AWXPlaceDetails.h"
#import "AWXShippingViewController.h"
#import "AWXUtils.h"
#import "NSObject+logging.h"
#ifdef AirwallexSDK
#import "Card/Card-Swift.h"
#import "Core/Core-Swift.h"
#else
#import "Airwallex/Airwallex-Swift.h"
#endif

@interface AWXUIContext ()<AWXProviderDelegate>

@property (nonatomic, weak) UIViewController *hostVC;
@property (nonatomic, weak) AWXCardViewControllerSwift *currentVC;
@property (nonatomic) BOOL isPush;

@end

@implementation AWXUIContext

+ (instancetype)sharedContext {
    static AWXUIContext *sharedContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContext = [self new];
    });
    return sharedContext;
}

+ (void)initialize {
    if (self == [AWXUIContext class]) {
        [[NSUserDefaults awxUserDefaults] reset];
    }
}

- (void)presentPaymentFlowFrom:(UIViewController *)hostViewController {
    [self presentEntirePaymentFlowFrom:hostViewController];
}

- (void)presentEntirePaymentFlowFrom:(UIViewController *)hostViewController {
    NSCAssert(hostViewController != nil, @"hostViewController must not be nil.");
    self.hostVC = hostViewController;
    AWXPaymentMethodListViewController *controller = [[AWXPaymentMethodListViewController alloc] initWithNibName:nil bundle:nil];
    controller.viewModel = [[AWXPaymentMethodListViewModel alloc] initWithSession:_session APIClient:[[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]]];
    controller.session = self.session;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [hostViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)presentCardPaymentFlowFrom:(UIViewController *)hostViewController {
    NSCAssert(hostViewController != nil, @"hostViewController must not be nil.");
    self.hostVC = hostViewController;
    self.isPush = NO;

    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:self session:self.session];
    provider.cardSchemes = AWXCardSupportedBrands();
    [provider handleFlow];
}

- (void)pushPaymentFlowFrom:(UIViewController *)hostViewController {
    [self pushEntirePaymentFlowFrom:hostViewController];
}

- (void)pushEntirePaymentFlowFrom:(UIViewController *)hostViewController {
    NSCAssert(hostViewController != nil, @"hostViewController must not be nil.");
    UINavigationController *navigationController;
    if ([hostViewController isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)hostViewController;
    } else {
        navigationController = hostViewController.navigationController;
    }
    NSCAssert(navigationController != nil, @"The hostViewController is not a navigation controller, or is not contained in a navigation controller.");

    AWXPaymentMethodListViewController *controller = [[AWXPaymentMethodListViewController alloc] initWithNibName:nil bundle:nil];
    controller.viewModel = [[AWXPaymentMethodListViewModel alloc] initWithSession:_session APIClient:[[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]]];
    controller.session = self.session;
    [navigationController pushViewController:controller animated:YES];
}

- (void)pushCardPaymentFlowFrom:(UIViewController *)hostViewController {
    NSCAssert(hostViewController != nil, @"hostViewController must not be nil.");
    UINavigationController *navigationController;
    if ([hostViewController isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)hostViewController;
    } else {
        navigationController = hostViewController.navigationController;
    }
    NSCAssert(navigationController != nil, @"The hostViewController is not a navigation controller, or is not contained in a navigation controller.");

    self.hostVC = hostViewController;
    self.isPush = YES;

    AWXCardProvider *provider = [[AWXCardProvider alloc] initWithDelegate:self session:self.session];
    provider.cardSchemes = AWXCardSupportedBrands();
    [provider handleFlow];
}

#pragma mark - AWXProviderDelegate

- (void)providerDidStartRequest:(AWXDefaultProvider *)provider {
    [self log:@"providerDidStartRequest:"];
    [self.currentVC startAnimating];
}

- (void)providerDidEndRequest:(AWXDefaultProvider *)provider {
    [self log:@"providerDidEndRequest:"];
    [self.currentVC stopAnimating];
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    [self log:@"provider:didCompleteWithStatus:error:  %lu  %@", status, error.localizedDescription];
    id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    [delegate paymentViewController:self.currentVC didCompleteWithStatus:status error:error];
    [self log:@"Delegate: %@, paymentViewController:didCompleteWithStatus:error: %@  %lu  %@", delegate.class, self.class, status, error.localizedDescription];
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithPaymentConsentId:(NSString *)Id {
    id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    if ([delegate respondsToSelector:@selector(paymentViewController:didCompleteWithPaymentConsentId:)]) {
        [delegate paymentViewController:self.currentVC didCompleteWithPaymentConsentId:Id];
    }
}

- (void)provider:(AWXDefaultProvider *)provider didInitializePaymentIntentId:(NSString *)paymentIntentId {
    [self.session updateInitialPaymentIntentId:paymentIntentId];
    [self log:@"provider:didInitializePaymentIntentId:  %@", paymentIntentId];
}

- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    Class class = ClassToHandleNextActionForType(nextAction);
    if (class == nil) {
        [self showAlert:NSLocalizedString(@"No provider matched the next action.", nil)];
        return;
    }

    AWXDefaultActionProvider *actionProvider = [[class alloc] initWithDelegate:self.currentVC session:self.session];
    [actionProvider handleNextAction:nextAction];
    self.currentVC.provider = actionProvider;
}

- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(nullable UIViewController *)controller forceToDismiss:(BOOL)forceToDismiss withAnimation:(BOOL)withAnimation {
    AWXCardViewController *vc = (AWXCardViewController *)
        controller;
    if (vc) {
        self.currentVC = vc;
    }

    if (forceToDismiss) {
        [controller.presentedViewController dismissViewControllerAnimated:YES
                                                               completion:^{
                                                                   if (controller) {
                                                                       [self.hostVC presentViewController:controller animated:withAnimation completion:nil];
                                                                   }
                                                               }];
    } else if (controller) {
        if (self.isPush) {
            UINavigationController *navigationController;
            if ([self.hostVC isKindOfClass:[UINavigationController class]]) {
                navigationController = (UINavigationController *)self.hostVC;
            } else {
                navigationController = self.hostVC.navigationController;
            }

            [navigationController pushViewController:controller animated:withAnimation];
        } else {
            [self.hostVC presentViewController:controller animated:withAnimation completion:nil];
        }
    }
}

- (void)showAlert:(NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
    //    [self.currentVC presentViewController:controller animated:YES completion:nil];
}

@end
