//
//  AWXPaymentMethodListViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodListViewController.h"
#import "AWXViewController+Utils.h"
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
#import "AWXPaymentConsent.h"
#import "AWXPaymentFormViewController.h"
#import "AWXFormMapping.h"
#import "AWXForm.h"

@interface AWXPaymentMethodListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, AWXCardViewControllerDelegate, AWXThreeDSServiceDelegate, AWXDCCViewControllerDelegate, AWXPaymentFormViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButtonItem;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSArray <NSArray <AWXPaymentMethod *> *> *paymentMethods;
@property (strong, nonatomic) NSMutableArray <AWXPaymentMethod *> *cards;
@property (nonatomic) BOOL canLoadMore;
@property (nonatomic) NSInteger nextPageNum;
@property (strong, nonatomic) AWXThreeDSService *service;
@property (strong, nonatomic) AWXDevice *device;
@property (strong, nonatomic) NSString *initialPaymentIntentId;
@property (nonatomic, strong) AWXPaymentConsent *paymentConsent;
@property (nonatomic, strong, nullable) AWXPaymentMethod *paymentMethod;
@property (nonatomic, strong) NSArray *availablePaymentMethodTypes;

@end

@implementation AWXPaymentMethodListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.closeBarButtonItem.image = [[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    [self.view addSubview:self.activityIndicator];

    [self loadPaymentMethodTypesFromPageNum:0];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.activityIndicator.center = self.view.center;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"confirmPayment"]) {
        AWXPaymentViewController *controller = (AWXPaymentViewController *)segue.destinationViewController;
        controller.delegate = [AWXUIContext sharedContext].delegate;
        controller.session = self.session;
        controller.paymentMethod = self.paymentMethod;
        controller.paymentConsent = self.paymentConsent;
        controller.isFlow = self.isFlow;
    } else if ([segue.identifier isEqualToString:@"addCard"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWXCardViewController *controller = (AWXCardViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.sameAsShipping = YES;
        controller.session = self.session;
        controller.isFlow = self.isFlow;
    } else if ([segue.identifier isEqualToString:@"showDCC"] && [sender isKindOfClass:[AWXConfirmPaymentIntentResponse class]]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AWXDCCViewController *controller = (AWXDCCViewController *)navigationController.topViewController;
        controller.response = sender;
        controller.delegate = self;
    }
}

- (void)loadCustomerPaymentMethods
{
    self.paymentMethods = @[self.section0, @[]];
    
    if ([self.session isKindOfClass:[AWXOneOffSession class]] && self.customerPaymentConsents.count > 0) {
        self.cards = @[].mutableCopy;
        for (AWXPaymentConsent * consent in  self.customerPaymentConsents) {
            if ([consent.nextTriggeredBy isEqualToString: @"customer"]) {
                for (AWXPaymentMethod * method in  self.customerPaymentMethods) {
                    if ([consent.paymentMethod.Id isEqualToString:method.Id]) {
                        [self.cards addObject:method];
                    }
                }
            }
        }
        self.paymentMethods = @[self.section0, self.cards];
    }
    [self.tableView reloadData];
}

- (NSArray <AWXPaymentMethod *> *)section0
{
    NSArray *supportedTypes = [Airwallex supportedNonCardTypes];
    NSMutableArray *paymentMethodTypes = [NSMutableArray array];
    for (NSString *type in self.availablePaymentMethodTypes) {
        if ([supportedTypes containsObject:type]) {
            AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
            paymentMethod.type = type;
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
    [self loadCustomerPaymentMethods];
}

- (void)loadPaymentMethodTypesFromPageNum:(NSInteger)pageNum {
    AWXGetPaymentMethodsTypeRequest *request = [AWXGetPaymentMethodsTypeRequest new];
    request.active = YES;
    request.pageNum = pageNum;
    request.transactionCurrency = self.currency;
    
    __weak __typeof(self)weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        if (response && !error) {
            AWXGetPaymentMethodTypeResponse *result = (AWXGetPaymentMethodTypeResponse *)response;
            NSMutableArray *typeArray = @[].mutableCopy;
            for (AWXPaymentMethodType * type in result.items) {
                if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
                    if ([type.transactionMode isEqualToString:@"oneoff"]) {
                        if (type.name){
                            [typeArray addObject:type.name];
                        }
                    }
                } else {
                    if ([type.transactionMode isEqualToString:@"recurring"]){
                        if (type.name){
                            [typeArray addObject:type.name];
                        }
                    }
                }
            }
            strongSelf.availablePaymentMethodTypes = typeArray;
            [strongSelf reloadData];
            [strongSelf.tableView reloadData];
            strongSelf.nextPageNum = pageNum + 1;
        }
    }];
}

- (void)newPressed:(id)sender
{
    [self performSegueWithIdentifier:@"addCard" sender:nil];
}

- (void)disableCard:(AWXPaymentMethod *)paymentMethod
{
    [self.activityIndicator startAnimating];
    
    AWXDisablePaymentMethodRequest *request = [AWXDisablePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethodId = paymentMethod.Id;
    
    __weak __typeof(self)weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.activityIndicator stopAnimating];
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
    if (section == 1 && [self.availablePaymentMethodTypes containsObject:AWXCardKey]) {
        return 60;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 && [self.availablePaymentMethodTypes containsObject:AWXCardKey]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 56)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(16, 8, CGRectGetWidth(self.view.bounds) - 32, 44);
        button.layer.cornerRadius = 6;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [AWXTheme sharedTheme].lineColor.CGColor;
        button.layer.masksToBounds = YES;
        [button setTitle:NSLocalizedString(@"Card", nil) forState:UIControlStateNormal];
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
    return NSLocalizedString(@"Delete", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = self.paymentMethods[indexPath.section];
    if (indexPath.section == 1 && items.count == 0) {
        return;
    }
    
    AWXPaymentMethod *method = items[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Would you like to delete this card?", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self disableCard:method];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
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
        [self loadPaymentMethodTypesFromPageNum:self.nextPageNum];
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
    
    if ([Airwallex.supportedExtensionNonCardTypes containsObject:self.paymentMethod.type]) {
        AWXFormMapping *formMapping = [AWXFormMapping new];
//        if ([self.paymentMethod.type isEqualToString:AWXBankTransfer]) {
            formMapping.title = NSLocalizedString(@"Select your bank", @"Select your bank");
            formMapping.forms = @[
                [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Affin Bank" placeholder:@"affin" logo:@"affin_bank"],
                [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Alliance Bank" placeholder:@"alliance" logo:@"alliance_bank"],
                [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"AmBank" placeholder:@"ambank" logo:@"ambank"],
                [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Bank Islam" placeholder:@"islam" logo:@"bank_islam"],
                [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Bank Kerjasama Rakyat Malaysia" placeholder:@"rakyat" logo:@"bank_kerjasama_rakyat"],
                [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Bank Muamalat" placeholder:@"muamalat" logo:@"bank_muamalat"],
                [AWXForm formWithKey:@"bank_name" type:AWXFormTypeOption title:@"Bank Simpanan Nasional" placeholder:@"bsn" logo:@"bank_simpanan_nasional"]
            ];
//        } else {
//            formMapping.title = FormatPaymentMethodTypeString(self.paymentMethod.type);
//            formMapping.forms = @[
//                [AWXForm formWithKey:@"shopper_name" type:AWXFormTypeField title:@"Name"],
//                [AWXForm formWithKey:@"shopper_email" type:AWXFormTypeField title:@"Email"],
//                [AWXForm formWithKey:@"shopper_phone" type:AWXFormTypeField title:@"Phone"],
//                [AWXForm formWithKey:@"pay" type:AWXFormTypeButton title:@"Pay now"]
//            ];
//        }
        AWXPaymentFormViewController *controller = [[AWXPaymentFormViewController alloc] initWithNibName:nil bundle:nil];
        controller.delegate = self;
        controller.paymentMethod = method;
        controller.formMapping = formMapping;
        controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }
    
    // Confirm directly (Only be valid for payment flow)
    if ([Airwallex.supportedNonCardTypes containsObject:self.paymentMethod.type]) {
        // Confirm payment with wechat type directly
        [self confirmPaymentIntentWithPaymentMethod:self.paymentMethod];
        return;
    }
    
    for (AWXPaymentConsent * consent in  self.customerPaymentConsents) {
        if ([consent.paymentMethod.Id isEqualToString:self.paymentMethod.Id]) {
            self.paymentConsent = consent;
        }
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
    if (![paymentMethod.type isEqualToString:AWXCardKey]) {
        NSDictionary *metaData = @{@"flow": @"inapp", @"os_type": @"ios"};
        if (paymentMethod.additionalParams) {
            NSMutableDictionary *params = paymentMethod.additionalParams.mutableCopy;
            [params addEntriesFromDictionary:metaData];
            paymentMethod.additionalParams = params;
        } else {
            paymentMethod.additionalParams = metaData;
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.activityIndicator startAnimating];
    [[AWXSecurityService sharedService] doProfile:self.paymentIntentId ?: self.initialPaymentIntentId completion:^(NSString * _Nonnull sessionId) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.activityIndicator stopAnimating];

        AWXDevice *device = [AWXDevice new];
        device.deviceId = sessionId;
        
        if ([self.session isKindOfClass:[AWXOneOffSession class]]) {
            [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device consent:nil];
        } else if ([self.session isKindOfClass:[AWXRecurringSession class]]) {
            [strongSelf createPaymentConsentWithPaymentMethod:paymentMethod  createCompletion:^(AWXPaymentConsent * _Nullable consent) {
                [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod consent:consent];
            }];
        } else if ([self.session isKindOfClass:[AWXRecurringWithIntentSession class]]) {
            [strongSelf createPaymentConsentWithPaymentMethod:paymentMethod createCompletion:^(AWXPaymentConsent * _Nullable consent) {
                if ([paymentMethod.type isEqualToString:AWXCardKey]) {
                    [strongSelf confirmPaymentIntentWithPaymentMethod:paymentMethod device:device consent:consent];
                } else {
                    [strongSelf verifyPaymentConsentWithPaymentMethod:paymentMethod consent:consent];
                }
            }];
        }
    }];
}

- (void)createPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod createCompletion:(void(^)(AWXPaymentConsent * _Nullable))completion
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXCreatePaymentConsentRequest *request = [AWXCreatePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.customerId = self.customerId;
    request.paymentMethod = paymentMethod;
    request.currency = self.currency;
    request.nextTriggerByType = self.nextTriggerByType;
    [self.activityIndicator startAnimating];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.activityIndicator stopAnimating];
        
        AWXPaymentConsentResponse *result = response;
        completion(result.consent);
    }];
}


- (void)verifyPaymentConsentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod consent:(AWXPaymentConsent *)consent
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXVerifyPaymentConsentRequest *request = [AWXVerifyPaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.currency = self.currency;
    request.amount = self.amount;
    request.consent = consent;
    AWXPaymentMethod * payment = paymentMethod;
    request.options = payment;
    request.returnURL =  @"airwallexcheckout://com.airwallex.paymentacceptance";
    [self.activityIndicator startAnimating];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.activityIndicator stopAnimating];
        
        AWXVerifyPaymentConsentResponse *result = response;
        if ([self.session isKindOfClass:[AWXRecurringSession class]]){
            self.initialPaymentIntentId = result.initialPaymentIntentId;
        }
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)confirmPaymentIntentWithPaymentMethod:(AWXPaymentMethod *)paymentMethod device:(AWXDevice *)device consent:(AWXPaymentConsent *)consent
{
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    AWXConfirmPaymentIntentRequest *request = [AWXConfirmPaymentIntentRequest new];
    request.intentId = self.paymentIntentId ?: self.initialPaymentIntentId;
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

    [self.activityIndicator startAnimating];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.activityIndicator stopAnimating];
        
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
        AWXThreeDSService *service = [AWXThreeDSService new];
        service.customerId = self.customerId;
        service.intentId = self.paymentIntentId ?: self.initialPaymentIntentId;
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
    request.intentId = self.paymentIntentId ?: self.initialPaymentIntentId;
    request.type = AWXDCC;
    request.useDCC = useDCC;
    request.device = self.device;

    [self.activityIndicator startAnimating];
    __weak __typeof(self)weakSelf = self;
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.activityIndicator stopAnimating];
        
        [strongSelf finishConfirmationWithResponse:response error:error];
    }];
}

- (void)paymentExtensionInfoData:(NSDictionary *)data
{
    NSString *message = @"";
    for (NSString *key in data.allKeys) {
        message =  [message stringByAppendingFormat:@"%@:%@", key, data[key]];
    }
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - AWXPaymentFormViewControllerDelegate

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didSelectOption:(NSDictionary *)params
{
    [self.paymentMethod appendAdditionalParams:params];

    AWXFormMapping *formMapping = [AWXFormMapping new];
    formMapping.title = NSLocalizedString(@"Bank transfer", @"Bank transfer");
    formMapping.forms = @[
        [AWXForm formWithKey:@"shopper_name" type:AWXFormTypeField title:@"Name"],
        [AWXForm formWithKey:@"shopper_email" type:AWXFormTypeField title:@"Email"],
        [AWXForm formWithKey:@"shopper_phone" type:AWXFormTypeField title:@"Phone"],
        [AWXForm formWithKey:@"pay" type:AWXFormTypeButton title:@"Pay now"]
    ];
    AWXPaymentFormViewController *controller = [[AWXPaymentFormViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.paymentMethod = self.paymentMethod;
    controller.formMapping = formMapping;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didConfirmPayment:(NSDictionary *)params
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self.paymentMethod appendAdditionalParams:params];
        [self confirmPaymentIntentWithPaymentMethod:self.paymentMethod];
    }];
}

@end
