//
//  CardViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "CardViewController.h"
#import <Airwallex/Airwallex.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "Widgets.h"
#import "CountryListViewController.h"
#import "AWBilling+Utils.h"

@interface CardViewController () <CountryListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet CardTextField *cardNoField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *nameField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *expiresField;
@property (weak, nonatomic) IBOutlet FloatLabeledTextField *cvcField;
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

@implementation CardViewController

- (IBAction)closePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishCreation:(AWPaymentMethod *)paymentMethod
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewController:didCreatePaymentMethod:)]) {
        [self.delegate cardViewController:self didCreatePaymentMethod:paymentMethod];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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

    AWCard *card = [AWCard new];
    card.name = self.nameField.text;
    card.number = [self.cardNoField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    card.expYear = [self.expiresField.text substringFromIndex:3];
    card.expMonth = [self.expiresField.text substringToIndex:2];
    card.cvc = self.cvcField.text;

    AWPaymentMethod *paymentMethod = [AWPaymentMethod new];
    paymentMethod.type = @"card";
    paymentMethod.card = card;
    paymentMethod.billing = billing;

    AWCreatePaymentMethodRequest *request = [AWCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;

    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    AWAPIClient *client = [AWAPIClient new];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        AWCreatePaymentMethodResponse *result = (AWCreatePaymentMethodResponse *)response;
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf finishCreation:result.paymentMethod];
        [SVProgressHUD dismiss];
    }];
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
