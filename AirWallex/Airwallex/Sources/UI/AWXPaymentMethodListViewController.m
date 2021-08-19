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

@interface AWXPaymentMethodListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, AWXDCCViewControllerDelegate, AWXPaymentFormViewControllerDelegate, AWXViewModelDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSArray *availablePaymentMethodTypes;
@property (nonatomic, strong) NSMutableArray <AWXPaymentConsent *> *availablePaymentConsents;
@property (nonatomic) BOOL canLoadMore;
@property (nonatomic) NSInteger nextPageNum;

@property (nonatomic, strong) AWXViewModel *viewModel;

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
    
    [self reloadListItems];
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

- (void)reloadListItems
{
    // Fetch all available payment method types
    self.nextPageNum = 0;
    [self loadAvailablePaymentMethodTypesWithPageNum:self.nextPageNum];
    
    // Fetch all customer payment methods
    [self loadAvailablePaymentConsents];
}

- (void)loadAvailablePaymentMethodTypesWithPageNum:(NSInteger)pageNum
{
    AWXGetPaymentMethodTypesRequest *request = [AWXGetPaymentMethodTypesRequest new];
    request.active = YES;
    request.pageNum = pageNum;
    request.transactionCurrency = self.session.currency;
    
    __weak __typeof(self)weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request handler:^(id<AWXResponseProtocol>  _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (response && !error) {
            AWXGetPaymentMethodTypesResponse *result = (AWXGetPaymentMethodTypesResponse *)response;
            strongSelf.availablePaymentMethodTypes = [result.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"transactionMode == %@", strongSelf.session.transactionMode]];
            strongSelf.canLoadMore = result.hasMore;
            strongSelf.nextPageNum = pageNum + 1;
            [strongSelf.tableView reloadData];
        }
    }];
}

- (void)loadAvailablePaymentConsents
{
    NSArray *customerPaymentMethods = self.session.customerPaymentMethods;
    NSArray *customerPaymentConsents = self.session.customerPaymentConsents;
    
    if ([self.session isKindOfClass:[AWXOneOffSession class]] && customerPaymentConsents.count > 0 && customerPaymentMethods.count > 0) {
        NSArray *paymentConsents = [customerPaymentConsents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nextTriggeredBy == %@", FormatNextTriggerByType(AirwallexNextTriggerByCustomerType)]];
        NSMutableArray *availablePaymentConsents = [@[] mutableCopy];
        for (AWXPaymentConsent *consent in paymentConsents) {
            AWXPaymentMethod *paymentMethod = [customerPaymentMethods filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Id == %@", consent.paymentMethod.Id]].firstObject;
            if (paymentMethod != nil) {
                consent.paymentMethod = paymentMethod;
                [availablePaymentConsents addObject:consent];
            }
        }
        self.availablePaymentConsents = availablePaymentConsents;
        [self.tableView reloadData];
    }
}

- (void)showNewCard
{
    AWXCardViewController *controller = [[AWXCardViewController alloc] initWithNibName:nil bundle:nil];
    controller.sameAsShipping = YES;
    controller.session = self.session;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)disablePaymentConsent:(AWXPaymentConsent *)paymentConsent index:(NSInteger)index
{
    [self startAnimating];
    
    AWXDisablePaymentConsentRequest *request = [AWXDisablePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.Id = paymentConsent.Id;
    
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
        
        [strongSelf.availablePaymentConsents removeObjectAtIndex:index];
        [strongSelf.tableView reloadData];
    }];
}

- (void)showPayment:(AWXPaymentConsent *)paymentConsent
{
    AWXPaymentViewController *controller = [[AWXPaymentViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = [AWXUIContext sharedContext].delegate;
    controller.session = self.session;
    controller.paymentConsent = paymentConsent;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showPaymentForm:(AWXPaymentMethod *)paymentMethod
{
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
    controller.paymentMethod = paymentMethod;
    controller.formMapping = formMapping;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:controller animated:YES completion:nil];
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
    return 1 + (self.availablePaymentConsents.count > 0 ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.availablePaymentMethodTypes.count;
    }
    return self.availablePaymentConsents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *logoImage = nil;
    NSString *title = nil;
    if (indexPath.section == 0) {
        AWXPaymentMethodType *paymentMethodType = self.availablePaymentMethodTypes[indexPath.row];
        logoImage = [UIImage imageNamed:paymentMethodType.name inBundle:[NSBundle resourceBundle]];
        title = paymentMethodType.name.capitalizedString;
    } else {
        AWXPaymentConsent *paymentConsent = self.availablePaymentConsents[indexPath.row];
        logoImage = [UIImage imageNamed:paymentConsent.paymentMethod.card.brand inBundle:[NSBundle resourceBundle]];
        title = [NSString stringWithFormat:@"%@ •••• %@", paymentConsent.paymentMethod.card.brand.capitalizedString, paymentConsent.paymentMethod.card.last4];
    }
    
    AWXPaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWXPaymentMethodCell" forIndexPath:indexPath];
    cell.logoImageView.image = logoImage;
    cell.titleLabel.text = title;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    
    AWXPaymentConsent *paymentConsent = self.availablePaymentConsents[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Would you like to delete this card?", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self disablePaymentConsent:paymentConsent index:indexPath.row];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        AWXPaymentMethodType *paymentMethodType = self.availablePaymentMethodTypes[indexPath.row];
        AWXPaymentMethod *paymentMethod = [AWXPaymentMethod new];
        paymentMethod.type = paymentMethodType.name;
        
        if ([Airwallex.paymentFormRequiredTypes containsObject:paymentMethodType.name]) {
            [self showPaymentForm:paymentMethod];
        } else if ([paymentMethodType.name isEqualToString:AWXCardKey]) {
            [self showNewCard];
        } else {
            [self.viewModel confirmPaymentIntentWithPaymentMethod:paymentMethod paymentConsent:nil];
        }
        return;
    }
    
    // No cvc provided and go to enter cvc in payment detail page
    AWXPaymentConsent *paymentConsent = self.availablePaymentConsents[indexPath.row];
    [self showPayment:paymentConsent];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.canLoadMore) {
        return;
    }
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 0) {
        [self loadAvailablePaymentMethodTypesWithPageNum:self.nextPageNum];
    }
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

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didUpdatePaymentMethod:(nonnull AWXPaymentMethod *)paymentMethod
{
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
    controller.paymentMethod = paymentMethod;
    controller.formMapping = formMapping;
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

- (void)paymentFormViewController:(AWXPaymentFormViewController *)paymentFormViewController didConfirmPaymentMethod:(nonnull AWXPaymentMethod *)paymentMethod
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self.viewModel confirmPaymentIntentWithPaymentMethod:paymentMethod
                                               paymentConsent:nil];
    }];
}

@end
