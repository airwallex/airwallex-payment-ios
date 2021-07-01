//
//  CartViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/15.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "CartViewController.h"
#import <SafariServices/SFSafariViewController.h>
#import <Airwallex/Airwallex.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <WechatOpenSDK/WXApi.h>
#import "AirwallexExamplesKeys.h"
#import "OptionsViewController.h"
#import "ShippingCell.h"
#import "ProductCell.h"
#import "TotalCell.h"
#import "APIClient.h"

@interface CartViewController () <UITableViewDelegate, UITableViewDataSource, AWXShippingViewControllerDelegate, AWXPaymentResultDelegate, OptionsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) AWXPlaceDetails *shipping;

@property (strong, nonatomic) NSDecimalNumber *amount;
@property (strong, nonatomic) NSString *currency;
@property (strong, nonatomic) AWXPaymentIntent *paymentIntent;

@end

@implementation CartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.badgeView.backgroundColor = [[AWXTheme sharedTheme].tintColor colorWithAlphaComponent:0.5];
    self.badgeLabel.textColor = [AWXTheme sharedTheme].tintColor;
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
    self.amount = [NSDecimalNumber decimalNumberWithString:[AirwallexExamplesKeys shared].amount];
    self.currency = [AirwallexExamplesKeys shared].currency;
    
    APIClient *client = [APIClient sharedClient];
    client.paymentBaseURL = [NSURL URLWithString:[AirwallexExamplesKeys shared].baseUrl];
    client.apiKey = [AirwallexExamplesKeys shared].apiKey;
    client.clientID = [AirwallexExamplesKeys shared].clientId;
        
   NSDictionary *shipping = @{
                              @"first_name": @"Verify",
                              @"last_name": @"Doe",
                              @"phone_number": @"13800000000",
                              @"address": @{
                                      @"country_code": @"CN",
                                      @"state": @"Shanghai",
                                      @"city": @"Shanghai",
                                      @"street": @"Pudong District",
                                      @"postcode": @"100000"
                              }
                       };
    self.shipping =  [AWXPlaceDetails decodeFromJSON:shipping];

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
        controller.amount = self.amount;
        controller.currency = self.currency;
    }
}

- (void)reloadData
{
    self.badgeView.hidden = self.products.count == 0;
    self.badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.products.count];
    
    NSDecimalNumber *subtotal = [self.products valueForKeyPath:@"@sum.self.price"];
    NSDecimalNumber *shipping = [NSDecimalNumber zero];
    NSDecimalNumber *total = [subtotal decimalNumberByAdding:shipping];
    
    self.checkoutButton.enabled = self.shipping != nil && total.doubleValue > 0 && self.amount.doubleValue > 0 && self.currency.length > 0;
    self.checkoutButton.backgroundColor = self.checkoutButton.enabled ? [AWXTheme sharedTheme].tintColor : [UIColor colorNamed:@"Line Color"];
    
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
    [SVProgressHUD show];
    
    __weak __typeof(self)weakSelf = self;
    dispatch_group_t group = dispatch_group_create();
    __block NSError *_error;
    __block AWXPaymentIntent *_paymentIntent;
    __block NSString *_customerSecret;
    
    NSMutableDictionary *parameters = [@{@"amount": self.amount,
                                         @"currency": self.currency,
                                         @"merchant_order_id": NSUUID.UUID.UUIDString,
                                         @"request_id": NSUUID.UUID.UUIDString,
                                         @"customer_id": customerId,
                                         @"metadata": @{@"id": @1},
                                         @"return_url": @"airwallexcheckout://com.airwallex.paymentacceptance",
                                         @"order": @{
                                                 @"products": @[@{
                                                                    @"type": @"Free engraving",
                                                                    @"code": @"123",
                                                                    @"name": @"AirPods Pro",
                                                                    @"sku": @"piece",
                                                                    @"quantity": @1,
                                                                    @"unit_price": @399.0,
                                                                    @"desc": @"Buy AirPods Pro, per month with trade-in",
                                                                    @"url": @"www.aircross.com"
                                                 }, @{
                                                                    @"type": @"White",
                                                                    @"code": @"123",
                                                                    @"name": @"HomePod",
                                                                    @"sku": @"piece",
                                                                    @"quantity": @1,
                                                                    @"unit_price": @469.0,
                                                                    @"desc": @"Buy HomePod, per month with trade-in",
                                                                    @"url": @"www.aircross.com"
                                                 }],
                                                 @"shipping": @{
                                                         @"first_name": @"Verify",
                                                         @"last_name": @"Doe",
                                                         @"phone_number": @"13800000000",
                                                         @"address": @{
                                                                 @"country_code": @"CN",
                                                                 @"state": @"Shanghai",
                                                                 @"city": @"Shanghai",
                                                                 @"street": @"Pudong District",
                                                                 @"postcode": @"100000"
                                                         }
                                                 },
                                                 @"type": @"physical_goods"
                                         }} mutableCopy];
    
    
    if ([Airwallex checkoutMode] != AirwallexCheckoutRecurringMode) {
        dispatch_group_enter(group);
        [[APIClient sharedClient] createPaymentIntentWithParameters:parameters
                                                  completionHandler:^(AWXPaymentIntent * _Nullable paymentIntent, NSError * _Nullable error) {
            if (error) {
                _error = error;
                dispatch_group_leave(group);
                return;
            }

            _paymentIntent = paymentIntent;
            dispatch_group_leave(group);
        }];
    }

    dispatch_group_enter(group);
    [[APIClient sharedClient] createCustomerSecretWithId:customerId completionHandler:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        if (error) {
            _error = error;
            dispatch_group_leave(group);
            return;
        }
        
        _customerSecret = result[@"client_secret"];
        dispatch_group_leave(group);
        
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (_error) {
            [SVProgressHUD showErrorWithStatus:_error.localizedDescription];
            return;
        }
        
        [SVProgressHUD dismiss];
        [AWXAPIClientConfiguration sharedConfiguration].baseURL = [APIClient sharedClient].paymentBaseURL;
        if (_paymentIntent) {
            // Step1: Setup client secret
            [AWXAPIClientConfiguration sharedConfiguration].clientSecret = _paymentIntent.clientSecret;
        }
        if (_customerSecret) {
            // Step2: Setup customer secret
            [AWXCustomerAPIClientConfiguration sharedConfiguration].clientSecret = _customerSecret;
            if (!_paymentIntent) {
                [AWXAPIClientConfiguration sharedConfiguration].clientSecret = _customerSecret;
            }
            // Step3: Show payment flow
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf showPaymentFlowWithPaymentIntent:_paymentIntent];
        }
    });
}

#pragma mark - Show Payment Method List

- (void)showPaymentFlowWithPaymentIntent:(AWXPaymentIntent *)paymentIntent
{
    NSString *customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCachedCustomerID];
    NSString *clientSecret = [AWXAPIClientConfiguration sharedConfiguration].clientSecret;
    if (!paymentIntent) {
        AWXPaymentIntent *intent = AWXPaymentIntent.new;
        intent.customerId   = customerId;
        intent.currency     = self.currency;
        intent.amount       = self.amount;
        intent.clientSecret = clientSecret;
        paymentIntent = intent;
    }
    self.paymentIntent = paymentIntent;
    
    AWXUIContext *context = [AWXUIContext sharedContext];
    context.delegate = self;
    context.hostViewController = self;
    context.paymentIntent = paymentIntent;
    context.shipping = self.shipping;
    [context presentPaymentFlow];
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
        ShippingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShippingCell" forIndexPath:indexPath];
        cell.shipping = self.shipping;
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
    __weak __typeof(self)weakSelf = self;
    cell.handler = ^(Product *product) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.products removeObject:product];
        [strongSelf reloadData];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        AWXShippingViewController *controller = [AWXUIContext shippingViewController];
        controller.delegate = self;
        controller.shipping = self.shipping;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - AWXShippingViewControllerDelegate

- (void)shippingViewController:(AWXShippingViewController *)controller didEditShipping:(AWXPlaceDetails *)shipping
{
    [controller.navigationController popViewControllerAnimated:YES];
    self.shipping = shipping;
    [self reloadData];
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

#pragma mark - AWXPaymentResultDelegate

- (void)paymentViewController:(UIViewController *)controller didFinishWithStatus:(AWXPaymentStatus)status error:(nullable NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
        NSString *message = error.localizedDescription;
        if (status == AWXPaymentStatusSuccess) {
            message = @"Pay successfully";
        }
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

- (void)paymentViewController:(UIViewController *)controller nextActionWithWeChatPaySDK:(AWXWeChatPaySDKResponse *)response
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    /**
     To mock the wechat payment flow, we use an url to call instead wechat callback.
     */
    NSURL *url = [NSURL URLWithString:response.prepayId];
    if (url.scheme && url.host) {
        [SVProgressHUD show];
        
        __weak __typeof(self)weakSelf = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                return;
            }
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
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

- (void)paymentViewController:(UIViewController *)controller nextActionWithAlipayURL:(NSURL *)url
{
    [controller dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.message = url.absoluteString;
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        [UIPasteboard.generalPasteboard setString:url.absoluteString];
    }];
}

#pragma mark - Check Payment Intent Status

- (void)checkPaymentIntentStatusWithCompletion:(void (^)(BOOL success))completionHandler
{
    AWXRetrievePaymentIntentRequest *request = [[AWXRetrievePaymentIntentRequest alloc] init];
    request.intentId = self.paymentIntent.Id;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        
        AWXGetPaymentIntentResponse *result = (AWXGetPaymentIntentResponse *)response;
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
