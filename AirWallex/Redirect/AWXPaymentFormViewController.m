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

@property (strong, nonatomic) NSLayoutConstraint *promptBottomConstraint;
@property (strong, nonatomic) UIView *promptView;
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

- (void)setupViews
{
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    UIView *promptView = [UIView autoLayoutView];
    promptView.backgroundColor = [UIColor whiteColor];
    self.promptView = promptView;
    [self.view addSubview:promptView];
    
    UILabel *titleLabel = [UILabel autoLayoutView];
    titleLabel.text = self.formMapping.title;
    titleLabel.textColor = [UIColor gray100Color];
    titleLabel.font = [UIFont subhead2Font];
    [promptView addSubview:titleLabel];
    
    UIStackView *stackView = [UIStackView autoLayoutView];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 24;
    self.stackView = stackView;
    [promptView addSubview:stackView];
    
    CGFloat fieldHeight = 60.00;
    AWXFloatingLabelTextField *lastTextField = nil;

    for (AWXForm *form in self.formMapping.forms) {
        if (form.type == AWXFormTypeField) {
            AWXFloatingLabelTextField *textField = [AWXFloatingLabelTextField new];
            textField.key = form.key;
            textField.placeholder = form.placeholder;
            if (lastTextField) {
                lastTextField.nextTextField = textField;
            }
            [stackView addArrangedSubview:textField];
            [textField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;
            lastTextField = textField;
        } else if (form.type == AWXFormTypeOption) {
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
    
    NSDictionary *views = NSDictionaryOfVariableBindings(promptView, titleLabel, stackView);
    NSDictionary *metrics = @{@"bottom": @(24 + UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom)};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[promptView]|" options:0 metrics:nil views:views]];
    _promptBottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:promptView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    _promptBottomConstraint.active = YES;
    
    [promptView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-24-[titleLabel]-24-|" options:0 metrics:nil views:views]];
    [promptView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[titleLabel]-24-[stackView]-bottom-|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:metrics views:views]];
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

@end
