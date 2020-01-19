//
//  PaymentListViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "PaymentListViewController.h"
#import <Airwallex/Airwallex.h>
#import "PaymentMethodCell.h"

@interface PaymentListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *paymentMethods;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;

@end

@implementation PaymentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    AWPaymentMethod *weChatPay = [AWPaymentMethod new];
    weChatPay.type = @"wechatpay";
    AWWechatPay *pay = [AWWechatPay new];
    pay.flow = @"inapp";
    weChatPay.wechatpay = pay;

    self.paymentMethods = @[@[weChatPay], @[]];
    self.saveBarButtonItem.enabled = self.paymentMethod != nil;
}

- (IBAction)savePressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentListViewController:didSelectMethod:)]) {
        [self.delegate paymentListViewController:self didSelectMethod:self.paymentMethod];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addNewCard:(id)sender
{
    NSLog(@"Add new card");
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
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoCardCell" forIndexPath:indexPath];
            return cell;
        }
    }

    AWPaymentMethod *method = items[indexPath.row];
    PaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentMethodCell" forIndexPath:indexPath];
    if ([method.type isEqualToString:@"wechatpay"]) {
        cell.logoImageView.image = [UIImage imageNamed:@"wc"];
        cell.titleLabel.text = @"WeChat pay";
        if ([method.type isEqualToString:self.paymentMethod.type]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = self.paymentMethods[indexPath.section];
    if (indexPath.section == 1 && items.count == 0) {
        return;
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    AWPaymentMethod *method = items[indexPath.row];
    self.paymentMethod = method;
    self.saveBarButtonItem.enabled = self.paymentMethod != nil;
}

@end
