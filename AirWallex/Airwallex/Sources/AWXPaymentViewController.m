//
//  PaymentViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentViewController.h"
#import "AWXConstants.h"
#import "AWXUtils.h"
#import "AWXWidgets.h"
#import "AWXDevice.h"
#import "AWXPaymentMethod.h"
#import "AWXAPIClient.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXTheme.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentConsent.h"
#import "AWXDefaultProvider.h"
#import "AWXDefaultActionProvider.h"

@interface AWXPaymentViewController () <UITextFieldDelegate, AWXProviderDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *totalLabel;
@property (strong, nonatomic) UITextField *cvcField;
@property (strong, nonatomic) AWXButton *confirmButton;

@end

@implementation AWXPaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self enableTapToEndEditting];
    
    _scrollView = [UIScrollView new];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.spacing = 16;
    stackView.layoutMargins = UIEdgeInsetsMake(16, 0, 16, 0);
    stackView.layoutMarginsRelativeArrangement = YES;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:stackView];
    
    NSDictionary *views = @{@"scrollView": _scrollView, @"stackView": stackView};
    NSDictionary *metrics = @{@"margin": @16, @"padding": @33};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[scrollView]-|" options:0 metrics:metrics views:views]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stackView]|" options:0 metrics:metrics views:views]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stackView]|" options:0 metrics:metrics views:views]];
    [_scrollView.widthAnchor constraintEqualToAnchor:stackView.widthAnchor].active = YES;
    
    _totalLabel = [UILabel new];
    _totalLabel.text = [self.session.amount stringWithCurrencyCode:self.session.currency];
    _totalLabel.textAlignment = NSTextAlignmentCenter;
    _totalLabel.textColor = [UIColor gray50Color];
    _totalLabel.font = [UIFont subhead1Font];
    [stackView addArrangedSubview:_totalLabel];
    
    UILabel *totalLabel = [UILabel new];
    totalLabel.text = NSLocalizedString(@"Total", @"Total");
    totalLabel.textAlignment = NSTextAlignmentCenter;
    totalLabel.textColor = [UIColor gray50Color];
    totalLabel.font = [UIFont subhead1Font];
    [stackView addArrangedSubview:totalLabel];
    
    UIStackView *contentView = [UIStackView new];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.axis = UILayoutConstraintAxisVertical;
    contentView.alignment = UIStackViewAlignmentFill;
    contentView.distribution = UIStackViewDistributionEqualSpacing;
    contentView.spacing = 16;
    contentView.layoutMargins = UIEdgeInsetsMake(16, 16, 16, 16);
    contentView.layoutMarginsRelativeArrangement = YES;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView addArrangedSubview:contentView];
    [contentView.leftAnchor constraintEqualToAnchor:stackView.leftAnchor constant:0].active = YES;
    [contentView.rightAnchor constraintEqualToAnchor:stackView.rightAnchor constant:0].active = YES;
    
    UIStackView *paymentMethodStackView = [UIStackView new];
    paymentMethodStackView.axis = UILayoutConstraintAxisHorizontal;
    paymentMethodStackView.alignment = UIStackViewAlignmentFill;
    paymentMethodStackView.distribution = UIStackViewDistributionFill;
    paymentMethodStackView.spacing = 5;
    paymentMethodStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addArrangedSubview:paymentMethodStackView];
    
    UILabel *paymentLabel = [UILabel new];
    paymentLabel.text = NSLocalizedString(@"Payment", @"Payment");
    paymentLabel.textColor = [UIColor gray100Color];
    paymentLabel.font = [UIFont subhead2Font];
    [paymentMethodStackView addArrangedSubview:paymentLabel];
    
    UILabel *methodLabel = [UILabel new];
    methodLabel.textColor = [UIColor gray100Color];
    methodLabel.font = [UIFont subhead2Font];
    [paymentMethodStackView addArrangedSubview:methodLabel];
    
    UIStackView *cvcStackView = [UIStackView new];
    cvcStackView.axis = UILayoutConstraintAxisHorizontal;
    cvcStackView.alignment = UIStackViewAlignmentFill;
    cvcStackView.distribution = UIStackViewDistributionFill;
    cvcStackView.spacing = 20;
    cvcStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addArrangedSubview:cvcStackView];
    [cvcStackView.heightAnchor constraintEqualToConstant:44].active = YES;
    
    UIView *view = [UIView new];
    [cvcStackView addArrangedSubview:view];
    
    _cvcField = [UITextField new];
    _cvcField.delegate = self;
    _cvcField.textAlignment = NSTextAlignmentCenter;
    _cvcField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
    _cvcField.borderStyle = UITextBorderStyleRoundedRect;
    _cvcField.textColor = [AWXTheme sharedTheme].textColor;
    _cvcField.placeholder = NSLocalizedString(@"CVC/VCC", @"CVC/VCC");
    _cvcField.font = [UIFont subhead2Font];
    [_cvcField addTarget:self action:@selector(cvcChanged:) forControlEvents:UIControlEventEditingChanged];
    _cvcField.translatesAutoresizingMaskIntoConstraints = NO;
    [cvcStackView addArrangedSubview:_cvcField];
    [_cvcField.widthAnchor constraintEqualToConstant:92].active = YES;
    
    UIImageView *cvcImageView = [UIImageView new];
    cvcImageView.image = [UIImage imageNamed:@"cvv" inBundle:[NSBundle resourceBundle]];
    cvcImageView.contentMode = UIViewContentModeScaleAspectFit;
    cvcImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [cvcStackView addArrangedSubview:cvcImageView];
    [cvcImageView.widthAnchor constraintEqualToConstant:36].active = YES;
    [cvcImageView.heightAnchor constraintEqualToConstant:24].active = YES;
    
    _confirmButton = [AWXButton new];
    _confirmButton.enabled = YES;
    _confirmButton.cornerRadius = 6;
    [_confirmButton setTitle:NSLocalizedString(@"Pay now", @"Pay now") forState:UIControlStateNormal];
    _confirmButton.titleLabel.font = [UIFont headlineFont];
    [_confirmButton addTarget:self action:@selector(payPressed:) forControlEvents:UIControlEventTouchUpInside];
    _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView addArrangedSubview:_confirmButton];
    [_confirmButton.leftAnchor constraintEqualToAnchor:stackView.leftAnchor constant:16].active = YES;
    [_confirmButton.rightAnchor constraintEqualToAnchor:stackView.rightAnchor constant:-16].active = YES;
    [_confirmButton.heightAnchor constraintEqualToConstant:52].active = YES;
    
    if (self.paymentConsent.paymentMethod.card != nil) {
        methodLabel.text = [NSString stringWithFormat:@"%@ •••• %@", self.paymentConsent.paymentMethod.card.brand.capitalizedString, self.paymentConsent.paymentMethod.card.last4];
        cvcStackView.hidden = NO;
    } else {
        methodLabel.text = self.paymentConsent.paymentMethod.type.capitalizedString;
        cvcStackView.hidden = YES;
    }
    
    if (self.paymentConsent.paymentMethod.card.cvc) {
        _cvcField.text = self.paymentConsent.paymentMethod.card.cvc;
    }
    
    [self checkPaymentEnabled];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_cvcField becomeFirstResponder];
}

- (void)startAnimating
{
    [super startAnimating];
    _confirmButton.enabled = NO;
}

- (void)stopAnimating
{
    [super stopAnimating];
    _confirmButton.enabled = YES;
}

- (void)checkPaymentEnabled
{
    if (self.paymentConsent.paymentMethod.card == nil) {
        _confirmButton.enabled = YES;
        return;
    }
    
    _confirmButton.enabled = _cvcField.text.length > 0;
}

- (void)cvcChanged:(id)sender
{
    [self checkPaymentEnabled];
}

- (void)payPressed:(id)sender
{
    self.paymentConsent.paymentMethod.card.cvc = _cvcField.text;
    
    AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:self session:self.session];
    [provider confirmPaymentIntentWithPaymentMethod:self.paymentConsent.paymentMethod paymentConsent:self.paymentConsent device:nil];
    self.provider = provider;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length <= 4) {
        return YES;
    }
    return NO;
}

#pragma mark - AWXViewModelDelegate

- (void)providerDidStartRequest:(AWXDefaultProvider *)provider
{
    [self startAnimating];
}

- (void)providerDidEndRequest:(AWXDefaultProvider *)provider
{
    [self stopAnimating];
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error
{
    id <AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    [delegate paymentViewController:self didCompleteWithStatus:status error:error];
}

- (void)provider:(AWXDefaultProvider *)provider didInitializePaymentIntentId:(NSString *)paymentIntentId
{
    [self.session updateInitialPaymentIntentId:paymentIntentId];
}

- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
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

- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(nullable UIViewController *)controller forceToDismiss:(BOOL)forceToDismiss withAnimation:(BOOL)withAnimation
{
    if (forceToDismiss) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            if (controller) {
                [self presentViewController:controller animated:withAnimation completion:nil];
            }
        }];
    } else if (controller) {
        [self presentViewController:controller animated:withAnimation completion:nil];
    }
}

@end
