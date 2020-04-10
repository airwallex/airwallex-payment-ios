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
#import <WechatOpenSDK/WXApi.h>
#import "OptionsViewController.h"
#import "ProductCell.h"
#import "TotalCell.h"
#import "APIClient.h"
#import "Constant.h"

static NSString * const kCachedCustomerID = @"kCachedCustomerID";

@interface CartViewController () <UITableViewDelegate, UITableViewDataSource, OptionsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (strong, nonatomic) NSMutableArray *products;

@property (strong, nonatomic) NSDecimalNumber *amount;
@property (strong, nonatomic) NSString *currency;
@property (strong, nonatomic) AWPaymentIntent *paymentIntent;

@end

@implementation CartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.badgeView.layer.masksToBounds = YES;
    self.badgeView.layer.cornerRadius = 12;
    self.checkoutButton.layer.masksToBounds = YES;
    self.checkoutButton.layer.cornerRadius = 6;
    
    Product *product0 = [[Product alloc] initWithName:@"AirPods Pro"
                                               detail:@"Free engraving x 1"
                                                price:[NSDecimalNumber decimalNumberWithString:@"399"]];
    Product *product1 = [[Product alloc] initWithName:@"HomePod"
                                               detail:@"White x 1"
                                                price:[NSDecimalNumber decimalNumberWithString:@"469"]];
    self.products = [@[product0, product1] mutableCopy];
    self.amount = [NSDecimalNumber decimalNumberWithString:defaultAmount];
    self.currency = defaultCurrency;
    
    APIClient *client = [APIClient sharedClient];
    client.authBaseURL = [NSURL URLWithString:authenticationBaseURL];
    client.paymentBaseURL = [NSURL URLWithString:paymentBaseURL];
    client.apiKey = apiKey;
    client.clientID = clientID;
    
    [self reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.badgeView.layer.cornerRadius = CGRectGetWidth(self.badgeView.bounds) / 2;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToSettings"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        OptionsViewController *controller = (OptionsViewController *)navigationController.topViewController;
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
    
    self.checkoutButton.enabled = total.doubleValue > 0 && self.amount.doubleValue > 0 && self.currency.length > 0;
    self.checkoutButton.backgroundColor = self.checkoutButton.enabled ? [UIColor colorNamed:@"Purple Color"] : [UIColor colorNamed:@"Line Color"];
    
    [self.tableView reloadData];
}

#pragma mark - Check Out

- (IBAction)checkoutPressed:(id)sender
{
    if (self.products.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"No products in your cart"];
        return;
    }
    
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [[APIClient sharedClient] createAuthenticationTokenWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID];
        if (customerId) {
            [strongSelf createPaymentIntentWithCustomerId:customerId];
            return;
        }
        
        [[APIClient sharedClient] createCustomerWithParameters:@{@"request_id": NSUUID.UUID.UUIDString,
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
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                return;
            }
            
            NSString *customerId = result[@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:customerId forKey:kCachedCustomerID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [strongSelf createPaymentIntentWithCustomerId:customerId];
        }];
    }];
}

#pragma mark - Create Payment Intent

- (void)createPaymentIntentWithCustomerId:(NSString *)customerId
{
    NSMutableDictionary *parameters = [@{@"amount": self.amount,
                                         @"currency": self.currency,
                                         @"merchant_order_id": NSUUID.UUID.UUIDString,
                                         @"request_id": NSUUID.UUID.UUIDString,
                                         @"order": @{}} mutableCopy];
    if (customerId) {
        parameters[@"customer_id"] = customerId;
    }
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD show];
    [[APIClient sharedClient] createPaymentIntentWithParameters:parameters
                                              completionHandler:^(AWPaymentIntent * _Nullable paymentIntent, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        
        if (paymentIntent.Id && paymentIntent.clientSecret) {
            [AWAPIClientConfiguration sharedConfiguration].clientSecret = paymentIntent.clientSecret;
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf confirmPaymentIntent:paymentIntent];
            return;
        }
        
        [SVProgressHUD showErrorWithStatus:@"Failed to create payment intent."];
    }];
}

#pragma mark - Confirm Payment Intent Directly

- (void)confirmPaymentIntent:(AWPaymentIntent *)paymentIntent
{
    self.paymentIntent = paymentIntent;
    
    AWWeChatPay *weChatPay = [AWWeChatPay new];
    
    AWPaymentMethod *paymentMethod = [AWPaymentMethod new];
    NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID];
    paymentMethod.customerId = customerId;
    paymentMethod.type = AWWeChatPayKey;
    paymentMethod.weChatPay = weChatPay;
    
    AWConfirmPaymentIntentRequest *request = [AWConfirmPaymentIntentRequest new];
    request.customerId = customerId;
    request.intentId = paymentIntent.Id;
    request.paymentMethod = paymentMethod;
    request.requestId = NSUUID.UUID.UUIDString;
    
    [SVProgressHUD show];
    [[AWAPIClient sharedClient] send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        
        if ([response isKindOfClass:[AWConfirmPaymentIntentResponse class]]) {
            AWConfirmPaymentIntentResponse *result = (AWConfirmPaymentIntentResponse *)response;
            
            if ([result.status isEqualToString:@"SUCCEEDED"]) {
                [SVProgressHUD showSuccessWithStatus:@"Pay successfully"];
                return;
            }
            
            if (result.nextAction && result.nextAction.weChatPayResponse) {
                [self handleConfirmPaymentIntentResponse:result.nextAction.weChatPayResponse];
                return;
            }
        }
        
        [SVProgressHUD showErrorWithStatus:@"Failed to confirm payment intent."];
    }];
}

- (void)handleConfirmPaymentIntentResponse:(AWWeChatPaySDKResponse *)response
{
    /**
     To mock the wechat payment flow, we use an url to call instead wechat callback.
     */
    NSURL *url = [NSURL URLWithString:response.prepayId];
    if (url.scheme && url.host) {
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
    //    [WXApi sendReq:request completion:^(BOOL success) {
    //        if (!success) {
    //            [SVProgressHUD showErrorWithStatus:@"Failed to call WeChat Pay"];
    //            return;
    //        }
    //
    //        [SVProgressHUD showSuccessWithStatus:@"Succeed to pay"];
    //    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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

#pragma mark - OptionsViewControllerDelegate

- (void)optionsViewController:(OptionsViewController *)viewController didEditAmount:(NSDecimalNumber *)amount
{
    self.amount = amount;
    [self reloadData];
}

- (void)optionsViewController:(OptionsViewController *)viewController didEditCurrency:(NSString *)currency
{
    self.currency = currency;
    [self reloadData];
}

#pragma mark - Check Payment Intent Status

- (void)checkPaymentIntentStatusWithCompletion:(void (^)(BOOL success))completionHandler
{
    AWRetrievePaymentIntentRequest *request = [[AWRetrievePaymentIntentRequest alloc] init];
    request.intentId = self.paymentIntent.Id;
    AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
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
