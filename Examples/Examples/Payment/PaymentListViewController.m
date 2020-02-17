//
//  PaymentListViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "PaymentListViewController.h"
#import <Airwallex/Airwallex.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "PaymentMethodCell.h"
#import "CardViewController.h"
#import "UIButton+Utils.h"

static NSString * FormatPaymentMethodTypeString(NSString *type)
{
    if ([type isEqualToString:AWWechatpay]) {
        return @"WeChat pay";
    }
    return nil;
}

@interface PaymentListViewController () <UITableViewDataSource, UITableViewDelegate, CardViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) NSArray *paymentMethods;

@end

@implementation PaymentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.saveButton setImageAndTitleHorizontalAlignmentCenter:8];
    [self reloadData];
}

- (void)reloadData
{
    self.saveBarButtonItem.enabled = self.paymentMethod != nil;
    [SVProgressHUD show];
    AWAPIClient *client = [AWAPIClient new];
    AWGetPaymentMethodsRequest *request = [AWGetPaymentMethodsRequest new];
    __weak typeof(self) weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        
        AWGetPaymentMethodsResponse *result = (AWGetPaymentMethodsResponse *)response;
        AWPaymentMethod *wechatpay = [AWPaymentMethod new];
        wechatpay.type = AWWechatpay;
        AWWechatPay *pay = [AWWechatPay new];
        pay.flow = @"inapp";
        wechatpay.wechatpay = pay;
        NSArray *section0 = @[wechatpay];
        NSArray *section1 = [result.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            AWPaymentMethod *obj = (AWPaymentMethod *)evaluatedObject;
            return [obj.type isEqualToString:@"card"];
        }]];

        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.paymentMethods = @[section0, section1];
        [strongSelf.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addCard"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        CardViewController *controller = (CardViewController *)navigationController.topViewController;
        controller.delegate = self;
    }
}

- (IBAction)savePressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentListViewController:didSelectMethod:)]) {
        [self.delegate paymentListViewController:self didSelectMethod:self.paymentMethod];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

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
    NSArray *items = self.paymentMethods[indexPath.section];
    if (indexPath.section == 1) {
        if (items.count == 0) {
            NoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoCardCell" forIndexPath:indexPath];
            cell.isLastCell = indexPath.item == [tableView numberOfRowsInSection:indexPath.section] - 1;
            return cell;
        }
    }

    AWPaymentMethod *method = items[indexPath.row];
    PaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentMethodCell" forIndexPath:indexPath];
    if ([method.type isEqualToString:AWWechatpay]) {
        cell.logoImageView.image = [UIImage imageNamed:@"wc"];
        cell.titleLabel.text = FormatPaymentMethodTypeString(method.type);
    } else {
        cell.logoImageView.image = [UIImage imageNamed:method.card.brand];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ •••• %@", method.card.brand.capitalizedString, method.card.last4];
    }
    if ([method.Id isEqualToString:self.paymentMethod.Id]) {
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
    [self reloadData];
}

- (void)cardViewController:(CardViewController *)controller didCreatePaymentMethod:(nonnull AWPaymentMethod *)paymentMethod
{
    [self reloadData];
}

@end
