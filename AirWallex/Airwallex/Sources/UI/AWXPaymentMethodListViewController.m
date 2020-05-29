//
//  AWXPaymentMethodListViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodListViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AWXCardViewController.h"
#import "AWXPaymentViewController.h"
#import "AWXWidgets.h"
#import "AWXTheme.h"
#import "AWXUtils.h"
#import "AWXConstants.h"
#import "AWXPaymentMethod.h"
#import "AWXDevice.h"
#import "AWXAPIClient.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXPaymentMethodCell.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentIntent.h"
#import "AWXThreeDSService.h"
#import "AWXSecurityService.h"

static NSString * FormatPaymentMethodTypeString(NSString *type)
{
    if ([type isEqualToString:AWXWeChatPayKey]) {
        return @"WeChat pay";
    }
    return nil;
}

@interface AWXPaymentMethodListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, AWXCardViewControllerDelegate, AWXThreeDSServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButtonItem;

@property (strong, nonatomic) NSArray <NSArray <AWXPaymentMethod *> *> *paymentMethods;
@property (strong, nonatomic) NSMutableArray <AWXPaymentMethod *> *cards;
@property (nonatomic) BOOL canLoadMore;
@property (nonatomic) NSInteger nextPageNum;
@property (strong, nonatomic) AWXThreeDSService *service;
@property (strong, nonatomic) AWXDevice *device;

@end

@implementation AWXPaymentMethodListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.closeBarButtonItem.image = [[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"confirmPayment"]) {
        AWXPaymentViewController *controller = (AWXPaymentViewController *)segue.destinationViewController;
        controller.delegate = [AWXUIContext sharedContext].delegate;
        controller.paymentIntent = [AWXUIContext sharedContext].paymentIntent;
        controller.paymentMethod = self.paymentMethod;
        controller.isFlow = self.isFlow;
    } else if ([segue.identifier isEqualToString:@"addCard"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWXCardViewController *controller = (AWXCardViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.sameAsShipping = YES;
        controller.customerId = self.customerId;
        controller.shipping = self.shipping;
        controller.isFlow = self.isFlow;
    }
}

- (NSArray <AWXPaymentMethod *> *)section0
{
    AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
    paymentMethod.type = AWXWeChatPayKey;
    AWXWeChatPay *pay = [AWXWeChatPay new];
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
    
    AWXGetPaymentMethodsRequest *request = [AWXGetPaymentMethodsRequest new];
    request.customerId = self.customerId;
    request.pageNum = pageNum;
    request.methodType = AWXCardKey;
    
    __weak __typeof(self)weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXCustomerAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        if (error) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
            [strongSelf presentViewController:controller animated:YES completion:nil];
            return;
        }
        
        AWXGetPaymentMethodsResponse *result = (AWXGetPaymentMethodsResponse *)response;
        strongSelf.canLoadMore = result.hasMore;
        NSArray *cards = [result.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            AWXPaymentMethod *obj = (AWXPaymentMethod *)evaluatedObject;
            return [obj.type isEqualToString:AWXCardKey];
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

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.paymentMethods.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray <AWXPaymentMethod *> *items = self.paymentMethods[section];
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
        button.layer.borderColor = [AWXTheme sharedTheme].lineColor.CGColor;
        button.layer.masksToBounds = YES;
        [button setTitle:@"Enter a new card" forState:UIControlStateNormal];
        [button setTitleColor:[AWXTheme sharedTheme].purpleColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:14];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(newPressed:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        return view;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray <AWXPaymentMethod *> *items = self.paymentMethods[indexPath.section];
    if (indexPath.section == 1) {
        if (items.count == 0) {
            AWXNoCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWXNoCardCell" forIndexPath:indexPath];
            cell.isLastCell = indexPath.item == [tableView numberOfRowsInSection:indexPath.section] - 1;
            return cell;
        }
    }
    
    AWXPaymentMethod *method = items[indexPath.row];
    AWXPaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWXPaymentMethodCell" forIndexPath:indexPath];
    if ([method.type isEqualToString:AWXWeChatPayKey]) {
        cell.logoImageView.image = [UIImage imageNamed:@"wc" inBundle:[NSBundle resourceBundle]];
        cell.titleLabel.text = FormatPaymentMethodTypeString(method.type);
    } else {
        cell.logoImageView.image = [UIImage imageNamed:method.card.brand inBundle:[NSBundle resourceBundle]];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ •••• %@", method.card.brand.capitalizedString, method.card.last4];
    }
    
    if ([self.paymentMethod.type isEqualToString:AWXWeChatPayKey]) {
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
    
    AWXPaymentMethod *method = items[indexPath.row];
    self.paymentMethod = method;
    
    if (!self.isFlow) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(paymentMethodListViewController:didSelectPaymentMethod:)]) {
            [self.delegate paymentMethodListViewController:self didSelectPaymentMethod:method];
        }
        return;
    }
    
    NSString *cvc = [[NSUserDefaults awxUserDefaults] stringForKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
    if (cvc) {
        self.paymentMethod.card.cvc = cvc;
    }
    
    // Confirm directly (Only be valid for payment flow)
    if ([self.paymentMethod.type isEqualToString:AWXWeChatPayKey]) {
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

#pragma mark - AWXCardViewControllerDelegate

- (void)cardViewController:(AWXCardViewController *)controller didCreatePaymentMethod:(AWXPaymentMethod *)paymentMethod
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

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod
{
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD show];
    [[AWXSecurityService sharedService] doProfile:[AWXUIContext sharedContext].paymentIntent.Id completion:^(NSString * _Nonnull sessionId) {
        [SVProgressHUD dismiss];
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        AWXDevice *device = [AWXDevice new];
        device.deviceId = sessionId;
        [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device];
    }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod device:(AWXDevice *)device
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = [AWXUIContext sharedContext].paymentIntent.Id;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;

    if ([paymentMethod.type isEqualToString:AWXCardKey]) {
        AWXCardOptions *cardOptions = [AWXCardOptions new];
        cardOptions.autoCapture = YES;
        AWXThreeDs *threeDs = [AWXThreeDs new];
        threeDs.returnURL = AWXThreeDSReturnURL;
        cardOptions.threeDs = threeDs;

        AWXPaymentMethodOptions *options = [AWXPaymentMethodOptions new];
        options.cardOptions = cardOptions;
        request.options = options;
    }

    request.paymentMethod = paymentMethod;
    request.device = device;
    self.device = device;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)finishConfirmationWithResponse:(AWXConfirmPaymentIntentResponse *)response error:(nullable NSError *)error
{
    id <AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    if (error) {
        [[NSUserDefaults awxUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@:%@", kCachedCVC, self.paymentMethod.Id]];
        [[NSUserDefaults awxUserDefaults] synchronize];
        [delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusError error:error];
        return;
    }
    
    AWXConfirmPaymentIntentResponse *result = (AWXConfirmPaymentIntentResponse *)response;
    if ([response.status isEqualToString:@"SUCCEEDED"] || [response.status isEqualToString:@"REQUIRES_CAPTURE"]) {
        [delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        return;
    }
    
    if (!result.nextAction) {
        [delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        return;
    }
    
    if (result.nextAction.weChatPayResponse) {
        [delegate paymentViewController:self nextActionWithWeChatPaySDK:result.nextAction.weChatPayResponse];
    } else if (result.nextAction.redirectResponse) {
        AWXPaymentIntent *paymentIntent = [AWXUIContext sharedContext].paymentIntent;
        AWXThreeDSService *service = [AWXThreeDSService new];
        service.customerId = paymentIntent.customerId;
        service.intentId = paymentIntent.Id;
        service.paymentMethod = self.paymentMethod;
        service.device = self.device;
        service.presentingViewController = self;
        service.delegate = self;
        self.service = service;
        [service presentThreeDSFlowWithServerJwt:result.nextAction.redirectResponse.jwt];
    } else {
        [delegate paymentViewController:self
                         didFinishWithStatus:AWXPaymentStatusError
                                       error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported next action."}]];
    }
}

#pragma mark - AWXThreeDSServiceDelegate

- (void)threeDSService:(AWXThreeDSService *)service didFinishWithResponse:(AWXConfirmPaymentIntentResponse *)response error:(NSError *)error
{
    [self finishConfirmationWithResponse:response error:error];
}

@end
