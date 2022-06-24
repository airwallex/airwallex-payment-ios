//
//  UIViewController+Utils.m
//  Examples
//
//  Created by Victor Zhu on 2021/7/7.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "UIViewController+Utils.h"

@implementation UIViewController (Utils)

- (void)showAlert:(NSString *)message withTitle:(nullable NSString *)title {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
