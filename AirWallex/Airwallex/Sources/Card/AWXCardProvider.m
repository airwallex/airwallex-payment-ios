//
//  AWXCardProvider.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/8/19.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXCardProvider.h"
#import "AWXCardViewController.h"

@implementation AWXCardProvider

- (void)handleFlow
{
    AWXCardViewController *controller = [[AWXCardViewController alloc] initWithNibName:nil bundle:nil];
    controller.sameAsShipping = YES;
    controller.session = self.viewModel.session;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.delegate provider:self shouldPresentViewController:nav forceToDismiss:NO];
}

@end
