//
//  AWXShippingViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXShippingViewController.h"
#import "AWXCountryListViewController.h"
#import "AWXWidgets.h"
#import "AWXPlaceDetails.h"
#import "AWXCountry.h"
#import "AWXConstants.h"
#import "AWXUtils.h"
#import "AWXTheme.h"

@interface AWXShippingViewController () <AWXCountryListViewControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) AWXFloatingLabelTextField *firstNameField;
@property (strong, nonatomic) AWXFloatingLabelTextField *lastNameField;
@property (strong, nonatomic) AWXFloatingLabelView *countryView;
@property (strong, nonatomic) AWXFloatingLabelTextField *stateField;
@property (strong, nonatomic) AWXFloatingLabelTextField *cityField;
@property (strong, nonatomic) AWXFloatingLabelTextField *streetField;
@property (strong, nonatomic) AWXFloatingLabelTextField *zipcodeField;
@property (strong, nonatomic) AWXFloatingLabelTextField *emailField;
@property (strong, nonatomic) AWXFloatingLabelTextField *phoneNumberField;

@property (strong, nonatomic, nullable) AWXCountry *country;

@end

@implementation AWXShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(savePressed:)];
    [self enableTapToEndEditting];
    
    _scrollView = [UIScrollView new];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];
    
    UIView *contentView = [UIView new];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:contentView];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = NSLocalizedString(@"Shipping", @"Shipping");
    titleLabel.textColor = [UIColor gray100Color];
    titleLabel.font = [UIFont titleFont];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:titleLabel];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 16;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:stackView];
    
    NSDictionary *views = @{@"scrollView": _scrollView, @"contentView": contentView, @"titleLabel": titleLabel, @"stackView": stackView};
    NSDictionary *metrics = @{@"margin": @16, @"padding": @33};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[scrollView]-|" options:0 metrics:metrics views:views]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:metrics views:views]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:metrics views:views]];
    [contentView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[titleLabel]-margin-|" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[titleLabel]-padding-[stackView]-margin-|" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:metrics views:views]];
        
    _firstNameField = [AWXFloatingLabelTextField new];
    _firstNameField.fieldType = AWXTextFieldTypeFirstName;
    _firstNameField.placeholder = NSLocalizedString(@"First name", @"First Name");
    _firstNameField.isRequired = YES;
    [stackView addArrangedSubview:_firstNameField];
    
    _lastNameField = [AWXFloatingLabelTextField new];
    _lastNameField.fieldType = AWXTextFieldTypeLastName;
    _lastNameField.placeholder = NSLocalizedString(@"Last name", @"Last Name");
    _firstNameField.nextTextField = _lastNameField;
    _lastNameField.isRequired = YES;
    [stackView addArrangedSubview:_lastNameField];
    
    _countryView = [AWXFloatingLabelView new];
    _countryView.placeholder = NSLocalizedString(@"Country / Region", @"Country / Region");
    [stackView addArrangedSubview:_countryView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountries:)];
    [_countryView addGestureRecognizer:tap];
    
    _stateField = [AWXFloatingLabelTextField new];
    _stateField.fieldType = AWXTextFieldTypeState;
    _stateField.placeholder = NSLocalizedString(@"State", @"State");
    _lastNameField.nextTextField = _stateField;
    _stateField.isRequired = YES;
    [stackView addArrangedSubview:_stateField];
    
    _cityField = [AWXFloatingLabelTextField new];
    _cityField.fieldType = AWXTextFieldTypeCity;
    _cityField.placeholder = NSLocalizedString(@"City", @"City");
    _stateField.nextTextField = _cityField;
    _cityField.isRequired = YES;
    [stackView addArrangedSubview:_cityField];
    
    _streetField = [AWXFloatingLabelTextField new];
    _streetField.fieldType = AWXTextFieldTypeStreet;
    _streetField.placeholder = NSLocalizedString(@"Street", @"Street");
    _cityField.nextTextField = _streetField;
    _streetField.isRequired = YES;
    [stackView addArrangedSubview:_streetField];
    
    _zipcodeField = [AWXFloatingLabelTextField new];
    _zipcodeField.fieldType = AWXTextFieldTypeZipcode;
    _zipcodeField.placeholder = NSLocalizedString(@"Zip code (optional)", @"Zip code (optional)");
    _streetField.nextTextField = _zipcodeField;
    [stackView addArrangedSubview:_zipcodeField];
    
    _emailField = [AWXFloatingLabelTextField new];
    _emailField.fieldType = AWXTextFieldTypeEmail;
    _emailField.placeholder = NSLocalizedString(@"Email (optional)", @"Email (optional)");
    _zipcodeField.nextTextField = _emailField;
    [stackView addArrangedSubview:_emailField];
    
    _phoneNumberField = [AWXFloatingLabelTextField new];
    _phoneNumberField.fieldType = AWXTextFieldTypePhoneNumber;
    _phoneNumberField.placeholder = NSLocalizedString(@"Phone number (optional)", @"Phone number (optional)");
    _emailField.nextTextField = _phoneNumberField;
    [stackView addArrangedSubview:_phoneNumberField];
    
    if (self.shipping) {
        _firstNameField.text = self.shipping.firstName;
        _lastNameField.text = self.shipping.lastName;
        _emailField.text = self.shipping.email;
        _phoneNumberField.text = self.shipping.phoneNumber;
        
        AWXAddress *address = self.shipping.address;
        if (address) {
            AWXCountry *matchedCountry = [AWXCountry countryWithCode:address.countryCode];
            if (matchedCountry) {
                self.country = matchedCountry;
                self.countryView.text = matchedCountry.countryName;
            }
            _stateField.text = address.state;
            _cityField.text = address.city;
            _streetField.text = address.street;
            _zipcodeField.text = address.postcode;
        }
    }
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

- (IBAction)savePressed:(id)sender
{
    AWXPlaceDetails *shipping = [AWXPlaceDetails new];
    shipping.lastName = self.lastNameField.text;
    shipping.firstName = self.firstNameField.text;
    AWXAddress *address = [AWXAddress new];
    address.countryCode = self.country.countryCode;
    address.state = self.stateField.text;
    address.city = self.cityField.text;
    address.street = self.streetField.text;
    address.postcode = self.zipcodeField.text;
    shipping.address = address;
    shipping.email = self.emailField.text;
    shipping.phoneNumber = self.phoneNumberField.text;
    NSString *error = [shipping validate];
    if (error) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }
    
    self.shipping = shipping;
    if (self.delegate && [self.delegate respondsToSelector:@selector(shippingViewController:didEditShipping:)]) {
        [self.delegate shippingViewController:self didEditShipping:shipping];
    }
}

- (IBAction)selectCountries:(id)sender
{
    AWXCountryListViewController *controller = [[AWXCountryListViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.country = self.country;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)countryListViewController:(AWXCountryListViewController *)controller didSelectCountry:(AWXCountry *)country
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.country = country;
    self.countryView.text = country.countryName;
}

@end
