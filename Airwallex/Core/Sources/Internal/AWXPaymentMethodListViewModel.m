//
//  AWXPaymentMethodListViewModel.m
//  Core
//
//  Created by Hector.Huang on 2023/12/12.
//  Copyright © 2023 Airwallex. All rights reserved.
//

#import "AWXPaymentMethodListViewModel.h"
#import "AWXPaymentConsentRequest.h"
#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentMethodRequest.h"
#import "AWXPaymentMethodResponse.h"
#ifdef AirwallexSDK
#import "Core/Core-Swift.h"
#else
#import "Airwallex/Airwallex-Swift.h"
#endif

@interface AWXPaymentMethodListViewModel ()

typedef void (^PageResultPaymentTypes)(id __autoreleasing *page, NSError *__autoreleasing *error);
typedef void (^ItemsResultPaymentTypes)(NSArray *__autoreleasing *items, NSError *__autoreleasing *error);

typedef void (^PageResultPaymentConsents)(id __autoreleasing *page, NSError *__autoreleasing *error);
typedef void (^ItemsResultPaymentConsents)(NSArray *__autoreleasing *items, NSError *__autoreleasing *error);

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
    [self retrieveAvailablePaymentMethodsWithCompletion:^(ItemsResultPaymentTypes result) {
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
                                                  completion:^(ItemsResultPaymentConsents result) {
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

- (void)retrieveAvailablePaymentMethodsWithCompletion:(void (^)(ItemsResultPaymentTypes))completion {
    __weak __typeof(self) weakSelf = self;
    [self
        LoadPagedPaymentMethodTypesWithLoadPageBlock:^(NSInteger pageNum, void (^pageCompletion)(PageResultPaymentTypes)) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;

            AWXGetPaymentMethodTypesConfiguration *config = [AWXGetPaymentMethodTypesConfiguration new];
            config.transactionCurrency = strongSelf.session.currency;
            config.transactionMode = strongSelf.session.transactionMode;
            config.countryCode = strongSelf.session.countryCode;
            config.lang = strongSelf.session.lang;
            config.pageNum = pageNum;
            config.pageSize = 20;
            [AWXAPIClientSwift getAvailablePaymentMethodsWithConfiguration:config
                                                                completion:^(AWXGetPaymentMethodTypesResponse *_Nullable response, NSError *_Nullable responseError) {
                                                                    AWXGetPaymentMethodTypesResponse *result = (AWXGetPaymentMethodTypesResponse *)response;
                                                                    pageCompletion(^(id __autoreleasing *page, NSError *__autoreleasing *error) {
                                                                        *page = result;
                                                                        *error = responseError;
                                                                    });
                                                                }];
        }
        items:[NSMutableArray new]
        pageNum:0
        completion:^(ItemsResultPaymentTypes result) {
            completion(result);
        }];
}

- (void)retrieveAvailablePaymentConsentsWithCustomerId:(nonnull NSString *)customerId
                                            completion:(void (^)(ItemsResultPaymentConsents))completion {
    __weak __typeof(self) weakSelf = self;
    [self
        LoadPagedPaymentConsentsWithLoadPageBlock:^(NSInteger pageNum, void (^pageCompletion)(PageResultPaymentConsents)) {
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
                                pageCompletion(^(id __autoreleasing *page, NSError *__autoreleasing *error) {
                                    *page = result;
                                    *error = responseError;
                                });
                            }];
        }
        items:[NSMutableArray new]
        pageNum:0
        completion:^(ItemsResultPaymentConsents result) {
            completion(result);
        }];
}

- (void)LoadPagedPaymentMethodTypesWithLoadPageBlock:(void (^)(NSInteger pageNum, void (^)(PageResultPaymentTypes)))loadPageBlock
                                               items:(NSMutableArray *)items
                                             pageNum:(NSInteger)pageNum
                                          completion:(void (^)(ItemsResultPaymentTypes))completion {
    loadPageBlock(pageNum, ^void(PageResultPaymentTypes result) {
        AWXGetPaymentMethodTypesResponse *response;
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
            //            [self LoadPagedPaymentMethodTypesWithLoadPageBlock:loadPageBlock items:items pageNum:pageNum + 1 completion:completion];
        } else {
            completion(^(NSArray *__autoreleasing *newItems, NSError *__autoreleasing *error) {
                *newItems = items;
            });
        }
    });
}

- (void)LoadPagedPaymentConsentsWithLoadPageBlock:(void (^)(NSInteger pageNum, void (^)(PageResultPaymentConsents)))loadPageBlock
                                            items:(NSMutableArray *)items
                                          pageNum:(NSInteger)pageNum
                                       completion:(void (^)(ItemsResultPaymentConsents))completion {
    loadPageBlock(pageNum, ^void(PageResultPaymentConsents result) {
        AWXGetPaymentConsentsResponse *response;
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
            [self LoadPagedPaymentMethodTypesWithLoadPageBlock:loadPageBlock items:items pageNum:pageNum + 1 completion:completion];
        } else {
            completion(^(NSArray *__autoreleasing *newItems, NSError *__autoreleasing *error) {
                *newItems = items;
            });
        }
    });
}

@end
