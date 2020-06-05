//
//  PaymentViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
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

@interface AWXPaymentViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AWXThreeDSServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AWXButton *payButton;

@property (strong, nonatomic) NSString *cvc;
@property (strong, nonatomic) AWXThreeDSService *service;
@property (strong, nonatomic) AWXDevice *device;

@end

@implementation AWXPaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.payButton setImage:[UIImage imageNamed:@"lock-white" inBundle:[NSBundle resourceBundle]] forState:UIControlStateNormal];
    [self.payButton setImage:[UIImage imageNamed:@"lock-grey" inBundle:[NSBundle resourceBundle]] forState:UIControlStateDisabled];
    [self.payButton setImageAndTitleHorizontalAlignmentCenter:8];
    self.totalLabel.text = self.paymentIntent.amount.string;
    [self.tableView registerNib:[UINib nibWithNibName:@"AWXPaymentItemCell" bundle:[NSBundle sdkBundle]] forCellReuseIdentifier:@"AWXPaymentItemCell"];

    if (self.paymentMethod.card.cvc) {
        self.cvc = self.paymentMethod.card.cvc;
    } else {
        NSString *cvc = [[NSUserDefaults awxUserDefaults] stringForKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
        if (cvc) {
            self.cvc = cvc;
        }
    }

    [self reloadData];
}

- (void)checkPaymentEnabled
{
    if ([self.paymentMethod.type isEqualToString:AWXWeChatPayKey]) {
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
    request.intentId = self.paymentIntent.Id;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.paymentIntent.customerId;

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
    if (error) {
        [[NSUserDefaults awxUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
        [[NSUserDefaults awxUserDefaults] synchronize];
        [self.delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusError error:error];
        return;
    }

    [[NSUserDefaults awxUserDefaults] setObject:self.cvc forKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
    [[NSUserDefaults awxUserDefaults] synchronize];

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
        service.customerId = self.paymentIntent.customerId;
        service.intentId = self.paymentIntent.Id;
        service.paymentMethod = self.paymentMethod;
        service.device = self.device;
        service.presentingViewController = self;
        service.delegate = self;
        self.service = service;
        [service presentThreeDSFlowWithServerJwt:response.nextAction.redirectResponse.jwt];
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
    cell.titleLabel.text = @"Payment";
    NSString *type = self.paymentMethod.type;
    if ([type isEqualToString:AWXWeChatPayKey]) {
        cell.selectionLabel.text = @"WeChat pay";
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
    if (_cell.cvcField.text.length == 0) {
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

@end
