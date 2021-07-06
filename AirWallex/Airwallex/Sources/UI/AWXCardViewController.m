//
//  AWXCardViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/1.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCardViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
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
#import "AWXDCCViewController.h"

@interface AWXCardViewController () <AWXCountryListViewControllerDelegate, AWXThreeDSServiceDelegate, AWXDCCViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet AWXCardTextField *cardNoField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *nameField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *expiresField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *cvcField;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UIView *billingView;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *firstNameField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *lastNameField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *stateField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *cityField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *streetField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *zipcodeField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *emailField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledTextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet AWXFloatLabeledView *countryView;

@property (strong, nonatomic, nullable) AWXCountry *country;
@property (strong, nonatomic, nullable) AWXPlaceDetails *billing;
@property (weak, nonatomic) IBOutlet AWXButton *confirmButton;
@property (strong, nonatomic) AWXDevice *device;
@property (strong, nonatomic) AWXThreeDSService *service;
@property (strong, nonatomic) AWXPaymentMethod *paymentMethod;

@end

@implementation AWXCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.closeBarButtonItem.image = [[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.titleLabel.text = self.customerId != nil ? @"New card" : @"Payment with card";

    self.cardNoField.fieldType = AWXTextFieldTypeCardNumber;
    self.cardNoField.nextTextField = self.nameField;
    self.nameField.fieldType = AWXTextFieldTypeNameOnCard;
    self.nameField.nextTextField = self.expiresField;
    self.expiresField.fieldType = AWXTextFieldTypeExpires;
    self.expiresField.nextTextField = self.cvcField;
    self.cvcField.fieldType = AWXTextFieldTypeCVC;
    self.switchButton.onTintColor = [AWXTheme sharedTheme].tintColor;

    self.firstNameField.fieldType = AWXTextFieldTypeFirstName;
    self.firstNameField.nextTextField = self.lastNameField;
    self.lastNameField.fieldType = AWXTextFieldTypeLastName;
    self.lastNameField.nextTextField = self.stateField;
    self.stateField.fieldType = AWXTextFieldTypeState;
    self.stateField.nextTextField = self.cityField;
    self.cityField.fieldType = AWXTextFieldTypeCity;
    self.cityField.nextTextField = self.streetField;
    self.streetField.fieldType = AWXTextFieldTypeStreet;
    self.streetField.nextTextField = self.zipcodeField;
    self.zipcodeField.fieldType = AWXTextFieldTypeZipcode;
    self.zipcodeField.nextTextField = self.emailField;
    self.emailField.fieldType = AWXTextFieldTypeEmail;
    self.emailField.nextTextField = self.phoneNumberField;
    self.phoneNumberField.fieldType = AWXTextFieldTypePhoneNumber;
    self.confirmButton.enabled = YES;

    if (!self.shipping) {
        self.sameAsShipping = NO;
    }

    self.switchButton.on = self.sameAsShipping;
    self.billingView.hidden = self.sameAsShipping;

    if (self.billing) {
        self.firstNameField.text = self.billing.firstName;
        self.lastNameField.text = self.billing.lastName;
        self.emailField.text = self.billing.email;
        self.phoneNumberField.text = self.billing.phoneNumber;

        AWXAddress *address = self.billing.address;
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

- (IBAction)switchChanged:(id)sender
{
    if (!self.shipping) {
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
    self.cvcField.nextTextField = self.sameAsShipping ? self.firstNameField : nil;
}

- (IBAction)selectCountries:(id)sender
{
    [self performSegueWithIdentifier:@"selectCountries" sender:nil];
}

- (void)finishCreation:(AWXPaymentMethod *)paymentMethod
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardViewController:didCreatePaymentMethod:)]) {
        [self.delegate cardViewController:self didCreatePaymentMethod:paymentMethod];
    }
}

- (IBAction)savePressed:(id)sender
{
    if (self.sameAsShipping) {
        self.billing = [self.shipping copy];
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
            [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:controller animated:YES completion:nil];
            return;
        }

        self.billing = billing;
    }

    AWXCard *card = [AWXCard new];
    card.name = self.nameField.text;
    card.number = [self.cardNoField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *dates = [self.expiresField.text componentsSeparatedByString:@"/"];
    card.expiryYear = dates.lastObject;
    card.expiryMonth = dates.firstObject;
    card.cvc = self.cvcField.text;
    
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXCardKey;
    paymentMethod.billing = self.billing;
    paymentMethod.card = card;
    paymentMethod.customerId = self.customerId;
    
    if (self.customerId == nil) {
        [self confirmPaymentIntentWithPaymentMethod:paymentMethod];
        return;
    } else {
        [self createPaymentMethod:paymentMethod];
    }
}

- (void)createPaymentMethod:(AWXPaymentMethod *)paymentMethod
{
    AWXCreatePaymentMethodRequest *request = [AWXCreatePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXCustomerAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
            [strongSelf presentViewController:controller animated:YES completion:nil];
            return;
        }

        AWXCreatePaymentMethodResponse *result = (AWXCreatePaymentMethodResponse *)response;
        result.paymentMethod.card.cvc = strongSelf.cvcField.text;
        [strongSelf finishCreation:result.paymentMethod];
    }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
{
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD show];
    [[AWXSecurityService sharedService] doProfile:[AWXUIContext sharedContext].paymentIntent.Id completion:^(NSString * _Nonnull sessionId) {
        [SVProgressHUD dismiss];
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        AWXDevice *device = [AWXDevice new];
        device.deviceId = sessionId;
        [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device];
    }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod device:(AWXDevice *)device
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = [AWXUIContext sharedContext].paymentIntent.Id;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;

    if ([paymentMethod.type isEqualToString:AWXCardKey]) {
        AWXCardOptions *cardOptions = [AWXCardOptions new];
        cardOptions.autoCapture = YES;
        AWXThreeDs *threeDs = [AWXThreeDs new];
        threeDs.returnURL = AWXThreeDSReturnURL;
        cardOptions.threeDs = threeDs;

        AWXPaymentMethodOptions *options = [AWXPaymentMethodOptions new];
        options.cardOptions = cardOptions;
        request.options = options;
    }

    request.paymentMethod = paymentMethod;
    self.paymentMethod = paymentMethod;
    request.device = device;
    self.device = device;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)finishConfirmationWithResponse:(AWXConfirmPaymentIntentResponse *)response error:(nullable NSError *)error
{
    id <AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    UIViewController *presentingViewController = self.presentingViewController;
    if (error) {
        [self dismissViewControllerAnimated:YES completion:^{
            [delegate paymentViewController:presentingViewController didFinishWithStatus:AWXPaymentStatusError error:error];
        }];
        return;
    }
    
    if ([response.status isEqualToString:@"SUCCEEDED"] || [response.status isEqualToString:@"REQUIRES_CAPTURE"]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [delegate paymentViewController:presentingViewController didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        }];
        return;
    }
    
    if (!response.nextAction) {
        [self dismissViewControllerAnimated:YES completion:^{
            [delegate paymentViewController:presentingViewController didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        }];
        return;
    }
    
    if (response.nextAction.weChatPayResponse) {
        [self dismissViewControllerAnimated:YES completion:^{
            [delegate paymentViewController:presentingViewController nextActionWithWeChatPaySDK:response.nextAction.weChatPayResponse];
        }];
    } else if (response.nextAction.redirectResponse) {
        AWXPaymentIntent *paymentIntent = [AWXUIContext sharedContext].paymentIntent;
        AWXThreeDSService *service = [AWXThreeDSService new];
        service.customerId = paymentIntent.customerId;
        service.intentId = paymentIntent.Id;
        service.paymentMethod = self.paymentMethod;
        service.device = self.device;
        service.presentingViewController = self;
        service.delegate = self;
        self.service = service;
        [service presentThreeDSFlowWithServerJwt:response.nextAction.redirectResponse.jwt];
    } else if (response.nextAction.dccResponse) {
        [self performSegueWithIdentifier:@"showDCC" sender:response];
    } else if (response.nextAction.url) {
        [self dismissViewControllerAnimated:YES completion:^{
            [delegate paymentViewController:presentingViewController nextActionWithAlipayURL:response.nextAction.url];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [delegate paymentViewController:presentingViewController
                        didFinishWithStatus:AWXPaymentStatusError
                                      error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported next action."}]];
        }];
    }
}

#pragma mark - AWXThreeDSServiceDelegate

- (void)threeDSService:(AWXThreeDSService *)service didFinishWithResponse:(AWXConfirmPaymentIntentResponse *)response error:(NSError *)error
{
    [self finishConfirmationWithResponse:response error:error];
}

#pragma mark - AWXDCCViewControllerDelegate

- (void)dccViewController:(AWXDCCViewController *)controller useDCC:(BOOL)useDCC
{
    [controller dismissViewControllerAnimated:YES completion:nil];

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];

    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = [AWXUIContext sharedContext].paymentIntent.Id;
    request.type = AWXDCC;
    request.useDCC = useDCC;
    request.device = self.device;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];

        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

#pragma mark - AWXCountryListViewControllerDelegate

- (void)countryListViewController:(AWXCountryListViewController *)controller didSelectCountry:(AWXCountry *)country
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.country = country;
    self.countryView.text = country.countryName;
}

@end
