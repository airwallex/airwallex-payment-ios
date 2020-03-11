//
//  AWCardViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWCardViewController.h"
#import "AWEditShippingViewController.h"
#import "AWWidgets.h"
#import "AWBilling.h"
#import "AWUtils.h"
#import "AWCard.h"
#import "AWPaymentMethod.h"
#import "AWPaymentMethodRequest.h"
#import "AWPaymentConfiguration.h"
#import "AWAPIClient.h"
#import "AWPaymentMethodResponse.h"
#import "AWCountryListViewController.h"
#import "AWCountry.h"

@interface AWCardViewController () <AWCountryListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet AWHUD *HUD;

@property (weak, nonatomic) IBOutlet AWCardTextField *cardNoField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *nameField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *expiresField;
@property (weak, nonatomic) IBOutlet AWFloatLabeledTextField *cvcField;

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

@property (strong, nonatomic) AWCountry *country;
@property (nonatomic, strong, nullable) AWBilling *billing;

@end

@implementation AWCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameField.fieldType = AWTextFieldTypeNameOnCard;
    self.cardNoField.fieldType = AWTextFieldTypeCardNumber;
    self.expiresField.fieldType = AWTextFieldTypeExpires;
    self.cvcField.fieldType = AWTextFieldTypeCVC;

    self.closeBarButtonItem.image = [[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    self.lastNameField.fieldType = AWTextFieldTypeLastName;
    self.firstNameField.fieldType = AWTextFieldTypeFirstName;
    self.emailField.fieldType = AWTextFieldTypeEmail;
    self.phoneNumberField.fieldType = AWTextFieldTypePhoneNumber;
    self.stateField.fieldType = AWTextFieldTypeState;
    self.cityField.fieldType = AWTextFieldTypeCity;
    self.streetField.fieldType = AWTextFieldTypeStreet;
    self.zipcodeField.fieldType = AWTextFieldTypeZipcode;

    if (![AWPaymentConfiguration sharedConfiguration].shipping) {
        self.sameAsShipping = NO;
    }

    self.switchButton.on = self.sameAsShipping;
    self.billingView.hidden = self.sameAsShipping;

    if (self.billing) {
        self.firstNameField.text = self.billing.firstName;
        self.lastNameField.text = self.billing.lastName;
        self.emailField.text = self.billing.email;
        self.phoneNumberField.text = self.billing.phoneNumber;

        AWAddress *address = self.billing.address;
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

- (IBAction)switchChanged:(id)sender
{
    if (![AWPaymentConfiguration sharedConfiguration].shipping) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                            message:@"No shipping address configured."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.switchButton.on = NO;
        }]];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }

    self.sameAsShipping = self.switchButton.isOn;
    self.billingView.hidden = self.switchButton.isOn;
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

- (void)finishCreation:(AWPaymentMethod *)paymentMethod
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewController:didCreatePaymentMethod:)]) {
        [self.delegate cardViewController:self didCreatePaymentMethod:paymentMethod];
    }
}

- (IBAction)savePressed:(id)sender
{
    if (self.sameAsShipping) {
        self.billing = [AWPaymentConfiguration sharedConfiguration].shipping;
    } else {
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
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:controller animated:YES completion:nil];
            return;
        }

        self.billing = billing;
    }

    AWCard *card = [AWCard new];
    card.name = self.nameField.text;
    card.number = [self.cardNoField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    card.expiryYear = [self.expiresField.text substringFromIndex:3];
    card.expiryMonth = [self.expiresField.text substringToIndex:2];
    card.cvc = self.cvcField.text;

    AWPaymentMethod *paymentMethod = [AWPaymentMethod new];
    paymentMethod.type = @"card";
    paymentMethod.card = card;
    paymentMethod.billing = self.billing;

    AWCreatePaymentMethodRequest *request = [AWCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = [AWPaymentConfiguration sharedConfiguration].customerId;
    request.paymentMethod = paymentMethod;

    [self.HUD show];
    __weak typeof(self) weakSelf = self;
    AWAPIClient *client = [AWAPIClient new];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.HUD dismiss];
        if (error) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
            [strongSelf presentViewController:controller animated:YES completion:nil];
            return;
        }

        AWCreatePaymentMethodResponse *result = (AWCreatePaymentMethodResponse *)response;
        [[AWPaymentConfiguration sharedConfiguration] cache:result.paymentMethod.Id value:card.cvc];
        
        [strongSelf finishCreation:result.paymentMethod];
    }];
}

@end
