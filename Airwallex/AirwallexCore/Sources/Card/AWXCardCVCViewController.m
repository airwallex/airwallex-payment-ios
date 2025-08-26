//
//  PaymentViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCardCVCViewController.h"
#import "AWXAPIClient.h"
#import "AWXCardValidator.h"
#import "AWXConstants.h"
#import "AWXDefaultActionProvider.h"
#import "AWXDefaultProvider.h"
#import "AWXDevice.h"
#import "AWXFloatingCvcTextField.h"
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
#import "NSObject+Logging.h"

@interface AWXCardCVCViewController ()<AWXFloatingLabelTextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *totalLabel;
@property (strong, nonatomic) AWXFloatingCvcTextField *cvcField;
@property (strong, nonatomic) AWXActionButton *confirmButton;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;
@property (nonatomic) NSInteger requiredCvcLength;

@end

@implementation AWXCardCVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle] compatibleWithTraitCollection:nil];
    if (image) {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }

    [self enableTapToEndEditing];

    self.view.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;

    _scrollView = [UIScrollView autoLayoutView];
    _scrollView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_scrollView];

    UIView *bottomLine = [UIView autoLayoutView];
    [self.view addSubview:bottomLine];

    UIView *contentView = [UIView autoLayoutView];
    [_scrollView addSubview:contentView];

    _titleLabel = [UILabel autoLayoutView];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    _titleLabel.font = [UIFont titleFont];
    [contentView addSubview:_titleLabel];

    _totalLabel = [UILabel autoLayoutView];
    _totalLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Total %@", nil, [NSBundle resourceBundle], "total amount of payment session"), [self.session.amount stringWithCurrencyCode:self.session.currency]];
    _totalLabel.textColor = [AWXTheme sharedTheme].secondaryTextColor;
    _totalLabel.font = [UIFont subhead1Font];
    [contentView addSubview:_totalLabel];

    _requiredCvcLength = [AWXCardValidator cvcLengthForBrand:[[AWXCardValidator sharedCardValidator] brandForCardName:self.paymentConsent.paymentMethod.card.brand].type];
    _cvcField = [AWXFloatingCvcTextField autoLayoutView];
    _cvcField.placeholder = NSLocalizedStringFromTableInBundle(@"CVC / CVV", nil, [NSBundle resourceBundle], @"CVC / CVV placeholder");
    _cvcField.maxLength = _requiredCvcLength;
    __weak __typeof(self) weakSelf = self;
    _cvcField.textDidChangeCallback = ^(NSString *cvc) {
        [weakSelf checkPaymentEnabled:cvc];
    };
    [contentView addSubview:_cvcField];
    [_cvcField.widthAnchor constraintEqualToAnchor:contentView.widthAnchor multiplier:0.328].active = YES;

    _confirmButton = [AWXActionButton autoLayoutView];
    _confirmButton.enabled = YES;
    [_confirmButton setTitle:NSLocalizedStringFromTableInBundle(@"Pay now", nil, [NSBundle resourceBundle], @"Pay now - pay button") forState:UIControlStateNormal];
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
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Enter CVC/CVV for\n%@", nil, [NSBundle resourceBundle], nil), [NSString stringWithFormat:@"%@ •••• %@", self.paymentConsent.paymentMethod.card.brand.capitalizedString, self.paymentConsent.paymentMethod.card.last4]];
    } else {
        if (self.paymentConsent == nil) {
            _titleLabel.text = NSLocalizedStringFromTableInBundle(@"Enter CVC/CVV", nil, [NSBundle resourceBundle], nil);
        } else {
            _titleLabel.text = self.paymentConsent.paymentMethod.type.capitalizedString;
        }
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

    _confirmButton.enabled = text.length == _requiredCvcLength;
}

- (void)payPressed:(id)sender {
    [self close:nil];
}

// override
- (void)close:(id)sender {
    [super close:sender];
    if (self.cvcCallback) {
        self.cvcCallback(_cvcField.text, sender != nil);
    }
}

@end
