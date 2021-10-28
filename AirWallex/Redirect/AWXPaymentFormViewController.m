//
//  AWXPaymentFormViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/17.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentFormViewController.h"
#import "AWXWidgets.h"
#import "AWXUtils.h"
#import "AWXPaymentMethod.h"
#import "AWXFormMapping.h"
#import "AWXForm.h"
#import "AWXTheme.h"

@interface AWXPaymentFormViewController ()

@property (strong, nonatomic) UIView *dimmedView;
@property (nonatomic) CGFloat maxDimmedAlpha, maximumContainerHeight, currentContainerHeight;
@property (strong, nonatomic) NSLayoutConstraint *containerViewBottomConstraint;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIStackView *stackView;

@end

@implementation AWXPaymentFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self enableTapToDismiss];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.containerView roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight radius:16];
    self.currentContainerHeight = CGRectGetHeight(self.containerView.frame);
}

- (NSLayoutConstraint *)bottomLayoutConstraint
{
    return self.containerViewBottomConstraint;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerKeyboard];
    [self animateShowDimmedView];
    [self animatePresentContainer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterKeyboard];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor clearColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:pan];
    
    self.maxDimmedAlpha = 0.6;
    self.maximumContainerHeight = UIScreen.mainScreen.bounds.size.height - UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
    self.currentContainerHeight = self.view.bounds.size.height;
    
    UIView *dimmedView = [UIView autoLayoutView];
    dimmedView.backgroundColor = [UIColor blackColor];
    dimmedView.alpha = self.maxDimmedAlpha;
    self.dimmedView = dimmedView;
    [self.view addSubview:dimmedView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [dimmedView addGestureRecognizer:tap];
    
    UIView *containerView = [UIView autoLayoutView];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.clipsToBounds = YES;
    self.containerView = containerView;
    [self.view addSubview:containerView];
    
    UILabel *titleLabel = [UILabel autoLayoutView];
    titleLabel.text = self.formMapping.title;
    titleLabel.textColor = [UIColor gray100Color];
    titleLabel.font = [UIFont subhead2Font];
    [containerView addSubview:titleLabel];
    
    UIStackView *stackView = [UIStackView autoLayoutView];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 24;
    self.stackView = stackView;
    [containerView addSubview:stackView];
    
    CGFloat fieldHeight = 60.00;
    AWXFloatingLabelTextField *lastTextField = nil;

    for (AWXForm *form in self.formMapping.forms) {
        if (form.type == AWXFormTypeText) {
            AWXFloatingLabelTextField *textField = [AWXFloatingLabelTextField new];
            textField.key = form.key;
            textField.placeholder = form.title;
            if (lastTextField) {
                lastTextField.nextTextField = textField;
            }
            textField.fieldType = form.textFieldType;
            [stackView addArrangedSubview:textField];
            [textField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;
            lastTextField = textField;
        } else if (form.type == AWXFormTypeListCell) {
            AWXOptionView *optionView = [[AWXOptionView alloc] initWithKey:form.key formLabel:form.title logoURL:form.logo];
            [optionView addTarget:self action:@selector(optionPressed:) forControlEvents:UIControlEventTouchUpInside];
            [stackView addArrangedSubview:optionView];
        } else if (form.type == AWXFormTypeButton) {
            UIButton *button = [UIButton autoLayoutView];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 6;
            button.backgroundColor = [AWXTheme sharedTheme].tintColor;
            [button setTitle:form.title forState:UIControlStateNormal];
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont headlineFont];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [stackView addArrangedSubview:button];
            self.stackView = stackView;
            [button.heightAnchor constraintEqualToConstant:40].active = YES;
        }
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(dimmedView, containerView, titleLabel, stackView);
    NSDictionary *metrics = @{@"bottom": @(24 + UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom)};

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[dimmedView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dimmedView]|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:metrics views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[containerView]|" options:0 metrics:nil views:views]];
    _containerViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:-self.currentContainerHeight];
    _containerViewBottomConstraint.active = YES;
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-24-[titleLabel]-24-|" options:0 metrics:nil views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[titleLabel]-24-[stackView]-bottom-|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:metrics views:views]];
}

- (void)optionPressed:(UIButton *)sender
{
    [self.paymentMethod appendAdditionalParams:self.options];
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentFormViewController:didUpdatePaymentMethod:)]) {
        [self.delegate paymentFormViewController:self didUpdatePaymentMethod:self.paymentMethod];
    }
}

- (void)buttonPressed:(id)sender
{
    [self.paymentMethod appendAdditionalParams:self.fields];
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentFormViewController:didConfirmPaymentMethod:)]) {
        [self.delegate paymentFormViewController:self didConfirmPaymentMethod:self.paymentMethod];
        [self animateDismissView];
    }
}

- (NSDictionary *)options
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (UIView *view in self.stackView.arrangedSubviews) {
        if ([view isKindOfClass:[AWXOptionView class]]) {
            AWXOptionView *option = (AWXOptionView *)view;
            dictionary[@"bank_name"] = option.key;
        }
    }
    return dictionary;
}

- (NSDictionary *)fields
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (UIView *view in self.stackView.arrangedSubviews) {
        if ([view isKindOfClass:[AWXFloatingLabelTextField class]]) {
            AWXFloatingLabelTextField *field = (AWXFloatingLabelTextField *)view;
            dictionary[field.key] = field.textField.text;
        }
    }
    return dictionary;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:self.view];
    NSLog(@"Pan gesture y offset: %f", translation.y);
    
    BOOL isDraggingDown = translation.y > 0;
    NSLog(@"Dragging direction: %@", isDraggingDown ? @"going down" : @"going up");
        
    switch (gesture.state) {
        case UIGestureRecognizerStateChanged:
            NSLog(@"Pan gesture: UIGestureRecognizerStateChanged %f", translation.y);

            if (translation.y >= 0) {
                self.containerViewBottomConstraint.constant = -translation.y;
                [self.view layoutIfNeeded];
            }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Pan gesture: UIGestureRecognizerStateEnded %f", translation.y);

            if (translation.y > self.currentContainerHeight / 3) {
                [self animateDismissView];
            } else {
                [self animatePresentContainer];
            }
            break;
        default:
            break;
    }
}

- (void)handleTapGesture:(UIPanGestureRecognizer *)gesture
{
    [self animateDismissView];
}

- (void)animatePresentContainer
{
    [UIView animateWithDuration:0.25 animations:^{
        self.containerViewBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)animateShowDimmedView
{
    self.dimmedView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.dimmedView.alpha = self.maxDimmedAlpha;
    }];
}

- (void)animateDismissView
{
    self.dimmedView.alpha = self.maxDimmedAlpha;
    [UIView animateWithDuration:0.25 animations:^{
        self.dimmedView.alpha = 0;
        self.containerViewBottomConstraint.constant = -self.currentContainerHeight;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
