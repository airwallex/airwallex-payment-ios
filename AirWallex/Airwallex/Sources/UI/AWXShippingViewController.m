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

@interface AWXShippingViewController () <AWXCountryListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *firstNameField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *lastNameField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *stateField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *cityField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *streetField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *zipcodeField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledView *countryView;

@property (strong, nonatomic, nullable) AWXCountry *country;

@end

@implementation AWXShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.firstNameField.fieldType = AWXTextFieldTypeFirstName;
    self.firstNameField.nextTextField = self.lastNameField;
    self.lastNameField.fieldType = AWXTextFieldTypeLastName;
    self.lastNameField.nextTextField = self.phoneNumberField;
    self.phoneNumberField.fieldType = AWXTextFieldTypePhoneNumber;
    self.phoneNumberField.nextTextField = self.stateField;
    self.stateField.fieldType = AWXTextFieldTypeState;
    self.stateField.nextTextField = self.cityField;
    self.cityField.fieldType = AWXTextFieldTypeCity;
    self.cityField.nextTextField = self.streetField;
    self.streetField.fieldType = AWXTextFieldTypeStreet;
    self.streetField.nextTextField = self.zipcodeField;
    self.zipcodeField.fieldType = AWXTextFieldTypeZipcode;

    if (self.shipping) {
        self.lastNameField.text = self.shipping.lastName;
        self.firstNameField.text = self.shipping.firstName;
        self.phoneNumberField.text = self.shipping.phoneNumber;
        
        AWXAddress *address = self.shipping.address;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectCountries"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWXCountryListViewController *controller = (AWXCountryListViewController *)navigationController.topViewController;
        controller.country = self.country;
        controller.delegate = self;
    }
}

- (IBAction)savePressed:(id)sender
{
    AWXPlaceDetails *shipping = [AWXPlaceDetails new];
    shipping.lastName = self.lastNameField.text;
    shipping.firstName = self.firstNameField.text;
    shipping.phoneNumber = self.phoneNumberField.text;
    AWXAddress *address = [AWXAddress new];
    address.countryCode = self.country.countryCode;
    address.state = self.stateField.text;
    address.city = self.cityField.text;
    address.street = self.streetField.text;
    address.postcode = self.zipcodeField.text;
    shipping.address = address;
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
    [self performSegueWithIdentifier:@"selectCountries" sender:nil];
}

- (void)countryListViewController:(AWXCountryListViewController *)controller didSelectCountry:(AWXCountry *)country
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.country = country;
    self.countryView.text = country.countryName;
}

@end
