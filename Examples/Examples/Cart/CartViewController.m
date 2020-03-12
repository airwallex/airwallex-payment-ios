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
#import "Constant.h"

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
    [self.tableView registerNib:[UINib nibWithNibName:@"AWPaymentItemCell" bundle:[NSBundle sdkBundle]]
         forCellReuseIdentifier:@"AWPaymentItemCell"];
    Product *product0 = [[Product alloc] initWithName:@"AirPods Pro"
                                               detail:@"Free engraving x 1"
                                                price:[NSDecimalNumber decimalNumberWithString:@"399"]];
    Product *product1 = [[Product alloc] initWithName:@"HomePod"
                                               detail:@"White x 1"
                                                price:[NSDecimalNumber decimalNumberWithString:@"469"]];
    self.products = [@[product0, product1] mutableCopy];
    [self reloadData];
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
        controller.shipping = self.shipping;
        controller.delegate = self;
    }
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

#pragma mark - Check Out

- (IBAction)checkoutPressed:(id)sender
{
    if (self.products.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"No products in your cart"];
        return;
    }

    // 1. Setup Airwallex Configuration
    AWPaymentConfiguration *configuration = [AWPaymentConfiguration sharedConfiguration];
    configuration.shipping = self.shipping;
    NSDecimalNumber *subtotal = [self.products valueForKeyPath:@"@sum.self.price"];
    NSDecimalNumber *shipping = [NSDecimalNumber zero];
    NSDecimalNumber *total = [subtotal decimalNumberByAdding:shipping];
    configuration.totalNumber = total;
    configuration.delegate = self;
    configuration.baseURL = @"https://staging-pci-api.airwallex.com";

    [SVProgressHUD show];
    [[APIClient sharedClient] createAuthenticationToken:[NSURL URLWithString:authenticationURL]
                                               clientId:clientId
                                                 apiKey:apiKey
                                      completionHandler:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        configuration.token = token;

        __block NSError *finalError = nil;
        dispatch_group_t group = dispatch_group_create();

        NSMutableDictionary *parameters = [@{@"amount": total,
                                             @"currency": @"USD",
                                             @"merchant_order_id": NSUUID.UUID.UUIDString,
                                             @"request_id": NSUUID.UUID.UUIDString,
                                             @"order": @{}} mutableCopy];
        dispatch_group_enter(group);
        [[APIClient sharedClient] createPaymentIntent:[NSURL URLWithString:paymentIntentsURL]
                                                token:token
                                           parameters:parameters
                                    completionHandler:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            if (error) {
                finalError = error;
                dispatch_group_leave(group);
                return;
            }

            configuration.intentId = result[@"id"];
            configuration.clientSecret = result[@"client_secret"];
            configuration.currency = result[@"currency"];
            dispatch_group_leave(group);
        }];

        NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:@"Cached Customer ID"];
        if (customerId) {
            configuration.customerId = customerId;
        } else {
            dispatch_group_enter(group);
            [[APIClient sharedClient] createCustomer:[NSURL URLWithString:customersURL]
                                               token:token
                                          parameters:@{@"request_id": NSUUID.UUID.UUIDString,
                                                       @"merchant_customer_id": NSUUID.UUID.UUIDString,
                                                       @"first_name": @"John",
                                                       @"last_name": @"Doe",
                                                       @"email": @"john.doe@airwallex.com",
                                                       @"phone_number": @"13800000000",
                                                       @"additional_info": @{@"registered_via_social_media": @NO,
                                                                             @"registration_date": @"2019-09-18",
                                                                             @"first_successful_order_date": @"2019-09-18"},
                                                       @"metadata": @{@"id": @1}}
                                   completionHandler:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
                if (error) {
                    finalError = error;
                    dispatch_group_leave(group);
                    return;
                }

                NSString *customerId = result[@"id"];
                if (customerId) {
                    configuration.customerId = result[@"id"];
                    [[NSUserDefaults standardUserDefaults] setObject:customerId forKey:@"Cached Customer ID"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                dispatch_group_leave(group);
            }];
        }

        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (finalError) {
                [SVProgressHUD showErrorWithStatus:finalError.localizedDescription];
                return;
            }

            [SVProgressHUD dismiss];

            // 2. Show the payment method list or load the payment detail with selected payment method
            [self loadPaymentMethodList];
        });
    }];
}

#pragma mark - Show Payment Method List

- (void)loadPaymentMethodList
{
    UINavigationController *navigationController = [AWPaymentUI paymentMethodListNavigationController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

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

#pragma mark - AWEditShippingViewControllerDelegate

- (void)editShippingViewController:(AWEditShippingViewController *)controller didSelectBilling:(AWBilling *)billing
{
    [controller.navigationController popViewControllerAnimated:YES];
    // Please remove fake email later
    billing.email = @"jim631@sina.com";

    self.shipping = billing;
    [self reloadData];
}

#pragma mark - AWPaymentResultDelegate

- (void)paymentDidFinishWithStatus:(AWPaymentStatus)status error:(nullable NSError *)error
{
    NSString *message = error.localizedDescription;
    if (status == AWPaymentStatusSuccess) {
        message = @"Pay successfully";
    } else if (status == AWPaymentStatusUserCancellation) {
        message = @"Payment cancelled";
    }
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)paymentWithWechatPaySDK:(AWWechatPaySDKResponse *)response
{
    NSURL *url = [NSURL URLWithString:response.prepayId];
    if (url) {
        [SVProgressHUD show];

        __weak typeof(self) weakSelf = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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

//    WeChatSDK 1.8.6.1
//        [WXApi sendReq:request completion:^(BOOL success) {
//            if (!success) {
//                [SVProgressHUD showErrorWithStatus:@"Failed to call WeChat Pay"];
//                return;
//            }
//        }];
}

#pragma mark - Check Payment Intent Status

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
        [SVProgressHUD dismiss];
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                            message:success ? @"Pay successfully": @"Waiting payment completion"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

@end
