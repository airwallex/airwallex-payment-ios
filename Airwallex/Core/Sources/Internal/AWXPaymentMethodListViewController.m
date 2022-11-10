//
//  AWXPaymentMethodListViewController.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/17.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodListViewController.h"
#import "AWXAPIClient.h"
#import "AWXConstants.h"
#import "AWXDefaultActionProvider.h"
#import "AWXDefaultProvider.h"
#import "AWXDevice.h"
#import "AWXForm.h"
#import "AWXFormMapping.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentIntent.h"
#import "AWXPaymentIntentRequest.h"
#import "AWXPaymentIntentResponse.h"
#import "AWXPaymentMethod.h"
#import "AWXPaymentMethodCell.h"
#import "AWXPaymentMethodOptions.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#import "AWXPaymentViewController.h"
#import "AWXSession+Internal.h"
#import "AWXTheme.h"
#import "AWXTrackManager.h"
#import "AWXUtils.h"
#import "AWXWidgets.h"

@interface AWXPaymentMethodListViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, AWXProviderDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSArray *availablePaymentMethodTypes;
@property (nonatomic, strong) NSMutableArray<AWXPaymentConsent *> *availablePaymentConsents;
@property (nonatomic) BOOL canLoadMore;
@property (nonatomic) NSInteger nextPageNum;

@end

@implementation AWXPaymentMethodListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close" inBundle:[NSBundle resourceBundle]] style:UIBarButtonItemStylePlain target:self action:@selector(close:)];

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
    [_tableView registerClass:[AWXPaymentMethodCell class] forCellReuseIdentifier:@"AWXPaymentMethodCell"];
    [self.view addSubview:_tableView];

    NSDictionary *views = @{@"tableView": _tableView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tableView]-|" options:0 metrics:nil views:views]];

    [self reloadListItems];
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
    // Fetch all available payment method types
    self.nextPageNum = 0;
    [self loadAvailablePaymentMethodTypesWithPageNum:self.nextPageNum];

    // Fetch all customer payment methods
    [self loadAvailablePaymentConsents];
}

- (void)loadAvailablePaymentMethodTypesWithPageNum:(NSInteger)pageNum {
    AWXGetPaymentMethodTypesRequest *request = [AWXGetPaymentMethodTypesRequest new];
    request.pageNum = pageNum;
    request.transactionCurrency = self.session.currency;
    request.transactionMode = self.session.transactionMode;
    request.countryCode = self.session.countryCode;
    request.lang = self.session.lang;

    __weak __typeof(self) weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             __strong __typeof(weakSelf) strongSelf = weakSelf;

             if (response && !error) {
                 AWXGetPaymentMethodTypesResponse *result = (AWXGetPaymentMethodTypesResponse *)response;
                 strongSelf.availablePaymentMethodTypes = [self.session filteredPaymentMethodTypes:result.items];
                 strongSelf.canLoadMore = result.hasMore;
                 strongSelf.nextPageNum = pageNum + 1;
                 [strongSelf.tableView reloadData];
             }
         }];
}

- (void)loadAvailablePaymentConsents {
    NSArray *customerPaymentMethods = self.session.customerPaymentMethods;
    NSArray *customerPaymentConsents = self.session.customerPaymentConsents;

    if ([self.session isKindOfClass:[AWXOneOffSession class]] && customerPaymentConsents.count > 0 && customerPaymentMethods.count > 0) {
        NSArray *paymentConsents = [customerPaymentConsents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"nextTriggeredBy == %@ AND status == 'VERIFIED'", FormatNextTriggerByType(AirwallexNextTriggerByCustomerType)]];
        NSMutableArray *availablePaymentConsents = [@[] mutableCopy];
        NSMutableArray *cardsFingerprint = [NSMutableArray new];
        for (AWXPaymentConsent *consent in paymentConsents) {
            AWXPaymentMethod *paymentMethod = [customerPaymentMethods filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Id == %@", consent.paymentMethod.Id]].firstObject;
            if (paymentMethod != nil) {
                if (![cardsFingerprint containsObject:paymentMethod.card.fingerprint]) {
                    [cardsFingerprint addObject:paymentMethod.card.fingerprint];
                    consent.paymentMethod = paymentMethod;
                    [availablePaymentConsents addObject:consent];
                }
            }
        }
        self.availablePaymentConsents = availablePaymentConsents;
        [self.tableView reloadData];
    }
}

- (void)disablePaymentConsent:(AWXPaymentConsent *)paymentConsent index:(NSInteger)index {
    [self startAnimating];

    AWXDisablePaymentConsentRequest *request = [AWXDisablePaymentConsentRequest new];
    request.requestId = NSUUID.UUID.UUIDString;
    request.Id = paymentConsent.Id;

    __weak __typeof(self) weakSelf = self;
    AWXAPIClient *client = [[AWXAPIClient alloc] initWithConfiguration:[AWXAPIClientConfiguration sharedConfiguration]];
    [client send:request
         handler:^(AWXResponse *_Nullable response, NSError *_Nullable error) {
             __strong __typeof(weakSelf) strongSelf = weakSelf;
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

- (void)showPayment:(AWXPaymentConsent *)paymentConsent {
    AWXPaymentViewController *controller = [[AWXPaymentViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = [AWXUIContext sharedContext].delegate;
    controller.session = self.session;
    controller.paymentConsent = paymentConsent;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)close:(id)sender {
    id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    [delegate paymentViewController:self didCompleteWithStatus:AirwallexPaymentStatusCancel error:nil];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.availablePaymentMethodTypes.count;
    }
    return self.availablePaymentConsents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AWXPaymentMethodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AWXPaymentMethodCell" forIndexPath:indexPath];

    if (indexPath.section == 1) {
        AWXPaymentMethodType *paymentMethodType = self.availablePaymentMethodTypes[indexPath.row];
        [cell.logoImageView setImageURL:paymentMethodType.resources.logoURL
                            placeholder:nil];
        cell.titleLabel.text = paymentMethodType.displayName;
    } else {
        AWXPaymentConsent *paymentConsent = self.availablePaymentConsents[indexPath.row];
        cell.logoImageView.image = [UIImage imageNamed:paymentConsent.paymentMethod.card.brand inBundle:[NSBundle resourceBundle]];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ •••• %@", paymentConsent.paymentMethod.card.brand.capitalizedString, paymentConsent.paymentMethod.card.last4];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
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

    if (indexPath.section == 1) {
        AWXPaymentMethodType *paymentMethodType = self.availablePaymentMethodTypes[indexPath.row];
        Class class = ClassToHandleFlowForPaymentMethodType(paymentMethodType);

        // This should not happen since we've filtered out the types that no providers support when we get the data.
        // For now, we'll leave it here but we should be able to remove it.
        if (class == Nil) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No provider matched the payment method.", nil) preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:controller animated:YES completion:nil];
            return;
        }

        AWXDefaultProvider *provider = [[class alloc] initWithDelegate:self session:self.session paymentMethodType:paymentMethodType];
        [provider handleFlow];
        self.provider = provider;
        return;
    }

    // No cvc provided and go to enter cvc in payment detail page
    AWXPaymentConsent *paymentConsent = self.availablePaymentConsents[indexPath.row];
    if (paymentConsent.requiresCVC) {
        [self showPayment:paymentConsent];
    } else {
        AWXDefaultProvider *provider = [[AWXDefaultProvider alloc] initWithDelegate:self session:self.session];
        [provider confirmPaymentIntentWithPaymentMethod:paymentConsent.paymentMethod paymentConsent:paymentConsent device:nil];
        self.provider = provider;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!self.canLoadMore) {
        return;
    }

    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 0) {
        [self loadAvailablePaymentMethodTypesWithPageNum:self.nextPageNum];
    }
}

#pragma mark - AWXProviderDelegate

- (void)providerDidStartRequest:(AWXDefaultProvider *)provider {
    [self startAnimating];
}

- (void)providerDidEndRequest:(AWXDefaultProvider *)provider {
    [self stopAnimating];
}

- (void)provider:(AWXDefaultProvider *)provider didCompleteWithStatus:(AirwallexPaymentStatus)status error:(nullable NSError *)error {
    id<AWXPaymentResultDelegate> delegate = [AWXUIContext sharedContext].delegate;
    [delegate paymentViewController:self didCompleteWithStatus:status error:error];
}

- (void)provider:(AWXDefaultProvider *)provider didInitializePaymentIntentId:(NSString *)paymentIntentId {
    [self.session updateInitialPaymentIntentId:paymentIntentId];
}

- (void)provider:(AWXDefaultProvider *)provider shouldHandleNextAction:(AWXConfirmPaymentNextAction *)nextAction {
    Class class = ClassToHandleNextActionForType(nextAction);
    if (class == nil) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No provider matched the next action.", nil) preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
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
        [self presentViewController:controller animated:withAnimation completion:nil];
    }
}

- (void)provider:(AWXDefaultProvider *)provider shouldInsertViewController:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = CGRectInset(self.view.frame, 0, CGRectGetMaxY(self.view.bounds));
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

@end
