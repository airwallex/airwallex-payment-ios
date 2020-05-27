//
//  AWXViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXViewController.h"
#import "AWXLogger.h"

@interface AWXViewController ()

@end

@implementation AWXViewController

- (void)registerKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboard
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (UIView *)activeField
{
    return nil;
}

- (UIScrollView *)activeScrollView
{
    return nil;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    UIScrollView *scrollView = self.activeScrollView;
    if (scrollView) {
        NSValue *rectValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
        UIEdgeInsets contentInsets = scrollView.contentInset;
        contentInsets.bottom = CGRectGetHeight(rectValue.CGRectValue);
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = scrollView.contentInset;

        UIView *activeField = self.activeField;
        if (activeField) {
            CGRect frame = [activeField.superview convertRect:activeField.frame toView:scrollView];
            [scrollView scrollRectToVisible:frame animated:YES];
        }
    }
}

- (void)setActiveField:(UIView *)field
{
    UIScrollView *scrollView = self.activeScrollView;
    if (scrollView) {
        CGRect frame = [field.superview convertRect:field.frame toView:scrollView];
        if (CGRectGetMaxY(frame) <= CGRectGetMinY(scrollView.frame) + scrollView.contentSize.height) {
            [scrollView scrollRectToVisible:frame animated:YES];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    UIScrollView *scrollView = self.activeScrollView;
    if (scrollView) {
        UIEdgeInsets contentInsets = scrollView.contentInset;
        contentInsets.bottom = 0;
        scrollView.contentInset = UIEdgeInsetsZero;
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
    }
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)unwindToViewController:(UIStoryboardSegue *)unwindSegue
{
}

- (void)dealloc
{
    [[AWXLogger sharedLogger] logEvent:[NSString stringWithFormat:@"%@ dealloc", NSStringFromClass(self.class)]];
}

@end
