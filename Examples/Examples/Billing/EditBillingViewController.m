//
//  EditBillingViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/2/19.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "EditBillingViewController.h"
#import <Airwallex/Airwallex.h>
#import "Widgets.h"
#import "CountryListViewController.h"
#import "AWBilling+Utils.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface EditBillingViewController () <CountryListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UIStackView *billingView;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *firstNameField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *lastNameField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *stateField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *cityField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *streetField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *zipcodeField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *emailField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet FloatLabeledView *countryView;

@property (strong, nonatomic) Country *country;

@end

@implementation EditBillingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)savePressed:(id)sender
{
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
        [SVProgressHUD showErrorWithStatus:error];
        return;
    }

}

- (IBAction)switchChanged:(id)sender
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectCountries"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        CountryListViewController *controller = (CountryListViewController *)navigationController.topViewController;
        controller.country = sender;
        controller.delegate = self;
    }
}

- (IBAction)selectCountries:(id)sender
{
    [self performSegueWithIdentifier:@"selectCountries" sender:self.country];
}

- (void)countryListViewController:(CountryListViewController *)controller didSelectCountry:(nonnull Country *)country
{
    self.country = country;
    self.countryView.text = country.countryName;
}

@end
