//
//  AWXCardViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCardViewController.h"
#import "AWXShippingViewController.h"
#import "AWXConstants.h"
#import "AWXWidgets.h"
#import "AWXPlaceDetails.h"
#import "AWXUtils.h"
#import "AWXCard.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXAPIClient.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXCountryListViewController.h"
#import "AWXCountry.h"
#import "AWXTheme.h"
#import "AWXSecurityService.h"
#import "AWXUIContext.h"
#import "AWXPaymentIntent.h"
#import "AWXThreeDSService.h"
#import "AWXSecurityService.h"
#import "AWXDevice.h"
#import "AWXViewModel.h"
#import "AWXDCCViewController.h"

@interface AWXCardViewController () <AWXCountryListViewControllerDelegate, AWXViewModelDelegate, AWXDCCViewControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) AWXFloatingCardTextField *cardNoField;
@property (strong, nonatomic) AWXFloatingLabelTextField *nameField;
@property (strong, nonatomic) AWXFloatingLabelTextField *expiresField;
@property (strong, nonatomic) AWXFloatingLabelTextField *cvcField;
@property (strong, nonatomic) UISwitch *switchButton;
@property (strong, nonatomic) AWXFloatingLabelTextField *firstNameField;
@property (strong, nonatomic) AWXFloatingLabelTextField *lastNameField;
@property (strong, nonatomic) AWXFloatingLabelView *countryView;
@property (strong, nonatomic) AWXFloatingLabelTextField *stateField;
@property (strong, nonatomic) AWXFloatingLabelTextField *cityField;
@property (strong, nonatomic) AWXFloatingLabelTextField *streetField;
@property (strong, nonatomic) AWXFloatingLabelTextField *zipcodeField;
@property (strong, nonatomic) AWXFloatingLabelTextField *emailField;
@property (strong, nonatomic) AWXFloatingLabelTextField *phoneNumberField;
@property (strong, nonatomic) AWXButton *confirmButton;

@property (strong, nonatomic, nullable) AWXCountry *country;
@property (strong, nonatomic, nullable) AWXPlaceDetails *savedBilling;
@property (nonatomic, strong) AWXViewModel *viewModel;

@end

@implementation AWXCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewModel = [[AWXViewModel alloc] initWithSession:self.session delegate:self];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    [self enableTapToEndEditting];
    
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
    
    CGFloat fieldHeight = 60.00;
    
    _titleLabel = [UILabel new];
    _titleLabel.text = NSLocalizedString(@"Card", @"Card");
    _titleLabel.textColor = [UIColor textColor];
    _titleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:32];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView addArrangedSubview:_titleLabel];

    _cardNoField = [AWXFloatingCardTextField new];
    _cardNoField.fieldType = AWXTextFieldTypeCardNumber;
    _cardNoField.placeholder = NSLocalizedString(@"Card number", @"Card number");
    [stackView addArrangedSubview:_cardNoField];
    [_cardNoField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;
    
    _nameField = [AWXFloatingLabelTextField new];
    _nameField.fieldType = AWXTextFieldTypeNameOnCard;
    _nameField.placeholder = NSLocalizedString(@"Name on card", @"Name on card");
    _cardNoField.nextTextField = _nameField;
    [stackView addArrangedSubview:_nameField];
    [_nameField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;
    
    UIStackView *cvcStackView = [UIStackView new];
    cvcStackView.axis = UILayoutConstraintAxisHorizontal;
    cvcStackView.alignment = UIStackViewAlignmentFill;
    cvcStackView.distribution = UIStackViewDistributionFill;
    cvcStackView.spacing = 5;
    cvcStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView addArrangedSubview:cvcStackView];
    
    _expiresField = [AWXFloatingLabelTextField new];
    _expiresField.fieldType = AWXTextFieldTypeExpires;
    _expiresField.placeholder = NSLocalizedString(@"Expires MM / YYYY", @"Expires MM / YYYY");
    _nameField.nextTextField = _expiresField;
    [cvcStackView addArrangedSubview:_expiresField];
    
    _cvcField = [AWXFloatingLabelTextField new];
    _cvcField.fieldType = AWXTextFieldTypeCVC;
    _cvcField.placeholder = NSLocalizedString(@"CVC / VCC", @"CVC / VCC");
    _expiresField.nextTextField = _cvcField;
    [cvcStackView addArrangedSubview:_cvcField];
    [_expiresField.widthAnchor constraintEqualToAnchor:_cvcField.widthAnchor multiplier:1.7].active = YES;

    UILabel *billingLabel = [UILabel new];
    billingLabel.text = NSLocalizedString(@"Billing info", @"Billing info");
    billingLabel.textColor = [UIColor textColor];
    billingLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:18];
    [stackView addArrangedSubview:billingLabel];
    
    UIStackView *shippingStackView = [UIStackView new];
    shippingStackView.axis = UILayoutConstraintAxisHorizontal;
    shippingStackView.alignment = UIStackViewAlignmentFill;
    shippingStackView.distribution = UIStackViewDistributionFill;
    shippingStackView.spacing = 23;
    shippingStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView addArrangedSubview:shippingStackView];
    
    UILabel *shippingLabel = [UILabel new];
    shippingLabel.text = NSLocalizedString(@"Same as shipping address", @"Same as shipping address");
    shippingLabel.textColor = [UIColor textColor];
    shippingLabel.font = [UIFont fontWithName:AWXFontNameCircularStdMedium size:14];
    [shippingStackView addArrangedSubview:shippingLabel];
    
    _switchButton = [UISwitch new];
    _switchButton.onTintColor = [AWXTheme sharedTheme].tintColor;
    [_switchButton addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [shippingStackView addArrangedSubview:_switchButton];

    _firstNameField = [AWXFloatingLabelTextField new];
    _firstNameField.fieldType = AWXTextFieldTypeFirstName;
    _firstNameField.placeholder = NSLocalizedString(@"First name", @"First Name");
    [stackView addArrangedSubview:_firstNameField];
    [_firstNameField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;
    
    _lastNameField = [AWXFloatingLabelTextField new];
    _lastNameField.fieldType = AWXTextFieldTypeLastName;
    _lastNameField.placeholder = NSLocalizedString(@"Last name", @"Last Name");
    _firstNameField.nextTextField = _lastNameField;
    [stackView addArrangedSubview:_lastNameField];
    [_lastNameField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;
    
    _countryView = [AWXFloatingLabelView new];
    _countryView.placeholder = NSLocalizedString(@"Country / Region", @"Country / Region");
    [stackView addArrangedSubview:_countryView];
    [_countryView.heightAnchor constraintEqualToConstant:fieldHeight].active = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountries:)];
    [_countryView addGestureRecognizer:tap];

    _stateField = [AWXFloatingLabelTextField new];
    _stateField.fieldType = AWXTextFieldTypeState;
    _stateField.placeholder = NSLocalizedString(@"State", @"State");
    _phoneNumberField.nextTextField = _stateField;
    [stackView addArrangedSubview:_stateField];
    [_stateField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;

    _cityField = [AWXFloatingLabelTextField new];
    _cityField.fieldType = AWXTextFieldTypeCity;
    _cityField.placeholder = NSLocalizedString(@"City", @"City");
    _stateField.nextTextField = _cityField;
    [stackView addArrangedSubview:_cityField];
    [_cityField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;

    _streetField = [AWXFloatingLabelTextField new];
    _streetField.fieldType = AWXTextFieldTypeStreet;
    _streetField.placeholder = NSLocalizedString(@"Street", @"Street");
    _cityField.nextTextField = _streetField;
    [stackView addArrangedSubview:_streetField];
    [_streetField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;

    _zipcodeField = [AWXFloatingLabelTextField new];
    _zipcodeField.fieldType = AWXTextFieldTypeZipcode;
    _zipcodeField.placeholder = NSLocalizedString(@"Zip code (optional)", @"Zip code (optional)");
    _streetField.nextTextField = _zipcodeField;
    [stackView addArrangedSubview:_zipcodeField];
    [_zipcodeField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;

    _emailField = [AWXFloatingLabelTextField new];
    _emailField.fieldType = AWXTextFieldTypeZipcode;
    _emailField.placeholder = NSLocalizedString(@"Zip code (optional)", @"Zip code (optional)");
    _zipcodeField.nextTextField = _emailField;
    [stackView addArrangedSubview:_emailField];
    [_emailField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;
    
    _phoneNumberField = [AWXFloatingLabelTextField new];
    _phoneNumberField.fieldType = AWXTextFieldTypePhoneNumber;
    _phoneNumberField.placeholder = NSLocalizedString(@"Phone number", @"Phone number");
    _emailField.nextTextField = _phoneNumberField;
    [stackView addArrangedSubview:_phoneNumberField];
    [_phoneNumberField.heightAnchor constraintGreaterThanOrEqualToConstant:fieldHeight].active = YES;
    
    _confirmButton = [AWXButton new];
    _confirmButton.enabled = YES;
    _confirmButton.cornerRadius = 6;
    [_confirmButton setTitle:NSLocalizedString(@"Confirm", @"Confirm") forState:UIControlStateNormal];
    _confirmButton.titleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:14];
    [_confirmButton addTarget:self action:@selector(savePressed:) forControlEvents:UIControlEventTouchUpInside];
    [stackView addArrangedSubview:_confirmButton];
    [_confirmButton.heightAnchor constraintEqualToConstant:44].active = YES;
    
    if (self.session.billing) {
        self.firstNameField.text = self.session.billing.firstName;
        self.lastNameField.text = self.session.billing.lastName;
        self.emailField.text = self.session.billing.email;
        self.phoneNumberField.text = self.session.billing.phoneNumber;

        AWXAddress *address = self.session.billing.address;
        if (address) {
            AWXCountry *matchedCountry = [AWXCountry countryWithCode:address.countryCode];
            if (matchedCountry) {
                self.country = matchedCountry;
                self.countryView.text = matchedCountry.countryName;
            }
            self.stateField.text = address.state;
            self.cityField.text = address.city;
            self.streetField.text = address.street;
            self.zipcodeField.text = address.postcode;
        }
    }
    self.sameAsShipping = self.session.billing != nil;
    _switchButton.on = self.sameAsShipping;
}

- (UIScrollView *)activeScrollView
{
    return self.scrollView;
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

- (void)startAnimating
{
    [super startAnimating];
    self.confirmButton.enabled = NO;
}

- (void)stopAnimating
{
    [super stopAnimating];
    self.confirmButton.enabled = YES;
}

- (void)setSameAsShipping:(BOOL)sameAsShipping
{
    _sameAsShipping = sameAsShipping;
    _firstNameField.hidden = sameAsShipping;
    _lastNameField.hidden = sameAsShipping;
    _countryView.hidden = sameAsShipping;
    _stateField.hidden = sameAsShipping;
    _cityField.hidden = sameAsShipping;
    _streetField.hidden = sameAsShipping;
    _zipcodeField.hidden = sameAsShipping;
    _emailField.hidden = sameAsShipping;
    _phoneNumberField.hidden = sameAsShipping;
}

- (void)switchChanged:(id)sender
{
    if (!self.session.billing) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                            message:NSLocalizedString(@"No shipping address configured.", nil)
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.switchButton.on = NO;
        }]];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }

    self.sameAsShipping = self.switchButton.isOn;
}

- (void)selectCountries:(id)sender
{
    AWXCountryListViewController *controller = [[AWXCountryListViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.country = self.country;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)savePressed:(id)sender
{
    if (self.sameAsShipping) {
        self.savedBilling = [self.session.billing copy];
    } else {
        AWXPlaceDetails *billing = [AWXPlaceDetails new];
        billing.firstName = self.firstNameField.text;
        billing.lastName = self.lastNameField.text;
        billing.email = self.emailField.text;
        billing.phoneNumber = self.phoneNumberField.text;
        AWXAddress *address = [AWXAddress new];
        address.countryCode = self.country.countryCode;
        address.state = self.stateField.text;
        address.city = self.cityField.text;
        address.street = self.streetField.text;
        address.postcode = self.zipcodeField.text;
        billing.address = address;
        NSString *error = [billing validate];
        if (error) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:controller animated:YES completion:nil];
            return;
        }

        self.savedBilling = billing;
    }

    AWXCard *card = [AWXCard new];
    card.name = self.nameField.text;
    card.number = [self.cardNoField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *dates = [self.expiresField.text componentsSeparatedByString:@"/"];
    card.expiryYear = dates.lastObject;
    card.expiryMonth = dates.firstObject;
    card.cvc = self.cvcField.text;
    
    NSString *error = [card validate];
    if (error) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }
    
    [self.viewModel confirmPaymentIntentWithCard:card billing:self.savedBilling];
}

- (void)showDcc:(AWXDccResponse *)response
{
    AWXDCCViewController *controller = [[AWXDCCViewController alloc] initWithNibName:nil bundle:nil];
    controller.session = self.session;
    controller.response = response;
    controller.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - AWXCountryListViewControllerDelegate

- (void)countryListViewController:(AWXCountryListViewController *)controller didSelectCountry:(AWXCountry *)country
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.country = country;
    self.countryView.text = country.countryName;
}

#pragma mark - AWXViewModelDelegate

- (void)viewModelDidStartRequest:(AWXViewModel *)viewModel
{
    [self startAnimating];
}

- (void)viewModelDidEndRequest:(AWXViewModel *)viewModel
{
    [self stopAnimating];
}

- (void)viewModel:(AWXViewModel *)viewModel didCompleteWithError:(NSError *)error
{
    UIViewController *presentingViewController = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        id <AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
        [delegate paymentViewController:presentingViewController didFinishWithStatus:error != nil ? AWXPaymentStatusError : AWXPaymentStatusSuccess error:error];
    }];
}

- (void)viewModel:(AWXViewModel *)viewModel didInitializePaymentIntentId:(NSString *)paymentIntentId
{
    [self.session updateInitialPaymentIntentId:paymentIntentId];
}

- (void)viewModel:(AWXViewModel *)viewModel shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
    id <AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    if (nextAction.weChatPayResponse) {
        [delegate paymentViewController:self nextActionWithWeChatPaySDK:nextAction.weChatPayResponse];
    } else if (nextAction.redirectResponse) {
        [self.viewModel handleThreeDSWithJwt:nextAction.redirectResponse.jwt
                    presentingViewController:self];
    } else if (nextAction.dccResponse) {
        [self showDcc:nextAction.dccResponse];
    } else if (nextAction.url) {
        [delegate paymentViewController:self nextActionWithRedirectToURL:nextAction.url];
    } else {
        [delegate paymentViewController:self
                    didFinishWithStatus:AWXPaymentStatusError
                                  error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported next action."}]];
    }
}

#pragma mark - AWXDCCViewControllerDelegate

- (void)dccViewController:(AWXDCCViewController *)controller useDCC:(BOOL)useDCC
{
    [controller dismissViewControllerAnimated:YES completion:nil];

    [self.viewModel confirmThreeDSWithUseDCC:useDCC];
}

@end
