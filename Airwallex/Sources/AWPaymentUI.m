//
//  AWPaymentUI.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentUI.h"
#import "AWUtils.h"
#import "AWPaymentListViewController.h"
#import "AWEditShippingViewController.h"
#import "AWCardViewController.h"
#import "AWPaymentViewController.h"

@implementation AWPaymentUI

+ (UINavigationController *)paymentMethodListNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paymentMethodListNav"];
    return controller;
}

+ (AWPaymentListViewController *)paymentMethodListViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    AWPaymentListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paymentMethodList"];
    return controller;
}

+ (UINavigationController *)newCardNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"newCardNav"];
    return controller;
}

+ (AWCardViewController *)newCardViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    AWCardViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"newCard"];
    return controller;
}

+ (UINavigationController *)paymentDetailNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paymentDetailNav"];
    return controller;
}

+ (AWPaymentViewController *)paymentDetailViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    AWPaymentViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paymentDetail"];
    return controller;
}

+ (UINavigationController *)shippingNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"shippingNav"];
    return controller;
}

+ (AWEditShippingViewController *)shippingViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    AWEditShippingViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"shipping"];
    return controller;
}

@end
