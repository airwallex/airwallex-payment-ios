//
//  AWPaymentUI.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/9.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentUI.h"
#import "AWUtils.h"
#import "AWPaymentMethodListViewController.h"
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

+ (UINavigationController *)newCardNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"newCardNav"];
    return controller;
}

+ (UINavigationController *)paymentDetailNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paymentDetailNav"];
    return controller;
}

+ (UINavigationController *)shippingNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AWPaymentMethod" bundle:[NSBundle sdkBundle]];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"shippingNav"];
    return controller;
}

@end
