//
//  AWPaymentListViewController.m
//  Examples
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentListViewController.h"
#import "AWCardViewController.h"
#import "AWWidgets.h"
#import "AWTheme.h"
#import "AWUtils.h"
#import "AWPaymentMethod.h"
#import "AWPaymentConfiguration.h"
#import "AWAPIClient.h"
#import "AWPaymentMethodRequest.h"
#import "AWPaymentMethodResponse.h"
#import "AWPaymentMethodCell.h"

static NSString * FormatPaymentMethodTypeString(NSString *type)
{
    if ([type isEqualToString:AWWechatpay]) {
        return @"WeChat pay";
    }
    return nil;
}

@interface AWPaymentListViewController () <UITableViewDataSource, UITableViewDelegate, AWCardViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet AWHUD *HUD;
@property (strong, nonatomic) NSArray *paymentMethods;

@end

@implementation AWPaymentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
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

- (void)reloadData
{
    [self.HUD show];
    AWAPIClient *client = [AWAPIClient new];
    AWGetPaymentMethodsRequest *request = [AWGetPaymentMethodsRequest new];
    request.customerId = [AWPaymentConfiguration sharedConfiguration].customerId;
    __weak typeof(self) weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self.HUD showErrorWithStatus:error.localizedDescription];
            return;
        }

        __strong typeof(self) strongSelf = weakSelf;
        AWGetPaymentMethodsResponse *result = (AWGetPaymentMethodsResponse *)response;

        // Section 0
        NSArray *cards = [result.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            AWPaymentMethod *obj = (AWPaymentMethod *)evaluatedObject;
            return [obj.type isEqualToString:@"card"];
        }]];
        cards = [strongSelf presetCVC:cards];

        // Section 1
        AWPaymentMethod *wechatpay = [AWPaymentMethod new];
        wechatpay.type = AWWechatpay;
        AWWechatPay *pay = [AWWechatPay new];
        pay.flow = @"inapp";
        wechatpay.wechatpay = pay;
        NSArray *pays = @[wechatpay];

        strongSelf.paymentMethods = @[cards, pays];
        [strongSelf.tableView reloadData];
        [self.HUD dismiss];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addCard"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWCardViewController *controller = (AWCardViewController *)navigationController.topViewController;
        controller.delegate = self;
    }
}

- (void)newPressed:(id)sender
{
    [self performSegueWithIdentifier:@"addCard" sender:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.paymentMethods.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = self.paymentMethods[section];
    if (section == 0) {
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
    if (section == 0) {
        return 60;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 56)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(16, 8, CGRectGetWidth(self.view.bounds) - 32, 44);
        button.layer.cornerRadius = 6;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [AWTheme defaultTheme].lineColor.CGColor;
        button.layer.masksToBounds = YES;
        [button setTitle:@"Enter a new card" forState:UIControlStateNormal];
        [button setTitleColor:[AWTheme defaultTheme].purpleColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"CircularStd-Bold" size:14];
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
    if (indexPath.section == 0) {
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
    if (indexPath.section == 0 && items.count == 0) {
        return;
    }

    AWPaymentMethod *method = items[indexPath.row];
    self.paymentMethod = method;

    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentListViewController:didSelectMethod:)]) {
        [self.delegate paymentListViewController:self didSelectMethod:self.paymentMethod];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cardViewController:(AWCardViewController *)controller didCreatePaymentMethod:(nonnull AWPaymentMethod *)paymentMethod
{
    [self reloadData];
}

@end
