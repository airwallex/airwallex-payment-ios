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
#import "Widgets.h"
#import "ProductCell.h"
#import "TotalCell.h"
#import "APIClient.h"
#import "PaymentViewController.h"

@interface CartViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet View *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *products;

@end

@implementation CartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    Product *product0 = [[Product alloc] initWithName:@"AirPods Pro" detail:@"Free engraving x 1" price:[NSDecimalNumber decimalNumberWithString:@"399"]];
    Product *product1 = [[Product alloc] initWithName:@"HomePod" detail:@"White x 1" price:[NSDecimalNumber decimalNumberWithString:@"469"]];

    self.products = [@[product0, product1] mutableCopy];
}

- (void)reloadData
{
    self.badgeView.hidden = self.products.count == 0;
    self.badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.products.count];
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.badgeView.cornerRadius = CGRectGetWidth(self.badgeView.bounds) / 2;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"checkout"]) {
        PaymentViewController *controller = (PaymentViewController *)segue.destinationViewController;
        controller.total = sender;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.products.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

        NSMutableDictionary *parameters = [@{@"amount": @100, @"currency": @"USD", @"merchant_order_id": NSUUID.UUID.UUIDString, @"request_id": NSUUID.UUID.UUIDString, @"order": @{}} mutableCopy];
        [[APIClient sharedClient] createPaymentIntent:[NSURL URLWithString:paymentURL] token:token parameters:parameters completionHandler:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                return;
            }

            AWPaymentConfiguration *configuration = [AWPaymentConfiguration sharedConfiguration];
            configuration.baseURL = @"https://staging-pci-api.airwallex.com";
            configuration.intentId = result[@"id"];
            configuration.requestId = result[@"request_id"];
            configuration.token = token;

            [SVProgressHUD dismiss];

            NSDecimalNumber *subtotal = [self.products valueForKeyPath:@"@sum.self.price"];
            NSDecimalNumber *shipping = [NSDecimalNumber zero];
            NSDecimalNumber *total = [subtotal decimalNumberByAdding:shipping];
            [self performSegueWithIdentifier:@"checkout" sender:total];
        }];
    }];
}

@end
