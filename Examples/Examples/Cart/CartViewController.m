//
//  CartViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "CartViewController.h"
#import <Airwallex/Airwallex.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ProductCell.h"
#import "TotalCell.h"
#import "APIClient.h"
#import "WXApi.h"

@interface CartViewController () <UITableViewDelegate, UITableViewDataSource, AWEditShippingViewControllerDelegate, AWPaymentResultDelegate>

@property (weak, nonatomic) IBOutlet AWView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AWButton *checkoutButton;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) AWBilling *shipping;

@end

@implementation CartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"PaymentItemCell" bundle:nil] forCellReuseIdentifier:@"PaymentItemCell"];
    Product *product0 = [[Product alloc] initWithName:@"AirPods Pro" detail:@"Free engraving x 1" price:[NSDecimalNumber decimalNumberWithString:@"399"]];
    Product *product1 = [[Product alloc] initWithName:@"HomePod" detail:@"White x 1" price:[NSDecimalNumber decimalNumberWithString:@"469"]];
    self.products = [@[product0, product1] mutableCopy];
    [self reloadData];
}

- (void)reloadData
{
    self.badgeView.hidden = self.products.count == 0;
    self.badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.products.count];

    NSDecimalNumber *subtotal = [self.products valueForKeyPath:@"@sum.self.price"];
    NSDecimalNumber *shipping = [NSDecimalNumber zero];
    NSDecimalNumber *total = [subtotal decimalNumberByAdding:shipping];

    self.checkoutButton.enabled = self.shipping != nil && total.doubleValue != 0;
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.badgeView.cornerRadius = CGRectGetWidth(self.badgeView.bounds) / 2;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"enterAddress"]) {
        AWEditShippingViewController *controller = (AWEditShippingViewController *)segue.destinationViewController;
        controller.billing = self.shipping;
        controller.delegate = self;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.products.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 9;
    }
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        AWPaymentItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWPaymentItemCell" forIndexPath:indexPath];
        cell.titleLabel.text = @"Shipping";
        AWBilling *shipping = self.shipping;
        if (shipping) {
            cell.selectionLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@ %@", shipping.firstName, shipping.lastName, shipping.address.street, shipping.address.city, shipping.address.state, shipping.address.countryCode];
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Black Text Color"];
        } else {
            cell.selectionLabel.text = @"Enter shipping information";
            cell.selectionLabel.textColor = [UIColor colorNamed:@"Placeholder Color"];
        }
        cell.isLastCell = YES;
        cell.cvcHidden = YES;
        return cell;
    }

    if (self.products.count == indexPath.row) {
        TotalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TotalCell" forIndexPath:indexPath];
        NSDecimalNumber *subtotal = [self.products valueForKeyPath:@"@sum.self.price"];
        NSDecimalNumber *shipping = [NSDecimalNumber zero];
        cell.subtotal = subtotal;
        cell.shipping = shipping;
        cell.total = [subtotal decimalNumberByAdding:shipping];
        return cell;
    }

    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    cell.product = self.products[indexPath.row];
    __weak typeof(self) weakSelf = self;
    cell.handler = ^(Product *product) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.products removeObject:product];
        [strongSelf reloadData];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"enterAddress" sender:nil];
    }
}

- (void)editShippingViewController:(AWEditShippingViewController *)controller didSelectBilling:(AWBilling *)billing
{
    self.shipping = billing;
    [self reloadData];
}

- (IBAction)checkoutPressed:(id)sender
{
    if (self.products.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"No products in your cart"];
        return;
    }

    [SVProgressHUD show];
    [[APIClient sharedClient] createAuthenticationToken:[NSURL URLWithString:authenticationURL] clientId:clientId apiKey:apiKey completionHandler:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        NSDecimalNumber *subtotal = [self.products valueForKeyPath:@"@sum.self.price"];
        NSDecimalNumber *shipping = [NSDecimalNumber zero];
        NSDecimalNumber *total = [subtotal decimalNumberByAdding:shipping];

        NSMutableDictionary *parameters = [@{@"amount": total, @"currency": @"USD", @"merchant_order_id": NSUUID.UUID.UUIDString, @"request_id": NSUUID.UUID.UUIDString, @"order": @{}} mutableCopy];
        [[APIClient sharedClient] createPaymentIntent:[NSURL URLWithString:paymentURL] token:token parameters:parameters completionHandler:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                return;
            }

            AWPaymentConfiguration *configuration = [AWPaymentConfiguration sharedConfiguration];
            configuration.baseURL = @"https://staging-pci-api.airwallex.com";
            configuration.customerId = @"cus_Dn6mVcMeTEkJgYuu9o5xEcxWRah";
            configuration.intentId = result[@"id"];
            configuration.token = token;
            configuration.clientSecret = result[@"client_secret"];
            configuration.currency = result[@"currency"];
            configuration.shipping = self.shipping;
            configuration.delegate = self;

            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:@"selectPaymentMethod" sender:nil];
        }];
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

- (void)paymentDidFinishWithStatus:(AWPaymentStatus)status error:(nullable NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];

    if (error) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }

    if (status == AWPaymentStatusSuccess) {
        [SVProgressHUD showSuccessWithStatus:@"Pay successfully"];
    } else if (status == AWPaymentStatusUserCancellation) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"Payment cancelled" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)paymentWithWechatPaySDK:(AWWechatPaySDKResponse *)response
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
