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
#import <SVProgressHUD/SVProgressHUD.h>

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
        [SVProgressHUD setMaxSupportedWindowLevel:2000];
        [AWXFontLoader loadFontIfNeeded];
        [[NSUserDefaults awxUserDefaults] reset];
    }
}

- (void)presentPaymentFlow
{
    NSCAssert(self.hostViewController != nil, @"hostViewController must not be nil.");

    AWXPaymentMethodListViewController *controller = [self.class paymentMethodListViewController];
    controller.delegate = nil;
    controller.paymentMethod = nil;
    controller.shipping = self.shipping;
    controller.customerId = self.paymentIntent.customerId;
    controller.isFlow = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
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
    controller.paymentMethod = nil;
    controller.shipping = self.shipping;
    controller.customerId = self.paymentIntent.customerId;
    controller.isFlow = YES;
    [navigationController pushViewController:controller animated:YES];
}

+ (AWXPaymentMethodListViewController *)paymentMethodListViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWXPaymentFlow" bundle:[NSBundle sdkBundle]];
    AWXPaymentMethodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paymentMethodList"];
    return controller;
}

+ (AWXCardViewController *)newCardViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWXPaymentFlow" bundle:[NSBundle sdkBundle]];
    AWXCardViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"newCard"];
    return controller;
}

+ (AWXPaymentViewController *)paymentDetailViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWXPaymentFlow" bundle:[NSBundle sdkBundle]];
    AWXPaymentViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paymentDetail"];
    return controller;
}

+ (AWXShippingViewController *)shippingViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWXPaymentFlow" bundle:[NSBundle sdkBundle]];
    AWXShippingViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"shipping"];
    return controller;
}

@end
