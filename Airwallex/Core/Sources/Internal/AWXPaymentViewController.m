//
//  PaymentViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentViewController.h"
#import "AWXAPIClient.h"
#import "AWXConstants.h"
#import "AWXDefaultActionProvider.h"
#import "AWXDefaultProvider.h"
#import "AWXDevice.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXTheme.h"
#import "AWXUtils.h"
#import "AWXWidgets.h"

@interface AWXPaymentViewController ()<AWXFloatingLabelTextFieldDelegate, AWXProviderDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *totalLabel;
@property (strong, nonatomic) AWXFloatingLabelTextField *cvcField;
@property (strong, nonatomic) AWXButton *confirmButton;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;

@end

@implementation AWXPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableTapToEndEditting];

    _scrollView = [UIScrollView autoLayoutView];
    [self.view addSubview:_scrollView];

    UIView *bottomLine = [UIView autoLayoutView];
    [self.view addSubview:bottomLine];

    UIView *contentView = [UIView autoLayoutView];
    [_scrollView addSubview:contentView];

    _titleLabel = [UILabel autoLayoutView];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [UIColor gray100Color];
    _titleLabel.font = [UIFont titleFont];
    [contentView addSubview:_titleLabel];

    _totalLabel = [UILabel autoLayoutView];
    _totalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Total %@", nil), [self.session.amount stringWithCurrencyCode:self.session.currency]];
    _totalLabel.textColor = [UIColor gray50Color];
    _totalLabel.font = [UIFont subhead1Font];
    [contentView addSubview:_totalLabel];

    _cvcField = [AWXFloatingLabelTextField autoLayoutView];
    _cvcField.delegate = self;
    _cvcField.fieldType = AWXTextFieldTypeCVC;
    _cvcField.placeholder = NSLocalizedString(@"CVC / VCC", @"CVC / VCC");
    _cvcField.isRequired = YES;
    [contentView addSubview:_cvcField];
    [_cvcField.widthAnchor constraintEqualToAnchor:contentView.widthAnchor multiplier:0.328].active = YES;

    _confirmButton = [AWXButton autoLayoutView];
    _confirmButton.enabled = YES;
    _confirmButton.cornerRadius = 6;
    [_confirmButton setTitle:NSLocalizedString(@"Pay now", @"Pay now") forState:UIControlStateNormal];
    _confirmButton.titleLabel.font = [UIFont headlineFont];
    [_confirmButton addTarget:self action:@selector(payPressed:) forControlEvents:UIControlEventTouchUpInside];
    _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_confirmButton];
    [_confirmButton.heightAnchor constraintEqualToConstant:52].active = YES;

    NSDictionary *views = @{@"scrollView": _scrollView, @"bottomLine": bottomLine, @"contentView": contentView, @"titleLabel": _titleLabel, @"totalLabel": _totalLabel, @"cvcField": _cvcField, @"confirmButton": _confirmButton};
    NSDictionary *metrics = @{@"margin": @24.0, @"padding": @16.0, @"offset": @108.0};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[scrollView][bottomLine]" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:metrics views:views]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:metrics views:views]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:metrics views:views]];
    [_scrollView.widthAnchor constraintEqualToAnchor:contentView.widthAnchor].active = YES;
    [_scrollView.heightAnchor constraintEqualToAnchor:contentView.heightAnchor].active = YES;

    _bottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomLine attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.view addConstraint:_bottomConstraint];

    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[titleLabel]-margin-|" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel][totalLabel]->=offset-[confirmButton]-margin-|" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[totalLabel]-padding-[cvcField]" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[cvcField]" options:0 metrics:metrics views:views]];

    if (self.paymentConsent.paymentMethod.card != nil) {
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Enter CVC/VCC for\n%@", nil), [NSString stringWithFormat:@"%@ •••• %@", self.paymentConsent.paymentMethod.card.brand.capitalizedString, self.paymentConsent.paymentMethod.card.last4]];
        _cvcField.hidden = NO;
    } else {
        _titleLabel.text = self.paymentConsent.paymentMethod.type.capitalizedString;
        _cvcField.hidden = YES;
    }

    if (self.paymentConsent.paymentMethod.card.cvc) {
        [_cvcField setText:self.paymentConsent.paymentMethod.card.cvc animated:NO];
    }

    [self checkPaymentEnabled:_cvcField.text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerKeyboard];
    [_cvcField.textField becomeFirstResponder];
}

- (NSLayoutConstraint *)bottomLayoutConstraint {
    return self.bottomConstraint;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterKeyboard];
}

- (void)startAnimating {
    [super startAnimating];
    _confirmButton.enabled = NO;
}

- (void)stopAnimating {
    [super stopAnimating];
    _confirmButton.enabled = YES;
}

- (void)checkPaymentEnabled:(NSString *)text {
    if (self.paymentConsent.paymentMethod.card == nil) {
        _confirmButton.enabled = YES;
        return;
    }

    _confirmButton.enabled = text.length > 0;
}

- (void)payPressed:(id)sender {
    self.paymentConsent.paymentMethod.card.cvc = _cvcField.text;

    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:self session:self.session];
    [provider confirmPaymentIntentWithPaymentMethod:self.paymentConsent.paymentMethod paymentConsent:self.paymentConsent device:nil];
    self.provider = provider;
}

#pragma mark - AWXFloatingLabelTextFieldDelegate

- (void)floatingLabelTextField:(AWXFloatingLabelTextField *)textField textDidChange:(NSString *)text {
    [self checkPaymentEnabled:text];
}

#pragma mark - AWXViewModelDelegate

- (void)providerDidStartRequest:(AWXDefaultProvider *)provider {
    [self startAnimating];
}

- (void)providerDidEndRequest:(AWXDefaultProvider *)provider {
    [self stopAnimating];
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    [delegate paymentViewController:self didCompleteWithStatus:status error:error];
}

- (void)provider:(AWXDefaultProvider *)provider didInitializePaymentIntentId:(NSString *)paymentIntentId {
    [self.session updateInitialPaymentIntentId:paymentIntentId];
}

- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    Class class = ClassToHandleNextActionForType(nextAction);
    if (class == nil) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No provider matched the next action.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }

    AWXDefaultActionProvider *actionProvider = [[class alloc] initWithDelegate:self session:self.session];
    [actionProvider handleNextAction:nextAction];
    self.provider = actionProvider;
}

- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(nullable UIViewController *)controller forceToDismiss:(BOOL)forceToDismiss withAnimation:(BOOL)withAnimation {
    if (forceToDismiss) {
        [self.presentedViewController dismissViewControllerAnimated:YES
                                                         completion:^{
                                                             if (controller) {
                                                                 [self presentViewController:controller animated:withAnimation completion:nil];
                                                             }
                                                         }];
    } else if (controller) {
        [self presentViewController:controller animated:withAnimation completion:nil];
    }
}

- (void)provider:(AWXDefaultProvider *)provider shouldInsertViewController:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = CGRectInset(self.view.frame, 0, CGRectGetMaxY(self.view.bounds));
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

@end
