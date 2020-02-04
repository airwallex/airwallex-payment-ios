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
#import "CardViewController.h"

@interface PaymentListViewController () <UITableViewDataSource, UITableViewDelegate, CardViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (nonatomic, strong) NSArray *paymentMethods;

@end

@implementation PaymentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.saveBarButtonItem.enabled = self.paymentMethod != nil;
    [self reload];
}

- (void)reload
{
    AWAPIClient *client = [AWAPIClient new];
    AWGetPaymentMethodsRequest *request = [AWGetPaymentMethodsRequest new];
    __weak typeof(self) weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (response && [response isKindOfClass:[AWGetPaymentMethodsResponse class]]) {
            AWGetPaymentMethodsResponse *result = (AWGetPaymentMethodsResponse *)response;
            NSArray *section0 = [result.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                AWPaymentMethod *obj = (AWPaymentMethod *)evaluatedObject;
                return [obj.type isEqualToString:@"wechatpay"];
            }]];
            NSArray *section1 = [result.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                AWPaymentMethod *obj = (AWPaymentMethod *)evaluatedObject;
                return [obj.type isEqualToString:@"card"];
            }]];

            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.paymentMethods = @[section0, section1];
            [strongSelf.tableView reloadData];
        }
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
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoCardCell" forIndexPath:indexPath];
            return cell;
        }
    }

    AWPaymentMethod *method = items[indexPath.row];
    PaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentMethodCell" forIndexPath:indexPath];
    if ([method.type isEqualToString:@"wechatpay"]) {
        cell.logoImageView.image = [UIImage imageNamed:@"wc"];
        cell.titleLabel.text = @"WeChat pay";
    } else {
        cell.logoImageView.image = [UIImage imageNamed:method.card.brand];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ •••• %@", method.card.brand.capitalizedString, method.card.last4];
    }
    if ([method.Id isEqualToString:self.paymentMethod.Id]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
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
    self.saveBarButtonItem.enabled = self.paymentMethod != nil;
}

- (void)cardViewController:(CardViewController *)controller didSelectCard:(AWCard *)card
{
//    AWPaymentMethod *method = [AWPaymentMethod new];
//    method.type = @"card";
//    method.card = card;
//
//    self.paymentMethods = @[@[self.weChatPay], @[method]];
//    [self.tableView reloadData];
}

@end
