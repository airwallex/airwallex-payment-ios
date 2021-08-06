//
//  PaymentViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentViewController.h"
#import "AWXDCCViewController.h"
#import "AWXConstants.h"
#import "AWXPaymentItemCell.h"
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
#import "AWXThreeDSService.h"
#import "AWXSecurityService.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentConsent.h"
#import "AWXViewController+Utils.h"

@interface AWXPaymentViewController () <UITextFieldDelegate, AWXThreeDSServiceDelegate, AWXDCCViewControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *totalLabel;
@property (strong, nonatomic) UITextField *cvcField;
@property (strong, nonatomic) AWXButton *confirmButton;

@property (strong, nonatomic) AWXThreeDSService *service;
@property (strong, nonatomic) AWXDevice *device;

@property (nullable, copy, nonatomic) NSString *initialPaymentIntentId;

@end

@implementation AWXPaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor];
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
    _totalLabel.text = [self.amount stringWithCurrencyCode:self.currency];
    _totalLabel.textAlignment = NSTextAlignmentCenter;
    _totalLabel.textColor = [UIColor textColor];
    _totalLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:40];
    [stackView addArrangedSubview:_totalLabel];
    
    UILabel *totalLabel = [UILabel new];
    totalLabel.text = NSLocalizedString(@"Total", @"Total");
    totalLabel.textAlignment = NSTextAlignmentCenter;
    totalLabel.textColor = [UIColor textColor];
    totalLabel.font = [UIFont fontWithName:AWXFontNameCircularStdMedium size:14];
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
    paymentLabel.textColor = [UIColor textColor];
    paymentLabel.font = [UIFont fontWithName:AWXFontNameCircularStdMedium size:14];
    [paymentMethodStackView addArrangedSubview:paymentLabel];
    
    UILabel *methodLabel = [UILabel new];
    methodLabel.textColor = [UIColor floatingTitleColor];
    methodLabel.font = [UIFont fontWithName:AWXFontNameCircularStdMedium size:14];
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
    _cvcField.textColor = [UIColor textColor];
    _cvcField.placeholder = NSLocalizedString(@"CVC/VCC", @"CVC/VCC");
    _cvcField.font = [UIFont fontWithName:AWXFontNameCircularStdMedium size:14];
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
    _confirmButton.titleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:14];
    [_confirmButton addTarget:self action:@selector(payPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_confirmButton setImage:[UIImage imageNamed:@"lock-white" inBundle:[NSBundle resourceBundle]] forState:UIControlStateNormal];
    [_confirmButton setImage:[UIImage imageNamed:@"lock-grey" inBundle:[NSBundle resourceBundle]] forState:UIControlStateDisabled];
    [_confirmButton setImageAndTitleHorizontalAlignmentCenter:8];
    _confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView addArrangedSubview:_confirmButton];
    [_confirmButton.leftAnchor constraintEqualToAnchor:stackView.leftAnchor constant:16].active = YES;
    [_confirmButton.rightAnchor constraintEqualToAnchor:stackView.rightAnchor constant:-16].active = YES;
    [_confirmButton.heightAnchor constraintEqualToConstant:44].active = YES;
    
    NSString *type = self.paymentMethod.type;
    if ([Airwallex.supportedNonCardTypes containsObject:self.paymentMethod.type]) {
        methodLabel.text = FormatPaymentMethodTypeString(type);
        cvcStackView.hidden = YES;
    } else {
        methodLabel.text = [NSString stringWithFormat:@"%@ •••• %@", self.paymentMethod.card.brand.capitalizedString, self.paymentMethod.card.last4];
        cvcStackView.hidden = NO;
    }
    
    if (self.paymentMethod.card.cvc) {
        _cvcField.text = self.paymentMethod.card.cvc;
    }

    [self checkPaymentEnabled];
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
    if ([Airwallex.supportedNonCardTypes containsObject:self.paymentMethod.type]) {
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
    self.paymentMethod.card.cvc = _cvcField.text;
    AWXPaymentMethod *paymentMethod = self.paymentMethod;

    [self confirmPaymentIntentWithPaymentMethod:paymentMethod];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
{
    __weak __typeof(self)weakSelf = self;
    [self startAnimating];
    [[AWXSecurityService sharedService] doProfile:self.paymentIntentId ?: self.initialPaymentIntentId completion:^(NSString * _Nonnull sessionId) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        AWXDevice *device = [AWXDevice new];
        device.deviceId = sessionId;
        if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
            [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device consent:self.paymentConsent];
        } else if ([self.session isKindOfClass:[AWXRecurringSession class]]){
            [strongSelf createPaymentConsentWithPaymentMethod:paymentMethod  createCompletion:^(AWXPaymentConsent * _Nullable consent) {
                [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod consent:consent];
            }];
        } else if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]){
            [strongSelf createPaymentConsentWithPaymentMethod:paymentMethod createCompletion:^(AWXPaymentConsent * _Nullable consent) {
                if ([paymentMethod.type isEqualToString:AWXCardKey]) {
                    [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device consent:consent];
                } else {
                    [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod consent:consent];
                }
            }];
        }
    }];
}

- (void)createPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod createCompletion:(void(^)(AWXPaymentConsent * _Nullable))completion
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.paymentMethod.customerId;
    request.paymentMethod = paymentMethod;
    request.currency = self.currency;
    request.nextTriggerByType = self.nextTriggerByType;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (response && !error) {
            AWXPaymentConsentResponse *result = response;
            completion(result.consent);
        }
    }];
}

- (void)verifyPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod consent:(AWXPaymentConsent *)consent
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXVerifyPaymentConsentRequest *request = [AWXVerifyPaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.currency = self.currency;
    request.amount = self.amount;
    request.consent = consent;
    AWXPaymentMethod * payment = paymentMethod;
    request.options = payment;
    request.returnURL =  @"airwallexcheckout://com.airwallex.paymentacceptance";
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        AWXVerifyPaymentConsentResponse *result = response;
        if ([self.session isKindOfClass:[AWXRecurringSession class]]){
            self.initialPaymentIntentId = result.initialPaymentIntentId;
        }

        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod device:(AWXDevice *)device consent:(AWXPaymentConsent *)consent
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = self.paymentIntentId ?: self.initialPaymentIntentId;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;
    request.paymentConsent = consent;
    if ([paymentMethod.type isEqualToString:AWXCardKey]) {
        AWXCardOptions *cardOptions = [AWXCardOptions new];
        cardOptions.autoCapture = YES;
        AWXThreeDs *threeDs = [AWXThreeDs new];
        threeDs.returnURL = AWXThreeDSReturnURL;
        cardOptions.threeDs = threeDs;

        AWXPaymentMethodOptions *options = [AWXPaymentMethodOptions new];
        options.cardOptions = cardOptions;
        request.options = options;
    }

    request.paymentMethod = paymentMethod;
    request.device = device;
    self.device = device;

    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)finishConfirmationWithResponse:(AWXConfirmPaymentIntentResponse *)response error:(nullable NSError *)error
{
    [self stopAnimating];
    
    if (error) {
        [self.delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusError error:error];
        return;
    }

    if ([response.status isEqualToString:@"SUCCEEDED"] || [response.status isEqualToString:@"REQUIRES_CAPTURE"]) {
        [self.delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        return;
    }

    if (!response.nextAction) {
        [self.delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        return;
    }

    if (response.nextAction.weChatPayResponse) {
        [self.delegate paymentViewController:self
                  nextActionWithWeChatPaySDK:response.nextAction.weChatPayResponse];
    } else if (response.nextAction.redirectResponse) {
        AWXThreeDSService *service = [AWXThreeDSService new];
        service.customerId = self.customerId;
        service.intentId   = self.paymentIntentId ?: self.initialPaymentIntentId;
        service.paymentMethod = self.paymentMethod;
        service.device = self.device;
        service.presentingViewController = self;
        service.delegate = self;
        self.service = service;
        
        [self startAnimating];
        [service presentThreeDSFlowWithServerJwt:response.nextAction.redirectResponse.jwt];
    } else if (response.nextAction.dccResponse) {
        [self showDcc:response];
    } else if (response.nextAction.url) {
        [self.delegate paymentViewController:self nextActionWithAlipayURL:response.nextAction.url];
    } else {
        [self.delegate paymentViewController:self
                         didFinishWithStatus:AWXPaymentStatusError
                                       error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported next action."}]];
    }
}

- (void)showDcc:(AWXConfirmPaymentIntentResponse *)response
{
    AWXDCCViewController *controller = [[AWXDCCViewController alloc] initWithNibName:nil bundle:nil];
    controller.response = response;
    controller.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
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

#pragma mark - AWXThreeDSServiceDelegate

- (void)threeDSService:(AWXThreeDSService *)service didFinishWithResponse:(AWXConfirmPaymentIntentResponse *)response error:(NSError *)error
{
    [self finishConfirmationWithResponse:response error:error];
}

#pragma mark - AWXDCCViewControllerDelegate

- (void)dccViewController:(AWXDCCViewController *)controller useDCC:(BOOL)useDCC
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];

    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = self.paymentIntentId ?: self.initialPaymentIntentId;
    request.type = AWXDCC;
    request.useDCC = useDCC;
    request.device = self.device;

    [self startAnimating];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

@end
