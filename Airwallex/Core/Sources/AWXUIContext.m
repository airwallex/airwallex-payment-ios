//
//  AWXUIContext.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXUIContext.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentMethodListViewController.h"
#import "AWXPaymentViewController.h"
#import "AWXPlaceDetails.h"
#import "AWXShippingViewController.h"
#import "AWXUtils.h"

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
    NSCAssert(hostViewController != nil, @"hostViewController must not be nil.");

    AWXPaymentMethodListViewController *controller = [[AWXPaymentMethodListViewController alloc] initWithNibName:nil bundle:nil];
    controller.viewModel = [[AWXPaymentMethodListViewModel alloc] initWithSession:_session APIClient:[[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]]];
    controller.session = self.session;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [hostViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)pushPaymentFlowFrom:(UIViewController *)hostViewController {
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

@end
