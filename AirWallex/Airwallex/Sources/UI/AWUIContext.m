//
//  AWUIContext.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWUIContext.h"
#import "AWFontLoader.h"
#import "AWUtils.h"
#import "AWPaymentMethodListViewController.h"
#import "AWCardViewController.h"
#import "AWPaymentViewController.h"
#import "AWShippingViewController.h"
#import "AWPaymentIntent.h"
#import "AWPlaceDetails.h"

@implementation AWUIContext

+ (instancetype)sharedContext
{
    static AWUIContext *sharedContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContext = [self new];
    });
    return sharedContext;
}

+ (void)initialize
{
    if (self == [AWUIContext class]) {
        [AWFontLoader loadFontIfNeeded];
        [[NSUserDefaults awUserDefaults] reset];
    }
}

- (void)presentPaymentFlow
{
    NSCAssert(self.hostViewController != nil, @"hostViewController must not be nil.");

    AWPaymentMethodListViewController *controller = [self.class paymentMethodListViewController];
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

    AWPaymentMethodListViewController *controller = [self.class paymentMethodListViewController];
    controller.delegate = nil;
    controller.paymentMethod = nil;
    controller.shipping = self.shipping;
    controller.customerId = self.paymentIntent.customerId;
    controller.isFlow = YES;
    [navigationController pushViewController:controller animated:YES];
}

+ (AWPaymentMethodListViewController *)paymentMethodListViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentFlow" bundle:[NSBundle sdkBundle]];
    AWPaymentMethodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paymentMethodList"];
    return controller;
}

+ (AWCardViewController *)newCardViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentFlow" bundle:[NSBundle sdkBundle]];
    AWCardViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"newCard"];
    return controller;
}

+ (AWPaymentViewController *)paymentDetailViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentFlow" bundle:[NSBundle sdkBundle]];
    AWPaymentViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paymentDetail"];
    return controller;
}

+ (AWShippingViewController *)shippingViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentFlow" bundle:[NSBundle sdkBundle]];
    AWShippingViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"shipping"];
    return controller;
}

@end
