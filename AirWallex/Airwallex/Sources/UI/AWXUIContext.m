//
//  AWXUIContext.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXUIContext.h"
#import "AWXFontLoader.h"
#import "AWXUtils.h"
#import "AWXPaymentMethodListViewController.h"
#import "AWXCardViewController.h"
#import "AWXPaymentViewController.h"
#import "AWXShippingViewController.h"
#import "AWXPaymentIntent.h"
#import "AWXPlaceDetails.h"

@implementation AWXUIContext

+ (instancetype)sharedContext
{
    static AWXUIContext *sharedContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContext = [self new];
    });
    return sharedContext;
}

+ (void)initialize
{
    if (self == [AWXUIContext class]) {
        [AWXFontLoader loadFontIfNeeded];
        [[NSUserDefaults awxUserDefaults] reset];
    }
}

- (void)presentPaymentFlow
{
    NSCAssert(self.hostViewController != nil, @"hostViewController must not be nil.");

    AWXPaymentMethodListViewController *controller = [self.class paymentMethodListViewController];
    controller.delegate = nil;
    controller.session = self.session;
    controller.isFlow = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.hostViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)pushPaymentFlow
{
    NSCAssert(self.hostViewController != nil, @"hostViewController must not be nil.");
    UINavigationController *navigationController;
    if ([self.hostViewController isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)self.hostViewController;
    } else {
        navigationController = self.hostViewController.navigationController;
    }
    NSCAssert(navigationController != nil, @"The hostViewController is not a navigation controller, or is not contained in a navigation controller.");

    AWXPaymentMethodListViewController *controller = [self.class paymentMethodListViewController];
    controller.delegate = nil;
    controller.session = self.session;
    controller.isFlow = YES;
    [navigationController pushViewController:controller animated:YES];
}

+ (AWXPaymentMethodListViewController *)paymentMethodListViewController
{
    AWXPaymentMethodListViewController *controller = [[AWXPaymentMethodListViewController alloc] initWithNibName:nil bundle:nil];
    return controller;
}

+ (AWXShippingViewController *)shippingViewController
{
    AWXShippingViewController *controller = [[AWXShippingViewController alloc] initWithNibName:nil bundle:nil];
    return controller;
}

@end
