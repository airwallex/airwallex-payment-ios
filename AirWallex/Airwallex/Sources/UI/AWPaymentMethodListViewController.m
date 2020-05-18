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
#import "AWDevice.h"
#import "AWAPIClient.h"
#import "AWPaymentMethodRequest.h"
#import "AWPaymentMethodResponse.h"
#import "AWPaymentMethodCell.h"
#import "AWPaymentIntentRequest.h"
#import "AWPaymentIntentResponse.h"
#import "AWPaymentMethodOptions.h"
#import "AWPaymentIntent.h"
#import "AW3DSService.h"
#import "AWSecurityService.h"

static NSString * FormatPaymentMethodTypeString(NSString *type)
{
    if ([type isEqualToString:AWWeChatPayKey]) {
        return @"WeChat pay";
    }
    return nil;
}

@interface AWPaymentMethodListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, AWCardViewControllerDelegate, AW3DSServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButtonItem;

@property (strong, nonatomic) NSArray <NSArray <AWPaymentMethod *> *> *paymentMethods;
@property (strong, nonatomic) NSMutableArray <AWPaymentMethod *> *cards;
@property (nonatomic) BOOL canLoadMore;
@property (nonatomic) NSInteger nextPageNum;
@property (strong, nonatomic, readonly) AW3DSService *service;

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
    AWPaymentMethod *paymentMethod = [AWPaymentMethod new];
    paymentMethod.type = AWWeChatPayKey;
    AWWeChatPay *pay = [AWWeChatPay new];
    paymentMethod.weChatPay = pay;
    return @[paymentMethod];
}

- (void)reloadData
{
    if (self.customerId == nil) {
        self.paymentMethods = @[self.section0, @[]];
        [self.tableView reloadData];
        return;
    }
    
    self.cards = [NSMutableArray array];
    [self loadDataFromPageNum:0];
}

- (void)loadDataFromPageNum:(NSInteger)pageNum
{
    [SVProgressHUD show];
    
    AWGetPaymentMethodsRequest *request = [AWGetPaymentMethodsRequest new];
    request.customerId = self.customerId;
    request.pageNum = pageNum;
    request.methodType = AWCardKey;
    
    __weak __typeof(self)weakSelf = self;
    AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
            [strongSelf presentViewController:controller animated:YES completion:nil];
            return;
        }
        
        AWGetPaymentMethodsResponse *result = (AWGetPaymentMethodsResponse *)response;
        strongSelf.canLoadMore = result.hasMore;
        NSArray *cards = [result.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            AWPaymentMethod *obj = (AWPaymentMethod *)evaluatedObject;
            return [obj.type isEqualToString:AWCardKey];
        }]];
        [strongSelf.cards addObjectsFromArray:cards];
        
        strongSelf.paymentMethods = @[strongSelf.section0, strongSelf.cards];
        [strongSelf.tableView reloadData];
        strongSelf.nextPageNum = pageNum + 1;
    }];
}

- (void)newPressed:(id)sender
{
    [self performSegueWithIdentifier:@"addCard" sender:nil];
}

- (AW3DSService *)service
{
    AWPaymentIntent *paymentIntent = [AWUIContext sharedContext].paymentIntent;
    AW3DSService *service = [AW3DSService new];
    service.customerId = paymentIntent.customerId;
    service.intentId = paymentIntent.Id;
    service.paymentMethod = self.paymentMethod;
    service.presentingViewController = self;
    service.delegate = self;
    return service;
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.canLoadMore) {
        return;
    }
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 0) {
        [self loadDataFromPageNum:self.nextPageNum];
    }
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
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD show];
    [[AWSecurityService sharedService] doProfile:[AWUIContext sharedContext].paymentIntent.Id completion:^(NSString * _Nonnull sessionId) {
        [SVProgressHUD dismiss];
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        AWDevice *device = [AWDevice new];
        device.deviceId = sessionId;
        [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device];
    }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWPaymentMethod *)paymentMethod device:(AWDevice *)device
{
    AWAPIClient *client = [[AWAPIClient alloc] initWithConfiguration:[AWAPIClientConfiguration sharedConfiguration]];
    AWConfirmPaymentIntentRequest *request = [AWConfirmPaymentIntentRequest new];
    request.intentId = [AWUIContext sharedContext].paymentIntent.Id;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;

    if ([paymentMethod.type isEqualToString:AWCardKey]) {
        AWCardOptions *cardOptions = [AWCardOptions new];
        cardOptions.autoCapture = YES;
        AWThreeDs *threeDs = [AWThreeDs new];
        threeDs.returnURL = AWThreeDSReturnURL;
        cardOptions.threeDs = threeDs;

        AWPaymentMethodOptions *options = [AWPaymentMethodOptions new];
        options.cardOptions = cardOptions;
        request.options = options;
    }

    request.paymentMethod = paymentMethod;
    request.device = device;
    
    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)finishConfirmationWithResponse:(AWConfirmPaymentIntentResponse *)response error:(nullable NSError *)error
{
    id <AWPaymentResultDelegate> delegate = [AWUIContext sharedContext].delegate;
    if (error) {
        [[NSUserDefaults awUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
        [[NSUserDefaults awUserDefaults] synchronize];
        [delegate paymentViewController:self didFinishWithStatus:AWPaymentStatusError error:error];
        return;
    }
    
    AWConfirmPaymentIntentResponse *result = (AWConfirmPaymentIntentResponse *)response;
    if ([result.status isEqualToString:@"SUCCEEDED"]) {
        [delegate paymentViewController:self didFinishWithStatus:AWPaymentStatusSuccess error:error];
        return;
    }
    
    if (!result.nextAction) {
        [delegate paymentViewController:self didFinishWithStatus:AWPaymentStatusSuccess error:error];
        return;
    }
    
    if (result.nextAction.weChatPayResponse) {
        [delegate paymentViewController:self nextActionWithWeChatPaySDK:result.nextAction.weChatPayResponse];
    } else if (result.nextAction.redirectResponse) {
        [self.service present3DSFlowWithRedirectResponse:result.nextAction.redirectResponse];
    }
}

#pragma mark - AW3DSServiceDelegate

- (void)threeDSServiceDidFailWithError:(NSError *)error
{

}

@end
