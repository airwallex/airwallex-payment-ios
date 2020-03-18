//
//  AWPaymentMethodListViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentMethodListViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AWCardViewController.h"
#import "AWPaymentViewController.h"
#import "AWWidgets.h"
#import "AWTheme.h"
#import "AWUtils.h"
#import "AWConstants.h"
#import "AWPaymentMethod.h"
#import "AWPaymentConfiguration.h"
#import "AWAPIClient.h"
#import "AWPaymentMethodRequest.h"
#import "AWPaymentMethodResponse.h"
#import "AWPaymentMethodCell.h"
#import "AWPaymentIntentRequest.h"
#import "AWPaymentIntentResponse.h"
#import "AWPaymentMethodOptions.h"

static NSString * FormatPaymentMethodTypeString(NSString *type)
{
    if ([type isEqualToString:AWWechatpay]) {
        return @"WeChat pay";
    }
    return nil;
}

@interface AWPaymentMethodListViewController () <UITableViewDataSource, UITableViewDelegate, AWCardViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButtonItem;

@property (strong, nonatomic) NSArray *paymentMethods;
@property (strong, nonatomic, nullable) AWPaymentMethod *paymentMethod;

@end

@implementation AWPaymentMethodListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.closeBarButtonItem.image = [[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"confirmPayment"]) {
        AWPaymentViewController *controller = (AWPaymentViewController *)segue.destinationViewController;
        controller.paymentMethod = self.paymentMethod;
    } else if ([segue.identifier isEqualToString:@"addCard"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWCardViewController *controller = (AWCardViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.sameAsShipping = YES;
    }
}

- (NSArray *)presetCVC:(NSArray *)cards
{
    for (AWPaymentMethod *method in cards) {
        if (method.Id) {
            NSString *value = [[AWPaymentConfiguration sharedConfiguration] cacheWithKey:method.Id];
            if (value) {
                method.card.cvc = value;
            }
        }
    }
    return cards;
}

- (NSArray *)section0
{
    AWPaymentMethod *wechatpay = [AWPaymentMethod new];
    wechatpay.type = AWWechatpay;
    AWWechatPay *pay = [AWWechatPay new];
    pay.flow = @"inapp";
    wechatpay.wechatpay = pay;
    return @[wechatpay];
}

- (void)reloadData
{
    if ([AWPaymentConfiguration sharedConfiguration].customerId == nil) {
        self.paymentMethods = @[self.section0, @[]];
        [self.tableView reloadData];
        return;
    }

    [SVProgressHUD show];
    AWAPIClient *client = [AWAPIClient new];
    AWGetPaymentMethodsRequest *request = [AWGetPaymentMethodsRequest new];
    request.customerId = [AWPaymentConfiguration sharedConfiguration].customerId;
    __weak typeof(self) weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
            [strongSelf presentViewController:controller animated:YES completion:nil];
            return;
        }

        AWGetPaymentMethodsResponse *result = (AWGetPaymentMethodsResponse *)response;
        NSArray *cards = [result.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            AWPaymentMethod *obj = (AWPaymentMethod *)evaluatedObject;
            return [obj.type isEqualToString:@"card"];
        }]];
        cards = [strongSelf presetCVC:cards];

        strongSelf.paymentMethods = @[strongSelf.section0, cards];
        [strongSelf.tableView reloadData];
    }];
}

- (void)newPressed:(id)sender
{
    [self performSegueWithIdentifier:@"addCard" sender:nil];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.paymentMethods.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = self.paymentMethods[section];
    if (section == 1) {
        return MAX(items.count, 1);
    }
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 9;
    }
    return 14;
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
    if (section == 1 && [AWPaymentConfiguration sharedConfiguration].customerId != nil) {
        return 60;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 && [AWPaymentConfiguration sharedConfiguration].customerId != nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 56)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(16, 8, CGRectGetWidth(self.view.bounds) - 32, 44);
        button.layer.cornerRadius = 6;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [AWTheme defaultTheme].lineColor.CGColor;
        button.layer.masksToBounds = YES;
        [button setTitle:@"Enter a new card" forState:UIControlStateNormal];
        [button setTitleColor:[AWTheme defaultTheme].purpleColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:AWFontNameCircularStdBold size:14];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(newPressed:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        return view;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = self.paymentMethods[indexPath.section];
    if (indexPath.section == 1) {
        if (items.count == 0) {
            AWNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWNoCardCell" forIndexPath:indexPath];
            cell.isLastCell = indexPath.item == [tableView numberOfRowsInSection:indexPath.section] - 1;
            return cell;
        }
    }

    AWPaymentMethod *method = items[indexPath.row];
    AWPaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWPaymentMethodCell" forIndexPath:indexPath];
    if ([method.type isEqualToString:AWWechatpay]) {
        cell.logoImageView.image = [UIImage imageNamed:@"wc" inBundle:[NSBundle resourceBundle]];
        cell.titleLabel.text = FormatPaymentMethodTypeString(method.type);
    } else {
        cell.logoImageView.image = [UIImage imageNamed:method.card.brand inBundle:[NSBundle resourceBundle]];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ •••• %@", method.card.brand.capitalizedString, method.card.last4];
    }

    if ([self.paymentMethod.type isEqualToString:AWWechatpay]) {
        if ([method.type isEqualToString:self.paymentMethod.type]) {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    } else if (method.Id && [method.Id isEqualToString:self.paymentMethod.Id]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    cell.isLastCell = indexPath.item == [tableView numberOfRowsInSection:indexPath.section] - 1;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = self.paymentMethods[indexPath.section];
    if (indexPath.section == 1 && items.count == 0) {
        return;
    }

    AWPaymentMethod *method = items[indexPath.row];
    self.paymentMethod = method;

    if ([self.paymentMethod.type isEqualToString:AWWechatpay]) {
        // Confirm payment with wechat type directly
        [self confirmPaymentIntentWithPaymentMethod:self.paymentMethod];
        return;
    } else if (self.paymentMethod.card.cvc) {
        // Confirm payment with card cvc directly
        [self confirmPaymentIntentWithPaymentMethod:self.paymentMethod];
        return;
    }

    // No cvc provided and go to enter cvc in payment detail page
    [self performSegueWithIdentifier:@"confirmPayment" sender:nil];
}

#pragma mark - AWCardViewControllerDelegate

- (void)cardViewController:(AWCardViewController *)controller didCreatePaymentMethod:(nonnull AWPaymentMethod *)paymentMethod
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self reloadData];
}

#pragma mark - Confirm Payment Intent with Payment Method

- (void)confirmPaymentIntentWithPaymentMethod:(AWPaymentMethod *)paymentMethod
{
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
        __strong typeof(self) strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        [strongSelf dismissViewControllerAnimated:YES completion:^{
            id <AWPaymentResultDelegate> delegate = [AWPaymentConfiguration sharedConfiguration].delegate;
            if (error) {
                [delegate paymentDidFinishWithStatus:AWPaymentStatusError error:error];
                return;
            }

            AWConfirmPaymentIntentResponse *result = (AWConfirmPaymentIntentResponse *)response;
            if ([result.status isEqualToString:@"SUCCEEDED"]) {
                [delegate paymentDidFinishWithStatus:AWPaymentStatusSuccess error:error];
                return;
            }

            if (!result.nextAction) {
                [delegate paymentDidFinishWithStatus:AWPaymentStatusSuccess error:error];
                return;
            }

            if ([result.nextAction.type isEqualToString:@"call_sdk"]) {
                [delegate paymentWithWechatPaySDK:result.nextAction.wechatResponse];
            }
        }];
    }];
}

@end
