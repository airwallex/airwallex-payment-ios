//
//  PaymentViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentViewController.h"
#import "AWXDCCViewController.h"
#import "AWXConstants.h"
#import "AWXPaymentItemCell.h"
#import "AWXUtils.h"
#import "AWXWidgets.h"
#import "AWXDevice.h"
#import "AWXPaymentMethod.h"
#import "AWXAPIClient.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXTheme.h"
#import "AWXPaymentIntent.h"
#import "AWXThreeDSService.h"
#import "AWXSecurityService.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentConsent.h"
#import "AWXViewController+Utils.h"

@interface AWXPaymentViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AWXThreeDSServiceDelegate, AWXDCCViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AWXButton *payButton;

@property (strong, nonatomic) NSString *cvc;
@property (strong, nonatomic) AWXThreeDSService *service;
@property (strong, nonatomic) AWXDevice *device;

@property (nullable, copy, nonatomic) NSString *initialPaymentIntentId;

@end

@implementation AWXPaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self enableTapToEndEditting];
    [self.payButton setImage:[UIImage imageNamed:@"lock-white" inBundle:[NSBundle resourceBundle]] forState:UIControlStateNormal];
    [self.payButton setImage:[UIImage imageNamed:@"lock-grey" inBundle:[NSBundle resourceBundle]] forState:UIControlStateDisabled];
    [self.payButton setImageAndTitleHorizontalAlignmentCenter:8];
    self.totalLabel.text = [self.amount stringWithCurrencyCode:self.currency];
    [self.tableView registerNib:[UINib nibWithNibName:@"AWXPaymentItemCell" bundle:[NSBundle sdkBundle]] forCellReuseIdentifier:@"AWXPaymentItemCell"];

    if (self.paymentMethod.card.cvc) {
        self.cvc = self.paymentMethod.card.cvc;
    }

    [self reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDCC"] && [sender isKindOfClass:[AWXConfirmPaymentIntentResponse class]]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWXDCCViewController *controller = (AWXDCCViewController *)navigationController.topViewController;
        controller.response = sender;
        controller.delegate = self;
    }
}

- (void)startAnimating
{
    [super startAnimating];
    self.payButton.enabled = NO;
}

- (void)stopAnimating
{
    [super stopAnimating];
    self.payButton.enabled = YES;
}

- (void)checkPaymentEnabled
{
    if ([Airwallex.supportedNonCardTypes containsObject:self.paymentMethod.type]) {
        self.payButton.enabled = YES;
        return;
    }

    self.payButton.enabled = self.cvc.length > 0;
}

- (void)reloadData
{
    [self checkPaymentEnabled];
    [self.tableView reloadData];
}

- (IBAction)payPressed:(id)sender
{
    self.paymentMethod.card.cvc = self.cvc;
    AWXPaymentMethod *paymentMethod = self.paymentMethod;

    [self confirmPaymentIntentWithPaymentMethod:paymentMethod];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
{
    __weak __typeof(self)weakSelf = self;
    [self startAnimating];
    [[AWXSecurityService sharedService] doProfile:self.paymentIntentId ?: self.initialPaymentIntentId completion:^(NSString * _Nonnull sessionId) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        AWXDevice *device = [AWXDevice new];
        device.deviceId = sessionId;
        if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
            [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device consent:self.paymentConsent];
        } else if ([self.session isKindOfClass:[AWXRecurringSession class]]){
            [strongSelf createPaymentConsentWithPaymentMethod:paymentMethod  createCompletion:^(AWXPaymentConsent * _Nullable consent) {
                [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod consent:consent];
            }];
        } else if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]){
            [strongSelf createPaymentConsentWithPaymentMethod:paymentMethod createCompletion:^(AWXPaymentConsent * _Nullable consent) {
                if ([paymentMethod.type isEqualToString:AWXCardKey]) {
                    [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device consent:consent];
                } else {
                    [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod consent:consent];
                }
            }];
        }
    }];
}

- (void)createPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod createCompletion:(void(^)(AWXPaymentConsent * _Nullable))completion
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.paymentMethod.customerId;
    request.paymentMethod = paymentMethod;
    request.currency = self.currency;
    request.nextTriggerByType = self.nextTriggerByType;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (response && !error) {
            AWXPaymentConsentResponse *result = response;
            completion(result.consent);
        }
    }];
}

- (void)verifyPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod consent:(AWXPaymentConsent *)consent
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXVerifyPaymentConsentRequest *request = [AWXVerifyPaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.currency = self.currency;
    request.amount = self.amount;
    request.consent = consent;
    AWXPaymentMethod * payment = paymentMethod;
    request.options = payment;
    request.returnURL =  @"airwallexcheckout://com.airwallex.paymentacceptance";
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        AWXVerifyPaymentConsentResponse *result = response;
        if ([self.session isKindOfClass:[AWXRecurringSession class]]){
            self.initialPaymentIntentId = result.initialPaymentIntentId;
        }

        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod device:(AWXDevice *)device consent:(AWXPaymentConsent *)consent
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = self.paymentIntentId ?: self.initialPaymentIntentId;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;
    request.paymentConsent = consent;
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
    request.device = device;
    self.device = device;

    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)finishConfirmationWithResponse:(AWXConfirmPaymentIntentResponse *)response error:(nullable NSError *)error
{
    [self stopAnimating];
    
    if (error) {
        [self.delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusError error:error];
        return;
    }

    if ([response.status isEqualToString:@"SUCCEEDED"] || [response.status isEqualToString:@"REQUIRES_CAPTURE"]) {
        [self.delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        return;
    }

    if (!response.nextAction) {
        [self.delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        return;
    }

    if (response.nextAction.weChatPayResponse) {
        [self.delegate paymentViewController:self
                  nextActionWithWeChatPaySDK:response.nextAction.weChatPayResponse];
    } else if (response.nextAction.redirectResponse) {
        AWXThreeDSService *service = [AWXThreeDSService new];
        service.customerId = self.customerId;
        service.intentId   = self.paymentIntentId ?: self.initialPaymentIntentId;
        service.paymentMethod = self.paymentMethod;
        service.device = self.device;
        service.presentingViewController = self;
        service.delegate = self;
        self.service = service;
        
        [self startAnimating];
        [service presentThreeDSFlowWithServerJwt:response.nextAction.redirectResponse.jwt];
    } else if (response.nextAction.dccResponse) {
        [self performSegueWithIdentifier:@"showDCC" sender:response];
    } else if (response.nextAction.url) {
        [self.delegate paymentViewController:self nextActionWithAlipayURL:response.nextAction.url];
    } else {
        [self.delegate paymentViewController:self
                         didFinishWithStatus:AWXPaymentStatusError
                                       error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported next action."}]];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AWXPaymentItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWXPaymentItemCell" forIndexPath:indexPath];
    cell.cvcField.delegate = self;
    cell.cvcField.text = self.cvc;
    cell.titleLabel.text = NSLocalizedString(@"Payment", nil);
    NSString *type = self.paymentMethod.type;
    if ([Airwallex.supportedNonCardTypes containsObject:self.paymentMethod.type]) {
        cell.selectionLabel.text = FormatPaymentMethodTypeString(type);
        cell.cvcHidden = YES;
    } else {
        cell.selectionLabel.text = [NSString stringWithFormat:@"%@ •••• %@", self.paymentMethod.card.brand.capitalizedString, self.paymentMethod.card.last4];
        cell.cvcHidden = NO;
    }
    cell.selectionLabel.textColor = [AWXTheme sharedTheme].textColor;
    cell.isLastCell = YES;
    cell.arrowView.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AWXPaymentItemCell *_cell = (AWXPaymentItemCell *)cell;
    if (_cell.cvcField.text.length == 0 && !_cell.cvcHidden) {
        [_cell.cvcField becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length <= 4) {
        self.cvc = text;
        [self checkPaymentEnabled];
        return YES;
    }
    return NO;
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
    request.intentId = self.paymentIntentId ?: self.initialPaymentIntentId;
    request.type = AWXDCC;
    request.useDCC = useDCC;
    request.device = self.device;

    [self startAnimating];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

@end
