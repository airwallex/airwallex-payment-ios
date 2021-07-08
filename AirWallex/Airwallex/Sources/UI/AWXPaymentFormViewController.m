//
//  AWXPaymentFormViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/6/17.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentFormViewController.h"
#import "AWXLabeledFormTextFieldView.h"
#import "AWXOptionView.h"
#import "AWXUtils.h"
#import "AWXPaymentMethod.h"
#import "AWXFormMapping.h"
#import "AWXForm.h"

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
    titleLabel.textColor = [UIColor titleColor];
    titleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:22];
    [promptView addSubview:titleLabel];
    
    UIStackView *stackView = [UIStackView autoLayoutView];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 24;
    self.stackView = stackView;
    [promptView addSubview:stackView];
    
    for (AWXForm *form in self.formMapping.forms) {
        if (form.type == AWXFormTypeField) {
            UITextField *textField = [UITextField new];
            AWXLabeledFormTextFieldView *fieldView = [[AWXLabeledFormTextFieldView alloc] initWithKey:form.key formLabel:form.title textField:textField];
            [stackView addArrangedSubview:fieldView];
        } else if (form.type == AWXFormTypeOption) {
            AWXOptionView *optionView = [[AWXOptionView alloc] initWithKey:form.key formLabel:form.title placeholder:form.placeholder logo:form.logo];
            [optionView addTarget:self action:@selector(optionPressed:) forControlEvents:UIControlEventTouchUpInside];
            [stackView addArrangedSubview:optionView];
        } else if (form.type == AWXFormTypeButton) {
            UIButton *button = [UIButton autoLayoutView];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 6;
            button.backgroundColor = [UIColor buttonBackgroundColor];
            [button setTitle:form.title forState:UIControlStateNormal];
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:14];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [stackView addArrangedSubview:button];
            self.stackView = stackView;
            [button.heightAnchor constraintEqualToConstant:40].active = YES;
        }
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(promptView, titleLabel, stackView);
    NSDictionary *metrics = @{@"bottom": @(24 + UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom)};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[promptView]|" options:0 metrics:nil views:views]];
    self.promptBottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:promptView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:self.promptBottomConstraint];
    
    [promptView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-24-[titleLabel]-24-|" options:0 metrics:nil views:views]];
    [promptView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[titleLabel]-24-[stackView]-bottom-|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:metrics views:views]];
}

- (void)optionPressed:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentFormViewController:didSelectOption:)]) {
        [self.delegate paymentFormViewController:self didSelectOption:self.options];
    }
}

- (void)buttonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentFormViewController:didConfirmPayment:)]) {
        [self.delegate paymentFormViewController:self didConfirmPayment:self.fields];
    }
}

- (NSDictionary *)options
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (UIView *view in self.stackView.arrangedSubviews) {
        if ([view isKindOfClass:[AWXOptionView class]]) {
            AWXOptionView *option = (AWXOptionView *)view;
            dictionary[option.key] = option.placeholder;
        }
    }
    return dictionary;
}

- (NSDictionary *)fields
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (UIView *view in self.stackView.arrangedSubviews) {
        if ([view isKindOfClass:[AWXLabeledFormTextFieldView class]]) {
            AWXLabeledFormTextFieldView *field = (AWXLabeledFormTextFieldView *)view;
            dictionary[field.key] = field.input;
        }
    }
    return dictionary;
}

@end
