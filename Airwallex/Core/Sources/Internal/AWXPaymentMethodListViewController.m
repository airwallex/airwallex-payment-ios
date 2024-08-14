//
//  AWXPaymentMethodListViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodListViewController.h"
#import "AWXAPIClient.h"
#import "AWXAnalyticsLogger.h"
#import "AWXCardImageView.h"
#import "AWXConstants.h"
#import "AWXDefaultActionProvider.h"
#import "AWXDefaultProvider.h"
#import "AWXForm.h"
#import "AWXFormMapping.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodCell.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXPaymentViewController.h"
#import "AWXSession+Internal.h"
#import "AWXTheme.h"
#import "AWXTrackManager.h"
#import "AWXUtils.h"
#import "AWXWidgets.h"
#import "NSObject+Logging.h"
#import <AirwallexRisk/AirwallexRisk-Swift.h>
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@interface AWXPaymentMethodListViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, AWXProviderDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSArray *availablePaymentMethodTypes;
@property (nonatomic, strong) NSMutableArray<AWXPaymentConsent *> *availablePaymentConsents;
@property (nonatomic) BOOL canLoadMore;
@property (nonatomic) BOOL showCardDirectly;
@property (nonatomic) NSInteger nextPageNum;
@property (nonatomic, strong) NSArray<AWXPaymentMethodType *> *filteredPaymentMethodTypes;
@property (nonatomic) BOOL isFlowFromPushing;

@end

@implementation AWXPaymentMethodListViewController

- (NSString *)pageName {
    return @"payment_method_list";
}

- (instancetype)initWithIsFlowFromPushing:(BOOL)isFlowFromPushing {
    self = [super init];
    if (self) {
        self.isFlowFromPushing = isFlowFromPushing;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isFlowFromPushing) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back" inBundle:[NSBundle resourceBundle]] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    }

    self.showCardDirectly = NO;
    self.view.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [AWXTheme sharedTheme].primaryBackgroundColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableHeaderView = [self headerView];
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorColor = [AWXTheme sharedTheme].lineColor;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 24, 0, 24);
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.hidden = YES;
    [_tableView registerClass:[AWXPaymentMethodCell class] forCellReuseIdentifier:@"AWXPaymentMethodCell"];
    [self.view addSubview:_tableView];

    NSDictionary *views = @{@"tableView": _tableView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tableView]-|" options:0 metrics:nil views:views]];

    [self reloadListItems];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [AWXRisk logWithEvent:@"show_payment_method_list" screen:@"page_method_list"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *headerView = self.tableView.tableHeaderView;
    CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = headerView.frame;
    if (height != frame.size.height) {
        frame.size.height = height;
        headerView.frame = frame;
        self.tableView.tableHeaderView = headerView;
    }
}

- (UIView *)headerView {
    UITableViewHeaderFooterView *headerView = [UITableViewHeaderFooterView new];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = NSLocalizedString(@"Payment methods", @"Payment methods");
    titleLabel.textColor = [AWXTheme sharedTheme].primaryTextColor;
    titleLabel.font = [UIFont titleFont];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:titleLabel];

    NSDictionary *views = @{@"titleLabel": titleLabel};
    NSDictionary *metrics = @{@"margin": @16};
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[titleLabel]-margin-|" options:0 metrics:metrics views:views]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[titleLabel]-margin-|" options:0 metrics:metrics views:views]];

    return headerView;
}

- (void)reloadListItems {
    // Fetch all available payment method types and consents
    [self startAnimating];

    __weak __typeof(self) weakSelf = self;
    [self log:@"Start loading payment methods and consents. Intent Id:%@", self.session.paymentIntentId];
    [_viewModel fetchAvailablePaymentMethodsAndConsentsWithCompletionHandler:^(NSArray<AWXPaymentMethodType *> *_Nullable methods, NSArray<AWXPaymentConsent *> *_Nullable consents, NSError *_Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf stopAnimating];
        if (error) {
            [strongSelf log:@"%@ Intent Id:%@", error.localizedDescription, self.session.paymentIntentId];
            [strongSelf showAlert:error.localizedDescription];
        } else {
            [strongSelf log:@"Finish loading payment methods and consents. Intent Id:%@", self.session.paymentIntentId];
            strongSelf.availablePaymentMethodTypes = [strongSelf.session filteredPaymentMethodTypes:methods];
            strongSelf.availablePaymentConsents = [consents mutableCopy];
            [strongSelf filterPaymentMethodTypes];

            [strongSelf presentSingleCardShortcutIfRequired];
            [strongSelf.tableView reloadData];
        }
    }];
}

- (void)presentSingleCardShortcutIfRequired {
    BOOL hasPaymentConsents = self.availablePaymentConsents.count > 0;
    BOOL hasSinglePaymentMethod = self.filteredPaymentMethodTypes.count == 1;
    self.showCardDirectly = !hasPaymentConsents && hasSinglePaymentMethod;

    if (self.showCardDirectly) {
        // find the card payment method if it exists
        for (AWXPaymentMethodType *type in self.filteredPaymentMethodTypes) {
            if ([type.name isEqualToString:AWXCardKey]) {
                [self didSelectPaymentMethodType:type];
                break;
            } else {
                _tableView.hidden = NO;
            }
        }
    } else {
        _tableView.hidden = NO;
    }
}

- (void)filterPaymentMethodTypes {
    if (self.session.paymentMethods && self.session.paymentMethods.count > 0) {
        [self log:@"Payment list filtered. Your input: %@", [self.session.paymentMethods componentsJoinedByString:@"  "]];
        NSMutableArray *intersectionArray = [NSMutableArray array];
        for (NSString *type in self.session.paymentMethods) {
            for (AWXPaymentMethodType *availableType in self.availablePaymentMethodTypes) {
                if ([type.lowercaseString isEqual:availableType.name.lowercaseString] && ![intersectionArray containsObject:availableType]) {
                    [intersectionArray addObject:availableType];
                }
            }
        }
        self.filteredPaymentMethodTypes = intersectionArray;
    } else {
        self.filteredPaymentMethodTypes = self.availablePaymentMethodTypes;
    }
}

- (void)disablePaymentConsent:(AWXPaymentConsent *)paymentConsent index:(NSInteger)index {
    [self startAnimating];

    AWXDisablePaymentConsentRequest *request = [AWXDisablePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.Id = paymentConsent.id;

    __weak __typeof(self) weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             __strong __typeof(weakSelf) strongSelf = weakSelf;
             [strongSelf stopAnimating];

             if (error) {
                 [strongSelf showAlert:error.localizedDescription];
                 [strongSelf log:@"removing consent failed. ID: %@", paymentConsent.id];
                 return;
             }

             [strongSelf log:@"remove consent successfully. ID: %@", paymentConsent.id];
             [strongSelf.availablePaymentConsents removeObjectAtIndex:index];
             [strongSelf.tableView reloadData];
         }];
}

- (void)showPayment:(AWXPaymentConsent *)paymentConsent {
    AWXPaymentViewController *controller = [[AWXPaymentViewController alloc] initWithShownDirectly:NO isFlowFromPushing:self.isFlowFromPushing];
    controller.delegate = [AWXUIContext sharedContext].delegate;
    controller.session = self.session;
    controller.paymentConsent = paymentConsent;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
                                 [delegate paymentViewController:self didCompleteWithStatus:AirwallexPaymentStatusCancel error:nil];
                             }];
}

- (void)goBack:(id)sender {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
        [delegate paymentViewController:self didCompleteWithStatus:AirwallexPaymentStatusCancel error:nil];
    }];
    [self.navigationController popViewControllerAnimated:YES];
    [CATransaction commit];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
    case 0:
        // payment consents section
        return self.availablePaymentConsents.count;
    case 1:
        // payment methods section
        return self.filteredPaymentMethodTypes.count;
    default:
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AWXPaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWXPaymentMethodCell" forIndexPath:indexPath];

    switch (indexPath.section) {
    case 0: {
        AWXPaymentConsent *paymentConsent = self.availablePaymentConsents[indexPath.row];
        AWXBrand *cardBrand = [[AWXCardValidator shared] brandForCardName:paymentConsent.paymentMethod.card.brand];
        cell.logoImageView.image = [[AWXCardImageView alloc] initWithCardBrand:cardBrand.type].image;
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ •••• %@", paymentConsent.paymentMethod.card.brand.capitalizedString, paymentConsent.paymentMethod.card.last4];
        break;
    }
    case 1: {
        AWXPaymentMethodType *paymentMethodType = self.filteredPaymentMethodTypes[indexPath.row];
        [cell.logoImageView setImageURL:paymentMethodType.resources.logoURL
                            placeholder:nil];
        cell.titleLabel.text = paymentMethodType.displayName;
        break;
    }
    default:
        break;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? YES : NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Delete", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return;
    }

    AWXPaymentConsent *paymentConsent = self.availablePaymentConsents[indexPath.row];

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Would you like to delete this card?", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              [self disablePaymentConsent:paymentConsent index:indexPath.row];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
    case 0: {
        // No cvc provided and go to enter cvc in payment detail page
        AWXPaymentConsent *paymentConsent = self.availablePaymentConsents[indexPath.row];
        if ([paymentConsent.paymentMethod.card.numberType isEqualToString:@"PAN"]) {
            [self showPayment:paymentConsent];
        } else {
            AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:self session:self.session];
            [provider confirmPaymentIntentWithPaymentMethod:paymentConsent.paymentMethod paymentConsent:paymentConsent device:nil];
            self.provider = provider;
        }

        if (paymentConsent.paymentMethod.type.length > 0) {
            [[AWXAnalyticsLogger shared] logActionWithName:@"select_payment" additionalInfo:@{@"paymentMethod": paymentConsent.paymentMethod.type}];
        }
        break;
    }
    case 1: {
        AWXPaymentMethodType *paymentMethodType = self.filteredPaymentMethodTypes[indexPath.row];
        [self didSelectPaymentMethodType:paymentMethodType];

        if (paymentMethodType.name.length > 0) {
            [[AWXAnalyticsLogger shared] logActionWithName:@"select_payment" additionalInfo:@{@"paymentMethod": paymentMethodType.name}];
        }
        break;
    }
    }
}

- (void)didSelectPaymentMethodType:(AWXPaymentMethodType *)paymentMethodType {
    Class class = ClassToHandleFlowForPaymentMethodType(paymentMethodType);

    AWXDefaultProvider *provider = [[class alloc] initWithDelegate:self session:self.session paymentMethodType:paymentMethodType isFlowFromPushing:self.isFlowFromPushing];
    provider.showPaymentDirectly = self.showCardDirectly;
    [provider handleFlow];
    self.provider = provider;
}

#pragma mark - AWXProviderDelegate

- (void)providerDidStartRequest:(AWXDefaultProvider *)provider {
    [self log:@"providerDidStartRequest:"];
    [self startAnimating];
}

- (void)providerDidEndRequest:(AWXDefaultProvider *)provider {
    [self log:@"providerDidEndRequest:"];
    [self stopAnimating];
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    [self log:@"provider:didCompleteWithStatus:error:  %lu  %@", status, error.localizedDescription];
    id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    [delegate paymentViewController:self didCompleteWithStatus:status error:error];
    [self log:@"Delegate: %@, paymentViewController:didCompleteWithStatus:error: %@  %lu  %@", delegate.class, self.class, status, error.localizedDescription];
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithPaymentConsentId:(NSString *)Id {
    id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    if ([delegate respondsToSelector:@selector(paymentViewController:didCompleteWithPaymentConsentId:)]) {
        [delegate paymentViewController:self didCompleteWithPaymentConsentId:Id];
    }
}

- (void)provider:(AWXDefaultProvider *)provider didInitializePaymentIntentId:(NSString *)paymentIntentId {
    [self.session updateInitialPaymentIntentId:paymentIntentId];
    [self log:@"provider:didInitializePaymentIntentId:  %@", paymentIntentId];
}

- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    Class class = ClassToHandleNextActionForType(nextAction);
    if (class == nil) {
        [self showAlert:NSLocalizedString(@"No provider matched the next action.", nil)];
        return;
    }

    AWXDefaultActionProvider *actionProvider = [[class alloc] initWithDelegate:self session:self.session];
    [actionProvider handleNextAction:nextAction];
    self.provider = actionProvider;
}

- (void)provider:(AWXDefaultProvider *)provider shouldPresentViewController:(nullable UIViewController *)controller forceToDismiss:(BOOL)forceToDismiss withAnimation:(BOOL)withAnimation {
    if (forceToDismiss) {
        [self.presentedViewController dismissViewControllerAnimated:YES
                                                         completion:^{
                                                             if (controller) {
                                                                 [self presentViewController:controller animated:withAnimation completion:nil];
                                                             }
                                                         }];
    } else if (controller) {
        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        if (self.showCardDirectly) {
            [viewControllers removeObject:self];
        }
        [viewControllers addObject:controller];
        [self.navigationController setViewControllers:viewControllers animated:!self.showCardDirectly];
    }
}

- (void)provider:(AWXDefaultProvider *)provider shouldInsertViewController:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = CGRectInset(self.view.frame, 0, CGRectGetMaxY(self.view.bounds));
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void)showAlert:(NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
