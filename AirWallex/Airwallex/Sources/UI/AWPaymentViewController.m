//
//  PaymentViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AWConstants.h"
#import "AWPaymentItemCell.h"
#import "AWUtils.h"
#import "AWWidgets.h"
#import "AWDevice.h"
#import "AWPaymentMethod.h"
#import "AWAPIClient.h"
#import "AWPaymentIntentRequest.h"
#import "AWPaymentMethodOptions.h"
#import "AWPaymentIntentResponse.h"
#import "AWTheme.h"
#import "AWPaymentIntent.h"
#import "AW3DSService.h"
#import "AWSecurityService.h"

@interface AWPaymentViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AW3DSServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AWButton *payButton;

@property (strong, nonatomic) NSString *cvc;
@property (strong, nonatomic, readonly) AW3DSService *service;

@end

@implementation AWPaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.payButton setImage:[UIImage imageNamed:@"lock-white" inBundle:[NSBundle resourceBundle]] forState:UIControlStateNormal];
    [self.payButton setImage:[UIImage imageNamed:@"lock-grey" inBundle:[NSBundle resourceBundle]] forState:UIControlStateDisabled];
    [self.payButton setImageAndTitleHorizontalAlignmentCenter:8];
    self.totalLabel.text = self.paymentIntent.amount.string;
    [self.tableView registerNib:[UINib nibWithNibName:@"AWPaymentItemCell" bundle:[NSBundle sdkBundle]] forCellReuseIdentifier:@"AWPaymentItemCell"];

    if (self.paymentMethod.card.cvc) {
        self.cvc = self.paymentMethod.card.cvc;
    } else {
        NSString *cvc = [[NSUserDefaults awUserDefaults] stringForKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
        if (cvc) {
            self.cvc = cvc;
        }
    }

    [self reloadData];
}

- (void)checkPaymentEnabled
{
    if ([self.paymentMethod.type isEqualToString:AWWeChatPayKey]) {
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

- (AW3DSService *)service
{
    AW3DSService *service = [AW3DSService new];
    service.customerId = self.paymentIntent.customerId;
    service.intentId = self.paymentIntent.Id;
    service.paymentMethod = self.paymentMethod;
    service.presentingViewController = self;
    service.delegate = self;
    return service;
}

- (IBAction)payPressed:(id)sender
{
    self.paymentMethod.card.cvc = self.cvc;
    AWPaymentMethod *paymentMethod = self.paymentMethod;

    [self confirmPaymentIntentWithPaymentMethod:paymentMethod];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWPaymentMethod *)paymentMethod
{
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD show];
    [[AWSecurityService sharedService] doProfile:[AWUIContext sharedContext].paymentIntent.Id completion:^(NSString * _Nonnull sessionId) {
        [SVProgressHUD dismiss];
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        AWDevice *device = [AWDevice new];
        device.deviceId = sessionId;
        [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device];
    }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWPaymentMethod *)paymentMethod device:(AWDevice *)device
{
    AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
    AWConfirmPaymentIntentRequest *request = [AWConfirmPaymentIntentRequest new];
    request.intentId = self.paymentIntent.Id;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.paymentIntent.customerId;
    AWPaymentMethodOptions *options = [AWPaymentMethodOptions new];
    request.options = options;
    request.paymentMethod = paymentMethod;
    request.device = device;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];

        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)finishConfirmationWithResponse:(AWConfirmPaymentIntentResponse *)response error:(nullable NSError *)error
{
    if (error) {
        [[NSUserDefaults awUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
        [[NSUserDefaults awUserDefaults] synchronize];
        [self.delegate paymentViewController:self didFinishWithStatus:AWPaymentStatusError error:error];
        return;
    }

    [[NSUserDefaults awUserDefaults] setObject:self.cvc forKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
    [[NSUserDefaults awUserDefaults] synchronize];

    if ([response.status isEqualToString:@"SUCCEEDED"]) {
        [self.delegate paymentViewController:self didFinishWithStatus:AWPaymentStatusSuccess error:error];
        return;
    }

    if (!response.nextAction) {
        [self.delegate paymentViewController:self didFinishWithStatus:AWPaymentStatusSuccess error:error];
        return;
    }

    if (response.nextAction.weChatPayResponse) {
        [self.delegate paymentViewController:self
                  nextActionWithWeChatPaySDK:response.nextAction.weChatPayResponse];
    } else if (response.nextAction.redirectResponse) {
        [self.service present3DSFlowWithRedirectResponse:response.nextAction.redirectResponse];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AWPaymentItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWPaymentItemCell" forIndexPath:indexPath];
    cell.cvcField.delegate = self;
    cell.cvcField.text = self.cvc;
    cell.titleLabel.text = @"Payment";
    NSString *type = self.paymentMethod.type;
    if ([type isEqualToString:AWWeChatPayKey]) {
        cell.selectionLabel.text = @"WeChat pay";
        cell.cvcHidden = YES;
    } else {
        cell.selectionLabel.text = [NSString stringWithFormat:@"%@ •••• %@", self.paymentMethod.card.brand.capitalizedString, self.paymentMethod.card.last4];
        cell.cvcHidden = NO;
    }
    cell.selectionLabel.textColor = [AWTheme sharedTheme].textColor;
    cell.isLastCell = YES;
    cell.arrowView.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AWPaymentItemCell *_cell = (AWPaymentItemCell *)cell;
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

@end
