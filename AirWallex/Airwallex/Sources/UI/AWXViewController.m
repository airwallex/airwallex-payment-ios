//
//  AWXViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/2.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXViewController.h"
#import "AWXLogger.h"
#import "AWXPaymentIntent.h"

@interface AWXViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation AWXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    [self.view addSubview:self.activityIndicator];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.activityIndicator.center = self.view.center;
}

- (void)startAnimating
{
    [self.activityIndicator startAnimating];
    self.view.userInteractionEnabled = false;
}

- (void)stopAnimating
{
    [self.activityIndicator stopAnimating];
    self.view.userInteractionEnabled = true;
}

- (void)enableTapToEndEditting
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(dismissKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)dismissKeyboard
{
     [self.view endEditing:YES];
}

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

- (void)enableTapToDismiss
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (UIView *)activeField
{
    return nil;
}

- (UIScrollView *)activeScrollView
{
    return nil;
}

- (NSLayoutConstraint *)bottomLayoutConstraint
{
    return nil;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSValue *rectValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardHeight = CGRectGetHeight(rectValue.CGRectValue);
    UIScrollView *scrollView = self.activeScrollView;
    NSLayoutConstraint *bottomLayoutConstraint = self.bottomLayoutConstraint;
    if (scrollView) {
        UIEdgeInsets contentInsets = scrollView.contentInset;
        contentInsets.bottom = keyboardHeight;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
        
        UIView *activeField = self.activeField;
        if (activeField) {
            CGRect frame = [activeField.superview convertRect:activeField.frame toView:scrollView];
            [scrollView scrollRectToVisible:frame animated:YES];
        }
    } else if (bottomLayoutConstraint) {
        bottomLayoutConstraint.constant = keyboardHeight;
        [UIView animateWithDuration:0.25 animations:^{
            [self.view setNeedsUpdateConstraints];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
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
    NSLayoutConstraint *bottomLayoutConstraint = self.bottomLayoutConstraint;
    if (scrollView) {
        UIEdgeInsets contentInsets = scrollView.contentInset;
        contentInsets.bottom = 0;
        scrollView.contentInset = UIEdgeInsetsZero;
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
    } else if (bottomLayoutConstraint) {
        bottomLayoutConstraint.constant = 0;
        [UIView animateWithDuration:0.25 animations:^{
            [self.view setNeedsUpdateConstraints];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.view];
    UIView *viewTouched = [self.view hitTest:point withEvent:nil];
    if (viewTouched == self.view) {
        return YES;
    }
    return NO;
}

@end
