//
//  EditShippingViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "EditShippingViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AWBilling+Utils.h"
#import "Widgets.h"
#import "CountryListViewController.h"

@interface EditShippingViewController () <CountryListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *lastNameField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *firstNameField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *emailField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *stateField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *cityField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *streetField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *zipcodeField;
@property (weak, nonatomic) IBOutlet FloatLabeledView *countryView;

@property (strong, nonatomic) Country *country;

@end

@implementation EditShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.billing) {
        self.lastNameField.text = self.billing.lastName;
        self.firstNameField.text = self.billing.firstName;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectCountries"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        CountryListViewController *controller = (CountryListViewController *)navigationController.topViewController;
        controller.country = sender;
        controller.delegate = self;
    }
}

- (IBAction)unwindToViewController:(UIStoryboardSegue *)unwindSegue
{
}

- (IBAction)savePressed:(id)sender
{
    AWBilling *billing = [AWBilling new];
    billing.lastName = self.lastNameField.text;
    billing.firstName = self.firstNameField.text;
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

    self.billing = billing;
    if (self.delegate && [self.delegate respondsToSelector:@selector(editShippingViewController:didSelectBilling:)]) {
        [self.delegate editShippingViewController:self didSelectBilling:billing];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
