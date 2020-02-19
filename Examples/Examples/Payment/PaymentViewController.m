//
//  PaymentViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "PaymentViewController.h"
#import <Airwallex/Airwallex.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "WXApi.h"
#import "PaymentItemCell.h"
#import "EditBillingViewController.h"
#import "PaymentListViewController.h"
#import "NSNumber+Utils.h"
#import "Widgets.h"
#import "UIButton+Utils.h"

@interface PaymentViewController () <UITableViewDelegate, UITableViewDataSource, EditBillingViewControllerDelegate, PaymentListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet Button *payButton;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) AWBilling *billing;
@property (strong, nonatomic) AWPaymentMethod *paymentMethod;

@end

@implementation PaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.payButton setImageAndTitleHorizontalAlignmentCenter:8];
    self.totalLabel.text = self.total.string;
    self.items = @[@{@"title": @"Payment", @"placeholder": @"Select payment method"},
                   @{@"title": @"Billing", @"placeholder": @"Enter shipping information"}];
    [self.tableView registerNib:[UINib nibWithNibName:@"PaymentItemCell" bundle:nil] forCellReuseIdentifier:@"PaymentItemCell"];
    [self reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pop) name:@"PaymentCompleted" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pop
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)reloadData
{
    self.payButton.enabled = self.currentBilling && self.paymentMethod;
    [self.tableView reloadData];
}

- (AWBilling *)currentBilling
{
    return self.sameAsShipping ? self.shipping : self.billing;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"enterAddress"]) {
        EditBillingViewController *controller = (EditBillingViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.billing = self.currentBilling;
        controller.sameAsShipping = self.sameAsShipping;
    } else if ([segue.identifier isEqualToString:@"selectPayment"]) {
        PaymentListViewController *controller = (PaymentListViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.paymentMethod = self.paymentMethod;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentItemCell" forIndexPath:indexPath];
    NSDictionary *item = self.items[indexPath.row];
    NSString *title = item[@"title"];
    cell.titleLabel.text = title;
    if ([title isEqualToString:@"Billing"]) {
        AWBilling *billing = self.currentBilling;
        if (self.sameAsShipping) {
            cell.selectionLabel.text = @"Same as shipping information";
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Black Text Color"];
        } else if (billing) {
            cell.selectionLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@ %@", billing.firstName, billing.lastName, billing.address.street, billing.address.city, billing.address.state, billing.address.countryCode];
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Black Text Color"];
        } else {
            cell.selectionLabel.text = item[@"placeholder"];
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Placeholder Color"];
        }
    } else {
        NSString *type = self.paymentMethod.type;
        if (type) {
            if ([type isEqualToString:AWWechatpay]) {
                cell.selectionLabel.text = @"WeChat pay";
            } else {
                cell.selectionLabel.text = [NSString stringWithFormat:@"%@ •••• %@", self.paymentMethod.card.brand.capitalizedString, self.paymentMethod.card.last4];
            }
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Black Text Color"];
        } else {
            cell.selectionLabel.text = item[@"placeholder"];
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Placeholder Color"];
        }
    }
    cell.isLastCell = indexPath.item == self.items.count - 1;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = self.items[indexPath.row];
    if ([item[@"title"] isEqualToString:@"Billing"]) {
        [self performSegueWithIdentifier:@"enterAddress" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"selectPayment" sender:nil];
    }
}

- (void)didEndEditingBillingViewController:(EditBillingViewController *)controller
{
    self.billing = controller.billing;
    self.sameAsShipping = controller.sameAsShipping;
    [self reloadData];
}

- (void)paymentListViewController:(PaymentListViewController *)controller didSelectMethod:(AWPaymentMethod *)paymentMethod
{
    self.paymentMethod = paymentMethod;
    [self reloadData];
}

- (IBAction)payPressed:(id)sender
{
    AWPaymentMethod *paymentMethod = self.paymentMethod;
    paymentMethod.billing = self.currentBilling;

    // Just for wechat pay testing
    if ([paymentMethod.type isEqualToString:AWWechatpay]) {
        paymentMethod.Id = nil;
        paymentMethod.wechatpay.flow = @"inapp";
    }

    AWAPIClient *client = [AWAPIClient new];
    AWConfirmPaymentIntentRequest *request = [AWConfirmPaymentIntentRequest new];
    request.intentId = client.configuration.intentId;
    request.requestId = NSUUID.UUID.UUIDString;
    AWPaymentMethodOptions *options = [AWPaymentMethodOptions new];
    options.autoCapture = YES;
    options.threeDsOption = NO;
    request.options = options;
    request.paymentMethod = paymentMethod;

    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        AWConfirmPaymentIntentResponse *result = (AWConfirmPaymentIntentResponse *)response;
        __strong typeof(self) strongSelf = weakSelf;
        if ([result.status isEqualToString:@"SUCCEEDED"]) {
            [strongSelf.navigationController popToRootViewControllerAnimated:YES];
            [SVProgressHUD showSuccessWithStatus:@"Pay successfully"];
            return;
        }

        if (!result.nextAction) {
            [strongSelf finishPayment];
            return;
        }

        if ([result.nextAction.type isEqualToString:@"call_sdk"]) {
            [strongSelf payWithWeChatSDK:result.nextAction.wechatResponse];
        }
    }];
}

- (void)checkPaymentIntentStatusWithCompletion:(void (^)(BOOL success))completionHandler
{
    AWGetPaymentIntentRequest *request = [[AWGetPaymentIntentRequest alloc] init];
    request.intentId = [AWPaymentConfiguration sharedConfiguration].intentId;
    [[AWAPIClient new] send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        AWGetPaymentIntentResponse *result = (AWGetPaymentIntentResponse *)response;
        completionHandler([result.status isEqualToString:@"SUCCEEDED"]);
    }];
}

- (void)finishPayment
{
    [self checkPaymentIntentStatusWithCompletion:^(BOOL success) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [SVProgressHUD showSuccessWithStatus:success ? @"Pay successfully": @"Waiting payment completion"];
    }];
}

- (void)payWithWeChatSDK:(AWWechatPaySDKResponse *)response
{
    NSURL *url = [NSURL URLWithString:response.prepayId];
    if (url) {
        __weak typeof(self) weakSelf = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                return;
            }

            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf finishPayment];
        }] resume];
        return;
    }

    PayReq *request = [[PayReq alloc] init];
    request.partnerId = response.partnerId;
    request.prepayId = response.prepayId;
    request.package = response.package;
    request.nonceStr = response.nonceStr;
    request.timeStamp = response.timeStamp.doubleValue;
    request.sign = response.sign;

    // WeChatSDK 1.8.2
    [WXApi sendReq:request];

    //WeChatSDK 1.8.6.1
//    [WXApi sendReq:request completion:^(BOOL success) {
//        if (!success) {
//            [SVProgressHUD showErrorWithStatus:@"Failed to call WeChat Pay"];
//            return;
//        }
//    }];
}

@end
