//
//  AWXPaymentFormViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/17.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentFormViewController.h"

@interface AWXPaymentFormViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promptBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *promptView;

@end

@implementation AWXPaymentFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self enableTapToDismiss];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.promptView roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight radius:16];
}

- (NSLayoutConstraint *)bottomLayoutConstraint
{
    return self.promptBottomConstraint;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterKeyboard];
}

@end
