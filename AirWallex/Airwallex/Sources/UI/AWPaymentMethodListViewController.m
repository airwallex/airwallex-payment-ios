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
#import "AWAPIClient.h"
#import "AWPaymentMethodRequest.h"
#import "AWPaymentMethodResponse.h"
#import "AWPaymentMethodCell.h"
#import "AWPaymentIntentRequest.h"
#import "AWPaymentIntentResponse.h"
#import "AWPaymentMethodOptions.h"
#import "AWPaymentIntent.h"

static NSString * FormatPaymentMethodTypeString(NSString *type)
{
    if ([type isEqualToString:AWWeChatPayKey]) {
        return @"WeChat pay";
    }
    return nil;
}

@interface AWPaymentMethodListViewController () <UITableViewDataSource, UITableViewDelegate, AWCardViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButtonItem;

@property (strong, nonatomic) NSArray <NSArray <AWPaymentMethod *> *> *paymentMethods;

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
        controller.delegate = [AWUIContext sharedContext].delegate;
        controller.paymentIntent = [AWUIContext sharedContext].paymentIntent;
        controller.paymentMethod = self.paymentMethod;
        controller.isFlow = self.isFlow;
    } else if ([segue.identifier isEqualToString:@"addCard"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWCardViewController *controller = (AWCardViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.sameAsShipping = YES;
        controller.customerId = self.customerId;
        controller.shipping = self.shipping;
        controller.isFlow = self.isFlow;
    }
}

- (NSArray <AWPaymentMethod *> *)section0
{
    AWPaymentMethod *wechatpay = [AWPaymentMethod new];
    wechatpay.type = AWWeChatPayKey;
    AWWechatPay *pay = [AWWechatPay new];
    pay.flow = @"inapp";
    wechatpay.wechatpay = pay;
    return @[wechatpay];
}

- (void)reloadData
{
    if (self.customerId == nil) {
        self.paymentMethods = @[self.section0, @[]];
        [self.tableView reloadData];
        return;
    }

    [SVProgressHUD show];
    AWAPIClient *client = [AWAPIClient new];
    AWGetPaymentMethodsRequest *request = [AWGetPaymentMethodsRequest new];
    request.customerId = self.customerId;
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
            return [obj.type isEqualToString:AWCardKey];
        }]];

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
    NSArray <AWPaymentMethod *> *items = self.paymentMethods[section];
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
    if (section == 1 && self.customerId != nil) {
        return 60;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 && self.customerId != nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 56)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(16, 8, CGRectGetWidth(self.view.bounds) - 32, 44);
        button.layer.cornerRadius = 6;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [AWTheme sharedTheme].lineColor.CGColor;
        button.layer.masksToBounds = YES;
        [button setTitle:@"Enter a new card" forState:UIControlStateNormal];
        [button setTitleColor:[AWTheme sharedTheme].purpleColor forState:UIControlStateNormal];
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
    NSArray <AWPaymentMethod *> *items = self.paymentMethods[indexPath.section];
    if (indexPath.section == 1) {
        if (items.count == 0) {
            AWNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWNoCardCell" forIndexPath:indexPath];
            cell.isLastCell = indexPath.item == [tableView numberOfRowsInSection:indexPath.section] - 1;
            return cell;
        }
    }

    AWPaymentMethod *method = items[indexPath.row];
    AWPaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWPaymentMethodCell" forIndexPath:indexPath];
    if ([method.type isEqualToString:AWWeChatPayKey]) {
        cell.logoImageView.image = [UIImage imageNamed:@"wc" inBundle:[NSBundle resourceBundle]];
        cell.titleLabel.text = FormatPaymentMethodTypeString(method.type);
    } else {
        cell.logoImageView.image = [UIImage imageNamed:method.card.brand inBundle:[NSBundle resourceBundle]];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ •••• %@", method.card.brand.capitalizedString, method.card.last4];
    }

    if ([self.paymentMethod.type isEqualToString:AWWeChatPayKey]) {
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

    if (!self.isFlow) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(paymentMethodListViewController:didSelectPaymentMethod:)]) {
            [self.delegate paymentMethodListViewController:self didSelectPaymentMethod:method];
        }
        return;
    }

    NSString *cvc = [[NSUserDefaults awUserDefaults] stringForKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
    if (cvc) {
        self.paymentMethod.card.cvc = cvc;
    }

    // Confirm directly (Only be valid for payment flow)
    if ([self.paymentMethod.type isEqualToString:AWWeChatPayKey]) {
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

- (void)cardViewController:(AWCardViewController *)controller didCreatePaymentMethod:(AWPaymentMethod *)paymentMethod
{
    self.paymentMethod = paymentMethod;
    [self reloadData];
    [controller dismissViewControllerAnimated:YES completion:^{
        if (self.isFlow) {
            [self performSegueWithIdentifier:@"confirmPayment" sender:nil];
        }
    }];
}

#pragma mark - Confirm Payment Intent with Payment Method (Only be valid for payment flow)

- (void)confirmPaymentIntentWithPaymentMethod:(AWPaymentMethod *)paymentMethod
{
    AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
    AWConfirmPaymentIntentRequest *request = [AWConfirmPaymentIntentRequest new];
    request.intentId = [AWUIContext sharedContext].paymentIntent.Id;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;
    AWPaymentMethodOptions *options = [AWPaymentMethodOptions new];
    options.autoCapture = YES;
    options.threeDsOption = NO;
    request.options = options;
    request.paymentMethod = paymentMethod;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];

        __strong __typeof(weakSelf)strongSelf = weakSelf;
        id <AWPaymentResultDelegate> delegate = [AWUIContext sharedContext].delegate;
        if (error) {
            [delegate paymentViewController:strongSelf didFinishWithStatus:AWPaymentStatusError error:error];
            return;
        }

        AWConfirmPaymentIntentResponse *result = (AWConfirmPaymentIntentResponse *)response;
        if ([result.status isEqualToString:@"SUCCEEDED"]) {
            [delegate paymentViewController:strongSelf didFinishWithStatus:AWPaymentStatusSuccess error:error];
            return;
        }

        if (!result.nextAction) {
            [delegate paymentViewController:strongSelf didFinishWithStatus:AWPaymentStatusSuccess error:error];
            return;
        }

        if (result.nextAction.wechatResponse) {
            [delegate paymentViewController:strongSelf nextActionWithWechatPaySDK:result.nextAction.wechatResponse];
        }
    }];
}

@end
