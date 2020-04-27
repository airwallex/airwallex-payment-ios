//
//  AWShippingViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWShippingViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AWCountryListViewController.h"
#import "AWWidgets.h"
#import "AWPlaceDetails.h"
#import "AWCountry.h"

@interface AWShippingViewController () <AWCountryListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *firstNameField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *lastNameField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *stateField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *cityField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *streetField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *zipcodeField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledView *countryView;

@property (strong, nonatomic, nullable) AWCountry *country;

@end

@implementation AWShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.firstNameField.fieldType = AWTextFieldTypeFirstName;
    self.firstNameField.nextTextField = self.lastNameField;
    self.lastNameField.fieldType = AWTextFieldTypeLastName;
    self.lastNameField.nextTextField = self.phoneNumberField;
    self.phoneNumberField.fieldType = AWTextFieldTypePhoneNumber;
    self.phoneNumberField.nextTextField = self.stateField;
    self.stateField.fieldType = AWTextFieldTypeState;
    self.stateField.nextTextField = self.cityField;
    self.cityField.fieldType = AWTextFieldTypeCity;
    self.cityField.nextTextField = self.streetField;
    self.streetField.fieldType = AWTextFieldTypeStreet;
    self.streetField.nextTextField = self.zipcodeField;
    self.zipcodeField.fieldType = AWTextFieldTypeZipcode;

    if (self.shipping) {
        self.lastNameField.text = self.shipping.lastName;
        self.firstNameField.text = self.shipping.firstName;
        self.phoneNumberField.text = self.shipping.phoneNumber;
        
        AWAddress *address = self.shipping.address;
        if (address) {
            AWCountry *matchedCountry = [AWCountry countryWithCode:address.countryCode];
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
        AWCountryListViewController *controller = (AWCountryListViewController *)navigationController.topViewController;
        controller.country = self.country;
        controller.delegate = self;
    }
}

- (IBAction)savePressed:(id)sender
{
    AWPlaceDetails *shipping = [AWPlaceDetails new];
    shipping.lastName = self.lastNameField.text;
    shipping.firstName = self.firstNameField.text;
    shipping.phoneNumber = self.phoneNumberField.text;
    AWAddress *address = [AWAddress new];
    address.countryCode = self.country.countryCode;
    address.state = self.stateField.text;
    address.city = self.cityField.text;
    address.street = self.streetField.text;
    address.postcode = self.zipcodeField.text;
    shipping.address = address;
    NSString *error = [shipping validate];
    if (error) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
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

- (void)countryListViewController:(AWCountryListViewController *)controller didSelectCountry:(AWCountry *)country
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.country = country;
    self.countryView.text = country.countryName;
}

@end
