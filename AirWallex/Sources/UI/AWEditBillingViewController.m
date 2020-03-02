//
//  AWEditBillingViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/2/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWEditBillingViewController.h"
#import "AWCountryListViewController.h"
#import "AWWidgets.h"
#import "AWBilling.h"
#import "AWCountry.h"

@interface AWEditBillingViewController () <AWCountryListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UIView *billingView;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *firstNameField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *lastNameField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *stateField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *cityField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *streetField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *zipcodeField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *emailField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledView *countryView;
@property (strong, nonatomic) IBOutlet AWHUD *HUD;

@property (strong, nonatomic) AWCountry *country;

@end

@implementation AWEditBillingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.switchButton.on = self.sameAsShipping;
    self.billingView.hidden = self.sameAsShipping;
    if (self.billing) {
        self.firstNameField.text = self.billing.firstName;
        self.lastNameField.text = self.billing.lastName;
        self.emailField.text = self.billing.email;
        self.phoneNumberField.text = self.billing.phoneNumber;

        AWAddress *address = self.billing.address;
        if (address) {
            self.stateField.text = address.state;
            self.cityField.text = address.city;
            self.streetField.text = address.street;
            self.zipcodeField.text = address.postcode;
        }
    }
}

- (IBAction)savePressed:(id)sender
{
    if (self.sameAsShipping) {
        self.billing = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didEndEditingBillingViewController:)]) {
            [self.delegate didEndEditingBillingViewController:self];
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    AWBilling *billing = [AWBilling new];
    billing.firstName = self.firstNameField.text;
    billing.lastName = self.lastNameField.text;
    billing.email = self.emailField.text;
    billing.phoneNumber = self.phoneNumberField.text;
    AWAddress *address = [AWAddress new];
    address.countryCode = self.country.countryCode;
    address.state = self.stateField.text;
    address.city = self.cityField.text;
    address.street = self.streetField.text;
    address.postcode = self.zipcodeField.text;
    billing.address = address;
    NSString *error = [billing validate];
    if (error) {
        [self.HUD showErrorWithStatus:error];
        return;
    }

    self.billing = billing;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndEditingBillingViewController:)]) {
        [self.delegate didEndEditingBillingViewController:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchChanged:(id)sender
{
    self.sameAsShipping = self.switchButton.isOn;
    self.billingView.hidden = self.switchButton.isOn;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectCountries"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWCountryListViewController *controller = (AWCountryListViewController *)navigationController.topViewController;
        controller.country = sender;
        controller.delegate = self;
    }
}

- (IBAction)selectCountries:(id)sender
{
    [self performSegueWithIdentifier:@"selectCountries" sender:self.country];
}

- (void)countryListViewController:(AWCountryListViewController *)controller didSelectCountry:(nonnull AWCountry *)country
{
    self.country = country;
    self.countryView.text = country.countryName;
}

@end
