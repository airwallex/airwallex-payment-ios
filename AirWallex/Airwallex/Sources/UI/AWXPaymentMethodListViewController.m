//
//  AWXPaymentMethodListViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodListViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AWXDCCViewController.h"
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
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXTrackManager.h"


@interface AWXPaymentMethodListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, AWXCardViewControllerDelegate, AWXThreeDSServiceDelegate, AWXDCCViewControllerDelegate>

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
    self.closeBarButtonItem.image = [[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self reloadData];
    [self loadPaymentMethodTypes];
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
    } else if ([segue.identifier isEqualToString:@"showDCC"] && [sender isKindOfClass:[AWXConfirmPaymentIntentResponse class]]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWXDCCViewController *controller = (AWXDCCViewController *)navigationController.topViewController;
        controller.response = sender;
        controller.delegate = self;
    }
}

- (void) loadPaymentMethodTypes{
    AWXGetPaymentMethodsTypeRequest *request = [AWXGetPaymentMethodsTypeRequest new];
    request.active = self.customerId;
    request.pageNum = 0;
    request.pageSize = 200;
    request.transactionCurrency = _currency;
    
    __weak __typeof(self)weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXCustomerAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        if (response && !error) {
            AWXGetPaymentMethodsResponse *result = (AWXGetPaymentMethodsResponse *)response;
            
        }
    }];
}

- (NSArray <AWXPaymentMethod *> *)section0
{
    NSArray *supportedTypes = [Airwallex supportedNonCardTypes];
    NSMutableArray *paymentMethodTypes = [NSMutableArray array];
    for (NSString *type in self.availablePaymentMethodTypes) {
        if ([supportedTypes containsObject:type]) {
            AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
            paymentMethod.type = type;
            AWXNonCard *nonCard = [AWXNonCard new];
            paymentMethod.nonCard = nonCard;
            [paymentMethodTypes addObject:paymentMethod];
        }
    }
    return paymentMethodTypes;
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

- (void)loadMultipleDataFromPageNum:(NSInteger)pageNum
{
    if (![self.availablePaymentMethodTypes containsObject:AWXCardKey]) {
        self.paymentMethods = @[self.section0, self.cards];
        [self.tableView reloadData];
        return;
    }
    
    NSArray *cardTypes = @[@"visa", @"mastercard"];

    [SVProgressHUD show];
    dispatch_group_t group = dispatch_group_create();

    for (NSString *type in cardTypes) {
        dispatch_group_enter(group);

        AWXGetPaymentMethodsRequest *request = [AWXGetPaymentMethodsRequest new];
        request.customerId = self.customerId;
        request.pageNum = pageNum;
        request.methodType = AWXCardKey;
        request.cardType = type;
        
        __weak __typeof(self)weakSelf = self;
        AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXCustomerAPIClientConfiguration sharedConfiguration]];
        [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;

            if (response && !error) {
                AWXGetPaymentMethodsResponse *result = (AWXGetPaymentMethodsResponse *)response;
                strongSelf.canLoadMore = strongSelf.canLoadMore || result.hasMore;
                NSArray *cards = [result.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    AWXPaymentMethod *obj = (AWXPaymentMethod *)evaluatedObject;
                    return [cardTypes containsObject:obj.type];
                }]];
                [strongSelf.cards addObjectsFromArray:cards];
            }
            
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self.paymentMethods = @[self.section0, self.cards];
        [self.tableView reloadData];
        self.nextPageNum = pageNum + 1;
        [SVProgressHUD dismiss];
    });
}

- (void)loadDataFromPageNum:(NSInteger)pageNum
{
    if (![self.availablePaymentMethodTypes containsObject:AWXCardKey]) {
        self.paymentMethods = @[self.section0, self.cards];
        [self.tableView reloadData];
        return;
    }

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
        [strongSelf.cards addObjectsFromArray:result.items];
        
        strongSelf.paymentMethods = @[strongSelf.section0, strongSelf.cards];
        [strongSelf.tableView reloadData];
        strongSelf.nextPageNum = pageNum + 1;
    }];
}

- (void)newPressed:(id)sender
{
    [self performSegueWithIdentifier:@"addCard" sender:nil];
}

- (void)disableCard:(AWXPaymentMethod *)paymentMethod
{
    [SVProgressHUD show];
    
    AWXDisablePaymentMethodRequest *request = [AWXDisablePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethodId = paymentMethod.Id;
    
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
        
        [strongSelf reloadData];
    }];
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
        return MAX(items.count, [self.availablePaymentMethodTypes containsObject:AWXCardKey] ? 1 : 0);
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
    if (section == 1 && self.customerId != nil && [self.availablePaymentMethodTypes containsObject:AWXCardKey]) {
        return 60;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 && self.customerId != nil && [self.availablePaymentMethodTypes containsObject:AWXCardKey]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 56)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(16, 8, CGRectGetWidth(self.view.bounds) - 32, 44);
        button.layer.cornerRadius = 6;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [AWXTheme sharedTheme].lineColor.CGColor;
        button.layer.masksToBounds = YES;
        [button setTitle:@"Enter a new card" forState:UIControlStateNormal];
        [button setTitleColor:[AWXTheme sharedTheme].tintColor forState:UIControlStateNormal];
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
    if ([Airwallex.supportedNonCardTypes containsObject:method.type]) {
        cell.logoImageView.image = [UIImage imageNamed:PaymentMethodTypeLogo(method.type) inBundle:[NSBundle resourceBundle]];
        cell.titleLabel.text = FormatPaymentMethodTypeString(method.type);
    } else {
        cell.logoImageView.image = [UIImage imageNamed:method.card.brand inBundle:[NSBundle resourceBundle]];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ •••• %@", method.card.brand.capitalizedString, method.card.last4];
    }
    
    if ([Airwallex.supportedNonCardTypes containsObject:self.paymentMethod.type]) {
        if ([method.type isEqualToString:self.paymentMethod.type]) {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    } else if (method.Id && [method.Id isEqualToString:self.paymentMethod.Id]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    cell.isLastCell = indexPath.item == [tableView numberOfRowsInSection:indexPath.section] - 1;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray <AWXPaymentMethod *> *items = self.paymentMethods[indexPath.section];
    if (indexPath.section == 1) {
        return items.count != 0;
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = self.paymentMethods[indexPath.section];
    if (indexPath.section == 1 && items.count == 0) {
        return;
    }
    
    AWXPaymentMethod *method = items[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Would you like to delete this card?" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self disableCard:method];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
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
    
    // Confirm directly (Only be valid for payment flow)
    if ([Airwallex.supportedNonCardTypes containsObject:self.paymentMethod.type]) {
        // Confirm payment with wechat type directly
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
        
        if ([Airwallex checkoutMode] == AirwallexCheckoutNormalMode) {
            [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device consent:nil];
        }else{
            [strongSelf createPaymentConsentWithPaymentMethod:paymentMethod completion:^(AWXPaymentConsent * _Nullable consent) {
                [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device consent:consent];
            }];
        }
    }];
}

-(void)createPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod completion:(void(^)(AWXPaymentConsent * _Nullable))completion{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;
    request.paymentMethod = paymentMethod;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        AWXPaymentConsentResponse *result = response;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod consent:result.consent completion:^(AWXPaymentConsent * _Nullable consent) {
            completion(consent);
        }];
    }];
}


-(void)verifyPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod consent:(AWXPaymentConsent *)consent completion:(void(^)(AWXPaymentConsent * _Nullable))completion{
    
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXVerifyPaymentConsentRequest *request = [AWXVerifyPaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.consent = consent;
    AWXPaymentMethod * payment = paymentMethod;
    request.options = payment;

    [SVProgressHUD show];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        AWXPaymentConsentResponse *result = response;
        completion(result.consent);
    }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod device:(AWXDevice *)device consent:(AWXPaymentConsent *)consent
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = [AWXUIContext sharedContext].paymentIntent.Id;
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;
    request.paymentConsent = consent;
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
        [delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusError error:error];
        return;
    }
    
    if ([response.status isEqualToString:@"SUCCEEDED"] || [response.status isEqualToString:@"REQUIRES_CAPTURE"]) {
        [delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        return;
    }
    
    if (!response.nextAction) {
        [delegate paymentViewController:self didFinishWithStatus:AWXPaymentStatusSuccess error:error];
        return;
    }
    
    if (response.nextAction.weChatPayResponse) {
        [delegate paymentViewController:self nextActionWithWeChatPaySDK:response.nextAction.weChatPayResponse];
    } else if (response.nextAction.redirectResponse) {
        AWXPaymentIntent *paymentIntent = [AWXUIContext sharedContext].paymentIntent;
        AWXThreeDSService *service = [AWXThreeDSService new];
        service.customerId = paymentIntent.customerId;
        service.intentId = paymentIntent.Id;
        service.paymentMethod = self.paymentMethod;
        service.device = self.device;
        service.presentingViewController = self;
        service.delegate = self;
        self.service = service;
        [service presentThreeDSFlowWithServerJwt:response.nextAction.redirectResponse.jwt];
    } else if (response.nextAction.dccResponse) {
        [self performSegueWithIdentifier:@"showDCC" sender:response];
    } else if (response.nextAction.url) {
        [delegate paymentViewController:self nextActionWithAlipayURL:response.nextAction.url];
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

#pragma mark - AWXDCCViewControllerDelegate

- (void)dccViewController:(AWXDCCViewController *)controller useDCC:(BOOL)useDCC
{
    [controller dismissViewControllerAnimated:YES completion:nil];

    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];

    AWXConfirmThreeDSRequest *request = [AWXConfirmThreeDSRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.intentId = [AWXUIContext sharedContext].paymentIntent.Id;
    request.type = AWXDCC;
    request.useDCC = useDCC;
    request.device = self.device;

    [SVProgressHUD show];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        [SVProgressHUD dismiss];

        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

@end
