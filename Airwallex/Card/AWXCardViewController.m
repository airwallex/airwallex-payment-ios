//
//  AWXCardViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCardViewController.h"
#import "AWXAPIClient.h"
#import "AWXAnalyticsLogger.h"
#import "AWXCard.h"
#import "AWXCardProvider.h"
#import "AWXCardViewModel.h"
#import "AWXConstants.h"
#import "AWXCountry.h"
#import "AWXCountryListViewController.h"
#import "AWXDefaultActionProvider.h"
#import "AWXDefaultProvider.h"
#import "AWXDevice.h"
#import "AWXFloatingCardTextField.h"
#import "AWXFloatingCvcTextField.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXPlaceDetails.h"
#import "AWXShippingViewController.h"
#import "AWXTheme.h"
#import "AWXUIContext.h"
#import "AWXUtils.h"
#import "AWXWidgets.h"
#import "NSBundle+Card.h"
#import "NSObject+Logging.h"
#import <AirwallexRisk/AirwallexRisk-Swift.h>

@interface AWXCardViewController ()<AWXCountryListViewControllerDelegate, AWXProviderDelegate, AWXFloatingLabelTextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) AWXFloatingCardTextField *cardNoField;
@property (strong, nonatomic) AWXFloatingLabelTextField *nameField;
@property (strong, nonatomic) AWXFloatingLabelTextField *expiresField;
@property (strong, nonatomic) AWXFloatingCvcTextField *cvcField;
@property (strong, nonatomic) UISwitch *addressSwitch;
@property (strong, nonatomic) AWXFloatingLabelTextField *firstNameField;
@property (strong, nonatomic) AWXFloatingLabelTextField *lastNameField;
@property (strong, nonatomic) AWXFloatingLabelView *countryView;
@property (strong, nonatomic) AWXFloatingLabelTextField *stateField;
@property (strong, nonatomic) AWXFloatingLabelTextField *cityField;
@property (strong, nonatomic) AWXFloatingLabelTextField *streetField;
@property (strong, nonatomic) AWXFloatingLabelTextField *zipcodeField;
@property (strong, nonatomic) AWXFloatingLabelTextField *emailField;
@property (strong, nonatomic) AWXFloatingLabelTextField *phoneNumberField;
@property (strong, nonatomic) AWXActionButton *confirmButton;
@property (strong, nonatomic) UIStackView *saveCardSwitchContainer;
@property (strong, nonatomic) UIStackView *container;
@property (strong, nonatomic) AWXWarningView *warningView;

@property (nonatomic) BOOL saveCard;

@end

@implementation AWXCardViewController

typedef enum {
    AddressSwitch,
    SaveCardSwitch
} SwitchType;

- (NSString *)pageName {
    return _viewModel.pageName;
}

- (NSDictionary<NSString *, id> *)additionalInfo {
    return _viewModel.additionalInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    [self enableTapToEndEditing];

    _scrollView = [UIScrollView new];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];

    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.spacing = 16;
    stackView.layoutMargins = UIEdgeInsetsMake(16, 16, 16, 16);
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

    _titleLabel = [UILabel new];
    _titleLabel.text = NSLocalizedStringFromTableInBundle(@"Card", nil, [NSBundle cardBundle], @"Card");
    _titleLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    _titleLabel.font = [UIFont titleFont];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView addArrangedSubview:_titleLabel];

    _cardNoField = [AWXFloatingCardTextField new];
    _cardNoField.cardBrands = _viewModel.makeDisplayedCardBrands;
    __weak __typeof(self) weakSelf = self;
    _cardNoField.validationMessageCallback = ^(NSString *cardNumber) {
        return [weakSelf.viewModel validationMessageFromCardNumber:cardNumber];
    };
    _cardNoField.brandUpdateCallback = ^(AWXBrandType brand) {
        weakSelf.viewModel.currentBrand = brand;
        weakSelf.cvcField.maxLength = weakSelf.viewModel.cvcLength;
        if (weakSelf.saveCard && brand == AWXBrandTypeUnionPay) {
            [weakSelf addUnionPayWarningViewIfNecessary];
        } else {
            [weakSelf.warningView removeFromSuperview];
        }
    };
    _cardNoField.isRequired = YES;
    _cardNoField.placeholder = @"1234 1234 1234 1234";
    _cardNoField.floatingText = NSLocalizedStringFromTableInBundle(@"Card number", nil, [NSBundle cardBundle], @"Card number");
    _cardNoField.delegate = self;
    [stackView addArrangedSubview:_cardNoField];

    _nameField = [AWXFloatingLabelTextField new];
    _nameField.fieldType = AWXTextFieldTypeNameOnCard;
    _nameField.placeholder = NSLocalizedStringFromTableInBundle(@"Name on card", nil, [NSBundle cardBundle], @"Name on card");
    _cardNoField.nextTextField = _nameField;
    _nameField.isRequired = YES;
    _nameField.delegate = self;
    [stackView addArrangedSubview:_nameField];

    UIStackView *cvcStackView = [UIStackView new];
    cvcStackView.axis = UILayoutConstraintAxisHorizontal;
    cvcStackView.alignment = UIStackViewAlignmentFill;
    cvcStackView.distribution = UIStackViewDistributionFill;
    cvcStackView.spacing = 5;
    cvcStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView addArrangedSubview:cvcStackView];

    _expiresField = [AWXFloatingLabelTextField new];
    _expiresField.fieldType = AWXTextFieldTypeExpires;
    _expiresField.placeholder = NSLocalizedStringFromTableInBundle(@"Expires MM / YY", nil, [NSBundle cardBundle], @"Expires MM / YY");
    _nameField.nextTextField = _expiresField;
    _expiresField.isRequired = YES;
    _expiresField.delegate = self;
    [cvcStackView addArrangedSubview:_expiresField];

    _cvcField = [AWXFloatingCvcTextField new];
    _cvcField.validationMessageCallback = ^(NSString *cvc) {
        return [weakSelf.viewModel validationMessageFromCvc:cvc];
    };
    _cvcField.maxLength = _viewModel.cvcLength;
    _cvcField.placeholder = NSLocalizedStringFromTableInBundle(@"CVC / CVV", nil, [NSBundle cardBundle], @"CVC / CVV");
    _expiresField.nextTextField = _cvcField;
    _cvcField.isRequired = YES;
    _cvcField.delegate = self;
    [cvcStackView addArrangedSubview:_cvcField];
    [_expiresField.widthAnchor constraintEqualToAnchor:_cvcField.widthAnchor multiplier:1.7].active = YES;

    if (self.viewModel.isCardSavingEnabled) {
        self.saveCard = self.viewModel.autoSaveCardForFuturePayments;
        [stackView addArrangedSubview:[self switchOfType:SaveCardSwitch isOn:self.saveCard]];
    }

    if (self.viewModel.isBillingInformationRequired) {
        [stackView addArrangedSubview:self.billingStackView];
    }

    _confirmButton = [AWXActionButton new];
    _confirmButton.enabled = YES;
    [_confirmButton setTitle:_viewModel.ctaTitle forState:UIControlStateNormal];
    [_confirmButton addTarget:self action:@selector(confirmPayment:) forControlEvents:UIControlEventTouchUpInside];
    [stackView addArrangedSubview:_confirmButton];
    [_confirmButton.heightAnchor constraintEqualToConstant:52].active = YES;

    AWXPlaceDetails *billing = self.viewModel.initialBilling;
    if (billing) {
        [self.firstNameField setText:billing.firstName animated:NO];
        [self.lastNameField setText:billing.lastName animated:NO];
        [self.emailField setText:billing.email animated:NO];
        [self.phoneNumberField setText:billing.phoneNumber animated:NO];

        AWXAddress *address = billing.address;
        if (address) {
            [self.countryView setText:self.viewModel.selectedCountry.countryName animated:NO];
            [self.stateField setText:address.state animated:NO];
            [self.cityField setText:address.city animated:NO];
            [self.streetField setText:address.street animated:NO];
            [self.zipcodeField setText:address.postcode animated:NO];
        }
    }
    [self setBillingInputHidden:self.viewModel.isReusingShippingAsBillingInformation];
    self.container = stackView;
}

- (UIStackView *)switchOfType:(SwitchType)type isOn:(BOOL)isOn {
    UIStackView *container = [UIStackView new];
    container.axis = UILayoutConstraintAxisHorizontal;
    container.alignment = UIStackViewAlignmentFill;
    container.distribution = UIStackViewDistributionFill;
    container.spacing = 23;
    container.translatesAutoresizingMaskIntoConstraints = NO;

    UISwitch *switchButton = [UISwitch new];
    UILabel *titleLabel = [UILabel new];
    switch (type) {
    case AddressSwitch:
        titleLabel.text = NSLocalizedStringFromTableInBundle(@"Same as shipping address", nil, [NSBundle cardBundle], @"Same as shipping address");
        self.addressSwitch = switchButton;
        [switchButton addTarget:self action:@selector(addressSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        break;
    case SaveCardSwitch:
        titleLabel.text = NSLocalizedStringFromTableInBundle(@"Save this card for future payments", nil, [NSBundle cardBundle], @"Save this card for future payments");
        [switchButton addTarget:self action:@selector(saveCardSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        self.saveCardSwitchContainer = container;
        break;
    }
    titleLabel.textColor = [AWXTheme sharedTheme].secondaryTextColor;
    titleLabel.font = [UIFont subhead1Font];
    [container addArrangedSubview:titleLabel];
    [container addArrangedSubview:switchButton];
    switchButton.on = isOn;
    return container;
}

- (UIStackView *)billingStackView {
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.spacing = 16;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *billingLabel = [UILabel new];
    billingLabel.text = NSLocalizedStringFromTableInBundle(@"Billing info", nil, [NSBundle cardBundle], @"Billing info");
    billingLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    billingLabel.font = [UIFont subhead2Font];
    [stackView addArrangedSubview:billingLabel];

    [stackView addArrangedSubview:[self switchOfType:AddressSwitch isOn:self.viewModel.isReusingShippingAsBillingInformation]];

    _firstNameField = [AWXFloatingLabelTextField new];
    _firstNameField.fieldType = AWXTextFieldTypeFirstName;
    _firstNameField.placeholder = NSLocalizedStringFromTableInBundle(@"First name", nil, [NSBundle cardBundle], @"First Name");
    _firstNameField.isRequired = YES;
    [stackView addArrangedSubview:_firstNameField];

    _lastNameField = [AWXFloatingLabelTextField new];
    _lastNameField.fieldType = AWXTextFieldTypeLastName;
    _lastNameField.placeholder = NSLocalizedStringFromTableInBundle(@"Last name", nil, [NSBundle cardBundle], @"Last Name");
    _firstNameField.nextTextField = _lastNameField;
    _lastNameField.isRequired = YES;
    [stackView addArrangedSubview:_lastNameField];

    _countryView = [AWXFloatingLabelView new];
    _countryView.placeholder = NSLocalizedStringFromTableInBundle(@"Country / Region", nil, [NSBundle cardBundle], @"Country / Region");
    [stackView addArrangedSubview:_countryView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountries:)];
    [_countryView addGestureRecognizer:tap];

    _stateField = [AWXFloatingLabelTextField new];
    _stateField.fieldType = AWXTextFieldTypeState;
    _stateField.placeholder = NSLocalizedStringFromTableInBundle(@"State", nil, [NSBundle cardBundle], @"State");
    _phoneNumberField.nextTextField = _stateField;
    _stateField.isRequired = YES;
    [stackView addArrangedSubview:_stateField];

    _cityField = [AWXFloatingLabelTextField new];
    _cityField.fieldType = AWXTextFieldTypeCity;
    _cityField.placeholder = NSLocalizedStringFromTableInBundle(@"City", nil, [NSBundle cardBundle], @"City");
    _stateField.nextTextField = _cityField;
    _cityField.isRequired = YES;
    [stackView addArrangedSubview:_cityField];

    _streetField = [AWXFloatingLabelTextField new];
    _streetField.fieldType = AWXTextFieldTypeStreet;
    _streetField.placeholder = NSLocalizedStringFromTableInBundle(@"Street", nil, [NSBundle cardBundle], @"Street");
    _cityField.nextTextField = _streetField;
    _streetField.isRequired = YES;
    [stackView addArrangedSubview:_streetField];

    _zipcodeField = [AWXFloatingLabelTextField new];
    _zipcodeField.fieldType = AWXTextFieldTypeZipcode;
    _zipcodeField.placeholder = NSLocalizedStringFromTableInBundle(@"Zip code (optional)", nil, [NSBundle cardBundle], @"Zip code (optional)");
    _streetField.nextTextField = _zipcodeField;
    [stackView addArrangedSubview:_zipcodeField];

    _emailField = [AWXFloatingLabelTextField new];
    _emailField.fieldType = AWXTextFieldTypeZipcode;
    _emailField.placeholder = NSLocalizedStringFromTableInBundle(@"Email (optional)", nil, [NSBundle cardBundle], @"Email (optional)");
    _zipcodeField.nextTextField = _emailField;
    [stackView addArrangedSubview:_emailField];

    _phoneNumberField = [AWXFloatingLabelTextField new];
    _phoneNumberField.fieldType = AWXTextFieldTypePhoneNumber;
    _phoneNumberField.placeholder = NSLocalizedStringFromTableInBundle(@"Phone number (optional)", nil, [NSBundle cardBundle], @"Phone number (optional)");
    _emailField.nextTextField = _phoneNumberField;
    [stackView addArrangedSubview:_phoneNumberField];

    return stackView;
}

- (UIScrollView *)activeScrollView {
    return self.scrollView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AWXRisk logWithEvent:@"show_create_card" screen:@"page_create_card"];
    [self registerKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterKeyboard];
}

- (void)startAnimating {
    [super startAnimating];
    self.confirmButton.enabled = NO;
}

- (void)stopAnimating {
    [super stopAnimating];
    self.confirmButton.enabled = YES;
}

- (void)close:(id)sender {
    if (_viewModel.isLaunchedDirectly) {
        id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
        [delegate paymentViewController:self didCompleteWithStatus:AirwallexPaymentStatusCancel error:nil];
        [self log:@"Delegate: %@, paymentViewController:didCompleteWithStatus:error: %lu", delegate.class, AirwallexPaymentStatusCancel];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setBillingInputHidden:(BOOL)isHidden {
    self.firstNameField.hidden = isHidden;
    self.lastNameField.hidden = isHidden;
    self.countryView.hidden = isHidden;
    self.stateField.hidden = isHidden;
    self.cityField.hidden = isHidden;
    self.streetField.hidden = isHidden;
    self.zipcodeField.hidden = isHidden;
    self.emailField.hidden = isHidden;
    self.phoneNumberField.hidden = isHidden;
}

- (void)saveCardSwitchChanged:(id)sender {
    self.saveCard = [(UISwitch *)sender isOn];
    if (_saveCard && _viewModel.currentBrand == AWXBrandTypeUnionPay) {
        [self addUnionPayWarningViewIfNecessary];
    } else {
        [_warningView removeFromSuperview];
    }

    if (_saveCard) {
        [[AWXAnalyticsLogger shared] logActionWithName:@"save_card"];
    }
}

- (void)addUnionPayWarningViewIfNecessary {
    [_container.arrangedSubviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        if (subview == _saveCardSwitchContainer && _container.arrangedSubviews[idx + 1] != _warningView) {
            if (!_warningView) {
                self.warningView = [[AWXWarningView alloc] initWithMessage:@"For UnionPay, only credit cards can be saved. Click “Pay” to proceed with a one time payment or use another card if you would like to save it for future use."];
            }
            [_container insertArrangedSubview:_warningView atIndex:idx + 1];
        }
    }];
}

- (void)addressSwitchChanged:(UISwitch *)sender {
    NSString *error;
    BOOL updateSuccessful = [self.viewModel setReusesShippingAsBillingInformation:sender.isOn error:&error];
    if (updateSuccessful == NO && error != nil) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                            message:error
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Close", nil, [NSBundle cardBundle], nil)
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction *_Nonnull action) {
                                                         sender.on = !sender.isOn;
                                                     }]];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }

    [self setBillingInputHidden:self.viewModel.isReusingShippingAsBillingInformation];
    [[AWXAnalyticsLogger shared] logActionWithName:@"toggle_billing_address"];
}

- (void)selectCountries:(id)sender {
    AWXCountryListViewController *controller = [[AWXCountryListViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.country = self.viewModel.selectedCountry;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)confirmPayment:(id)sender {
    [[AWXAnalyticsLogger shared] logActionWithName:@"tap_pay_button"];
    [AWXRisk logWithEvent:@"click_payment_button" screen:@"page_create_card"];
    [self log:@"Start payment. Intent ID: %@", self.session.paymentIntentId];

    NSString *error;
    AWXCardProvider *provider = [self.viewModel preparedProviderWithDelegate:self];
    BOOL isPaymentProcessing = [self.viewModel confirmPaymentWithProvider:provider
                                                                  billing:[self makeBilling]
                                                                     card:[self makeCard]
                                                   shouldStoreCardDetails:self.saveCard
                                                                    error:&error];

    if (isPaymentProcessing) {
        self.provider = provider;
    } else {
        if (error.length > 0) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Close", nil, [NSBundle cardBundle], nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:controller animated:YES completion:nil];

            [[AWXAnalyticsLogger shared] logActionWithName:@"card_payment_validation" additionalInfo:@{@"message": error}];
            [self log:@"Payment failed. Intent ID: %@. Reason: %@.", self.session.paymentIntentId, error];
        }
    }
}

- (AWXPlaceDetails *)makeBilling {
    return [self.viewModel makeBillingWithFirstName:self.firstNameField.text
                                           lastName:self.lastNameField.text
                                              email:self.emailField.text
                                        phoneNumber:self.phoneNumberField.text
                                              state:self.stateField.text
                                               city:self.cityField.text
                                             street:self.streetField.text
                                           postcode:self.zipcodeField.text];
}

- (AWXCard *)makeCard {
    return [self.viewModel makeCardWithName:self.nameField.text
                                     number:self.cardNoField.text
                                     expiry:self.expiresField.text
                                        cvc:self.cvcField.text];
}

#pragma mark - AWXCountryListViewControllerDelegate

- (void)countryListViewController:(AWXCountryListViewController *)controller didSelectCountry:(AWXCountry *)country {
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.viewModel.selectedCountry = country;
    [self.countryView setText:country.countryName animated:NO];
}

#pragma mark - AWXProviderDelegate

- (void)providerDidStartRequest:(AWXDefaultProvider *)provider {
    [self log:@"providerDidStartRequest:"];

    [self startAnimating];
}

- (void)providerDidEndRequest:(AWXDefaultProvider *)provider {
    [self log:@"providerDidEndRequest:"];
    [self stopAnimating];
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    [self log:@"provider:didCompleteWithStatus:error: %lu  %@", status, error.description];

    id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    if (_viewModel.isLaunchedDirectly) {
        [delegate paymentViewController:self didCompleteWithStatus:status error:error];
        [self log:@"Delegate: %@, paymentViewController:didCompleteWithStatus:error: %@  %lu  %@", delegate.class, self.class, status, error.localizedDescription];
    } else {
        UIViewController *presentingViewController = self.presentingViewController;
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     [delegate paymentViewController:presentingViewController didCompleteWithStatus:status error:error];
                                     [self log:@"Delegate: %@, paymentViewController:didCompleteWithStatus:error: %@  %lu  %@", delegate.class, presentingViewController.class, status, error.localizedDescription];
                                 }];
    }
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithPaymentConsentId:(NSString *)Id {
    UIViewController *presentingViewController = self.presentingViewController;
    id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    if ([delegate respondsToSelector:@selector(paymentViewController:didCompleteWithPaymentConsentId:)]) {
        [delegate paymentViewController:presentingViewController didCompleteWithPaymentConsentId:Id];
    }
}

- (void)provider:(AWXDefaultProvider *)provider didInitializePaymentIntentId:(NSString *)paymentIntentId {
    [self log:@"provider:didInitializePaymentIntentId:  %@", paymentIntentId];
    [self.viewModel updatePaymentIntentId:paymentIntentId];
}

- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    [self log:@"provider:shouldHandleNextAction:  type:%@, stage: %@", nextAction.type, nextAction.stage];
    AWXDefaultActionProvider *actionProvider = [self.viewModel actionProviderForNextAction:nextAction withDelegate:self];
    if (actionProvider == nil) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromTableInBundle(@"No provider matched the next action.", nil, [NSBundle cardBundle], nil) preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Close", nil, [NSBundle cardBundle], nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }

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

#pragma mark - AWXFloatingLabelTextFieldDelegate

- (BOOL)floatingLabelTextField:(AWXFloatingLabelTextField *)floatingLabelTextField textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.cardNoField.textField) {
        [AWXRisk logWithEvent:@"input_card_number" screen:@"page_create_card"];
    } else if (textField == self.cvcField.textField) {
        [AWXRisk logWithEvent:@"input_card_cvc" screen:@"page_create_card"];
    } else if (textField == self.expiresField.textField) {
        [AWXRisk logWithEvent:@"input_card_expiry" screen:@"page_create_card"];
    } else if (textField == self.nameField.textField) {
        [AWXRisk logWithEvent:@"input_card_holder_name" screen:@"page_create_card"];
    }

    return YES;
}

@end
