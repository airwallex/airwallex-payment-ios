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
#import "EditShippingViewController.h"
#import "PaymentListViewController.h"
#import "NSNumber+Utils.h"
#import "Widgets.h"

@interface PaymentViewController () <UITableViewDelegate, UITableViewDataSource, EditShippingViewControllerDelegate, PaymentListViewControllerDelegate>

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
    self.totalLabel.text = self.total.string;
    self.items = @[@{@"title": @"Shipping", @"placeholder": @"Enter shipping information"},
                   @{@"title": @"Payment", @"placeholder": @"Select payment method"}];
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
    self.payButton.enabled = self.billing && self.paymentMethod.type;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectShipping"]) {
        EditShippingViewController *controller = (EditShippingViewController *)segue.destinationViewController;
        controller.billing = sender;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"selectPayment"]) {
        PaymentListViewController *controller = (PaymentListViewController *)segue.destinationViewController;
        controller.delegate = self;
        controller.paymentMethod = sender;
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
    if ([title isEqualToString:@"Shipping"]) {
        AWBilling *billing = self.billing;
        if (billing) {
            cell.selectionLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@ %@", billing.firstName, billing.lastName, billing.address.street, billing.address.city, billing.address.state, billing.address.countryCode];
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Black Text Color"];
        } else {
            cell.selectionLabel.text = item[@"placeholder"];
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Placeholder Color"];
        }
    } else {
        NSString *type = self.paymentMethod.type;
        if (type) {
            if ([type isEqualToString:@"card"]) {
                NSString *number = self.paymentMethod.card.number;
                cell.selectionLabel.text = [NSString stringWithFormat:@"Master •••• %@", [number substringFromIndex:number.length - 4]];
            } else {
                cell.selectionLabel.text = @"WeChat pay";
            }
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Black Text Color"];
        } else {
            cell.selectionLabel.text = item[@"placeholder"];
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Placeholder Color"];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = self.items[indexPath.row];
    if ([item[@"title"] isEqualToString:@"Shipping"]) {
        [self performSegueWithIdentifier:@"selectShipping" sender:self.billing];
    } else {
        [self performSegueWithIdentifier:@"selectPayment" sender:self.paymentMethod];
    }
}

- (void)editShippingViewController:(EditShippingViewController *)controller didSelectBilling:(AWBilling *)billing
{
    self.billing = billing;
    [self reloadData];
}

- (void)paymentListViewController:(PaymentListViewController *)controller didSelectMethod:(AWPaymentMethod *)paymentMethod
{
    self.paymentMethod = paymentMethod;
    [self reloadData];
}

- (IBAction)payPressed:(id)sender
{
    // Using payment method
    AWPaymentMethod *paymentMethod = [AWPaymentMethod new];
    paymentMethod.type = @"card";

    AWCard *card = [AWCard new];
    card.number = @"4012000300001003";
    card.name = @"Adam";
    card.expYear = @"2020";
    card.expMonth = @"12";
    card.cvc = @"123";
    paymentMethod.card = card;
    paymentMethod.billing = self.billing;

    // Using payment method selected
//    AWPaymentMethod *paymentMethod = self.paymentMethod;
//    paymentMethod.billing = self.billing;

    AWAPIClient *client = [AWAPIClient new];
    AWConfirmPaymentIntentRequest *request = [AWConfirmPaymentIntentRequest new];
    request.intentId = client.configuration.intentId;
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethod = paymentMethod;

    [SVProgressHUD show];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        PayReq *request = [[PayReq alloc] init];
        request.partnerId = @"334777613";
        request.prepayId = @"wx20160642629447d58cef99b51132242000";
        request.package = @"Sign=WXPay";
        request.nonceStr = @"t2XhtFHvMBJ5oSDjhe3dVuREHbQrDncR";
        request.timeStamp = 1579507602;
        request.sign= @"7B8FD19DC494D4CDA5EC55241048D2BB594945E6558449E9A2636B9A71ED0CD1";

        // WeChatSDK 1.8.2
        [WXApi sendReq:request];

        // WeChatSDK 1.8.6.1
//        [WXApi sendReq:request completion:^(BOOL success) {
//            if (!success) {
//                [SVProgressHUD showErrorWithStatus:@"Failed to call WeChat Pay"];
//                return;
//            }
//        }];
    }];
}

@end
