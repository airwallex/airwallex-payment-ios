//
//  AWXPaymentMethodListViewModel.m
//  Core
//
//  Created by Hector.Huang on 2023/12/12.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodListViewModel.h"
#import "AWXPage.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"

@interface AWXPaymentMethodListViewModel ()

typedef void (^PageResult)(id<AWXPage> __autoreleasing *page, NSError *__autoreleasing *error);
typedef void (^ItemsResult)(NSArray *__autoreleasing *items, NSError *__autoreleasing *error);

@property (nonatomic, strong, nonnull) AWXSession *session;
@property (nonatomic, strong, nonnull) AWXAPIClient *client;

@end

@implementation AWXPaymentMethodListViewModel

- (instancetype)initWithSession:(AWXSession *)session APIClient:(AWXAPIClient *)client {
    self = [super init];
    if (self) {
        _session = session;
        _client = client;
    }
    return self;
}

- (void)fetchAvailablePaymentMethodsAndConsentsWithCompletionHandler:(nonnull PaymentMethodsAndConsentsCompletionHandler)completionHandler {
    dispatch_group_t group = dispatch_group_create();
    __block NSArray<AWXPaymentMethodType *> *paymentMethods;
    __block NSArray<AWXPaymentConsent *> *paymentConsents;

    dispatch_group_enter(group);
    [self retrieveAvailablePaymentMethodsWithCompletion:^(ItemsResult result) {
        NSError *responseError;
        result(&paymentMethods, &responseError);

        if (responseError) {
            completionHandler(@[], @[], responseError);
            return;
        }
        dispatch_group_leave(group);
    }];

    AWXOneOffSession *oneOffSession = (AWXOneOffSession *)_session;
    if (_session.customerId && [_session isKindOfClass:AWXOneOffSession.class] && oneOffSession && !oneOffSession.hidePaymentConsents) {
        dispatch_group_enter(group);
        [self retrieveAvailablePaymentConsentsWithCustomerId:_session.customerId
                                                  completion:^(ItemsResult result) {
                                                      NSError *responseError;
                                                      result(&paymentConsents, &responseError);

                                                      if (responseError) {
                                                          completionHandler(@[], @[], responseError);
                                                          return;
                                                      }
                                                      dispatch_group_leave(group);
                                                  }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completionHandler(paymentMethods, [self filteredPaymentConsentsWithConsents:paymentConsents methods:paymentMethods], nil);
    });
}

- (NSArray<AWXPaymentConsent *> *)filteredPaymentConsentsWithConsents:(NSArray<AWXPaymentConsent *> *)consents
                                                              methods:(NSArray<AWXPaymentMethodType *> *)methods {
    AWXPaymentMethodType *cardPaymentMethod = [methods filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", AWXCardKey]].firstObject;
    if (cardPaymentMethod && [_session isKindOfClass:[AWXOneOffSession class]]) {
        return [consents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"paymentMethod.type == %@", AWXCardKey]];
    }
    return @[];
}

- (void)retrieveAvailablePaymentMethodsWithCompletion:(void (^)(ItemsResult))completion {
    __weak __typeof(self) weakSelf = self;
    [self
        LoadPagedItemsWithLoadPageBlock:^(NSInteger pageNum, void (^pageCompletion)(PageResult)) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;

            AWXGetPaymentMethodTypesRequest *request = [AWXGetPaymentMethodTypesRequest new];
            request.transactionCurrency = strongSelf.session.currency;
            request.transactionMode = strongSelf.session.transactionMode;
            request.countryCode = strongSelf.session.countryCode;
            request.lang = strongSelf.session.lang;
            request.pageNum = pageNum;
            request.pageSize = 20;
            [strongSelf.client send:request
                            handler:^(AWXResponse *_Nullable response, NSError *_Nullable responseError) {
                                AWXGetPaymentMethodTypesResponse *result = (AWXGetPaymentMethodTypesResponse *)response;
                                pageCompletion(^(id<AWXPage> __autoreleasing *page, NSError *__autoreleasing *error) {
                                    *page = result;
                                    *error = responseError;
                                });
                            }];
        }
        items:[NSMutableArray new]
        pageNum:0
        completion:^(ItemsResult result) {
            completion(result);
        }];
}

- (void)retrieveAvailablePaymentConsentsWithCustomerId:(nonnull NSString *)customerId
                                            completion:(void (^)(ItemsResult))completion {
    __weak __typeof(self) weakSelf = self;
    [self
        LoadPagedItemsWithLoadPageBlock:^(NSInteger pageNum, void (^pageCompletion)(PageResult)) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;

            AWXGetPaymentConsentsRequest *request = [AWXGetPaymentConsentsRequest new];
            request.customerId = customerId;
            request.status = @"VERIFIED";
            request.nextTriggeredBy = FormatNextTriggerByType(AirwallexNextTriggerByCustomerType);
            request.pageNum = pageNum;
            request.pageSize = 20;
            [strongSelf.client send:request
                            handler:^(AWXResponse *_Nullable response, NSError *_Nullable responseError) {
                                AWXGetPaymentConsentsResponse *result = (AWXGetPaymentConsentsResponse *)response;
                                pageCompletion(^(id<AWXPage> __autoreleasing *page, NSError *__autoreleasing *error) {
                                    *page = result;
                                    *error = responseError;
                                });
                            }];
        }
        items:[NSMutableArray new]
        pageNum:0
        completion:^(ItemsResult result) {
            completion(result);
        }];
}

- (void)LoadPagedItemsWithLoadPageBlock:(void (^)(NSInteger pageNum, void (^)(PageResult)))loadPageBlock
                                  items:(NSMutableArray *)items
                                pageNum:(NSInteger)pageNum
                             completion:(void (^)(ItemsResult))completion {
    loadPageBlock(pageNum, ^void(PageResult result) {
        id<AWXPage> response;
        NSError *responseError;
        result(&response, &responseError);

        [items addObjectsFromArray:response.items];

        if (responseError) {
            completion(^(NSArray *__autoreleasing *items, NSError *__autoreleasing *error) {
                *error = responseError;
            });
            return;
        }

        if (response.hasMore) {
            [self LoadPagedItemsWithLoadPageBlock:loadPageBlock items:items pageNum:pageNum + 1 completion:completion];
        } else {
            completion(^(NSArray *__autoreleasing *newItems, NSError *__autoreleasing *error) {
                *newItems = items;
            });
        }
    });
}

@end
