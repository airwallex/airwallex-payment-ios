//
//  AWXPaymentMethodListViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodListViewController.h"
#import "AWXViewModel.h"
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

@interface AWXPaymentMethodListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, AWXCardViewControllerDelegate, AWXDCCViewControllerDelegate, AWXPaymentFormViewControllerDelegate, AWXViewModelDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSArray *availablePaymentMethodTypes;
@property (strong, nonatomic) NSArray <NSArray <AWXPaymentMethod *> *> *paymentMethods;
@property (strong, nonatomic) NSMutableArray <AWXPaymentMethod *> *cards;
@property (nonatomic) BOOL canLoadMore;
@property (nonatomic) NSInteger nextPageNum;

@property (nonatomic, strong) AWXViewModel *viewModel;
@property (nonatomic, strong, nullable) AWXPaymentMethod *paymentMethod;
@property (nonatomic, strong, nullable) AWXPaymentConsent *paymentConsent;

@end

@implementation AWXPaymentMethodListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewModel = [[AWXViewModel alloc] initWithSession:self.session delegate:self];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor bgColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableHeaderView = [self headerView];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[AWXPaymentMethodCell class] forCellReuseIdentifier:@"AWXPaymentMethodCell"];
    [self.view addSubview:_tableView];
    
    NSDictionary *views = @{@"tableView": _tableView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tableView]-|" options:0 metrics:nil views:views]];

    [self loadPaymentMethodTypesFromPageNum:0];
}

- (UIView *)headerView
{
    UITableViewHeaderFooterView *headerView = [UITableViewHeaderFooterView new];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = NSLocalizedString(@"Payment methods", @"Payment methods");
    titleLabel.textColor = [UIColor textColor];
    titleLabel.font = [UIFont fontWithName:AWXFontNameCircularStdBold size:32];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:titleLabel];
    
    NSDictionary *views = @{@"titleLabel": titleLabel};
    NSDictionary *metrics = @{@"margin": @16};
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[titleLabel]-margin-|" options:0 metrics:metrics views:views]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[titleLabel]-margin-|" options:0 metrics:metrics views:views]];
    
    return headerView;
}

- (void)loadCustomerPaymentMethods
{
    self.paymentMethods = @[self.section0, @[]];
    
    if ([self.session isKindOfClass:[AWXOneOffSession class]] && self.session.customerPaymentConsents.count > 0) {
        self.cards = @[].mutableCopy;
        for (AWXPaymentConsent * consent in  self.session.customerPaymentConsents) {
            if ([consent.nextTriggeredBy isEqualToString:FormatNextTriggerByType(AirwallexNextTriggerByCustomerType)]) {
                for (AWXPaymentMethod * method in  self.session.customerPaymentMethods) {
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
    if (self.session.customerId == nil) {
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
    request.transactionCurrency = self.session.currency;
    
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
    AWXCardViewController *controller = [[AWXCardViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.sameAsShipping = YES;
    controller.session = self.session;
    controller.isFlow = self.isFlow;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)disableCard:(AWXPaymentMethod *)paymentMethod
{
    [self startAnimating];
    
    AWXDisablePaymentMethodRequest *request = [AWXDisablePaymentMethodRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.paymentMethodId = paymentMethod.Id;
    
    __weak __typeof(self)weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf stopAnimating];
        if (error) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
            [strongSelf presentViewController:controller animated:YES completion:nil];
            return;
        }
        
        [strongSelf reloadData];
    }];
}

- (void)showPayment
{
    AWXPaymentViewController *controller = [[AWXPaymentViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = [AWXUIContext sharedContext].delegate;
    controller.session = self.session;
    controller.paymentMethod = self.paymentMethod;
    controller.paymentConsent = self.paymentConsent;
    controller.isFlow = self.isFlow;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showDcc:(AWXDccResponse *)response
{
    AWXDCCViewController *controller = [[AWXDCCViewController alloc] initWithNibName:nil bundle:nil];
    controller.session = self.session;
    controller.response = response;
    controller.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        controller.session = self.session;
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
        [self.viewModel confirmPaymentIntentWithPaymentMethod:self.paymentMethod paymentConsent:self.paymentConsent];
        return;
    }
    
    for (AWXPaymentConsent * consent in self.session.customerPaymentConsents) {
        if ([consent.paymentMethod.Id isEqualToString:self.paymentMethod.Id]) {
            self.paymentConsent = consent;
        }
    }
    
    // No cvc provided and go to enter cvc in payment detail page
    [self showPayment];
}

#pragma mark - AWXCardViewControllerDelegate

- (void)cardViewController:(AWXCardViewController *)controller didCreatePaymentMethod:(AWXPaymentMethod *)paymentMethod
{
    self.paymentMethod = paymentMethod;
    [self reloadData];
    [controller dismissViewControllerAnimated:YES completion:^{
        if (self.isFlow) {
            [self showPayment];
        }
    }];
}

#pragma mark - AWXViewModelDelegate

- (void)viewModelDidStartRequest:(AWXViewModel *)viewModel
{
    [self startAnimating];
}

- (void)viewModelDidEndRequest:(AWXViewModel *)viewModel
{
    [self stopAnimating];
}

- (void)viewModel:(AWXViewModel *)viewModel didCompleteWithError:(NSError *)error
{
    id <AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    [delegate paymentViewController:self didFinishWithStatus:error != nil ? AWXPaymentStatusError : AWXPaymentStatusSuccess error:error];
}

- (void)viewModel:(AWXViewModel *)viewModel didCreatePaymentConsent:(AWXPaymentConsent *)paymentConsent
{
    self.paymentConsent = paymentConsent;
}

- (void)viewModel:(AWXViewModel *)viewModel didInitializePaymentIntentId:(NSString *)paymentIntentId
{
    [self.session updateInitialPaymentIntentId:paymentIntentId];
}

- (void)viewModel:(AWXViewModel *)viewModel shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction
{
    id <AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    if (nextAction.weChatPayResponse) {
        [delegate paymentViewController:self nextActionWithWeChatPaySDK:nextAction.weChatPayResponse];
    } else if (nextAction.redirectResponse) {
        [self.viewModel handleThreeDSWithJwt:nextAction.redirectResponse.jwt
                    presentingViewController:self];
    } else if (nextAction.dccResponse) {
        [self showDcc:nextAction.dccResponse];
    } else if (nextAction.url) {
        [delegate paymentViewController:self nextActionWithRedirectToURL:nextAction.url];
    } else {
        [delegate paymentViewController:self
                    didFinishWithStatus:AWXPaymentStatusError
                                  error:[NSError errorWithDomain:AWXSDKErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported next action."}]];
    }
}

#pragma mark - AWXDCCViewControllerDelegate

- (void)dccViewController:(AWXDCCViewController *)controller useDCC:(BOOL)useDCC
{
    [controller dismissViewControllerAnimated:YES completion:nil];

    [self.viewModel confirmThreeDSWithUseDCC:useDCC];
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
    controller.session = self.session;
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
        [self.viewModel confirmPaymentIntentWithPaymentMethod:self.paymentMethod
                                               paymentConsent:self.paymentConsent];
    }];
}

@end
