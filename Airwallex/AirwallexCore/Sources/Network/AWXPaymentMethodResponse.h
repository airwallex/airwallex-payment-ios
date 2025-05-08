//
//  AWXPaymentMethodResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXPage.h"

@class AWXPaymentMethod, AWXPaymentConsent, AWXPaymentMethodType, AWXSchema, AWXBank;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXGetPaymentMethodsResponse` includes the list of payment methods.
 */
@interface AWXGetPaymentMethodsResponse : AWXResponse

/**
 Check whether there are more payment methods not loaded.
 */
@property (nonatomic, readonly) BOOL hasMore;

/**
 Payment methods.
 */
@property (nonatomic, readonly) NSArray<AWXPaymentMethod *> *items;

@end

/**
 `AWXGetPaymentMethodTypesResponse` includes the list of payment methods.
 */
@interface AWXGetPaymentMethodTypesResponse : AWXResponse<AWXPage>

/**
 Payment methods.
 */
@property (nonatomic, readonly) NSArray<AWXPaymentMethodType *> *items;

@end

/**
 `AWXGetPaymentMethodTypeResponse` includes the list of payment methods.
 */
@interface AWXGetPaymentMethodTypeResponse : AWXResponse

/**
 name of the payment method.
 */
@property (nonatomic, copy) NSString *name;

/**
 display name of the payment method.
 */
@property (nonatomic, copy) NSString *displayName;

/**
 Logo url
 */
@property (nonatomic, copy, nullable) NSURL *logoURL;

/**
 has_schema
 */
@property (nonatomic, assign) BOOL hasSchema;

/**
 Field schemas
 */
@property (nonatomic, strong) NSArray<AWXSchema *> *schemas;

@end

/**
 `AWXGetAvailableBanksResponse` includes the list of banks.
 */
@interface AWXGetAvailableBanksResponse : AWXResponse

/**
 Check whether there are more payment methods not loaded.
 */
@property (nonatomic, readonly) BOOL hasMore;

/**
 Payment methods.
 */
@property (nonatomic, readonly) NSArray<AWXBank *> *items;

@end

/**
 `AWXCreatePaymentMethodResponse` includes the payment method created.
 */
@interface AWXCreatePaymentMethodResponse : AWXResponse

/**
 Payment method object.
 */
@property (nonatomic, readonly) AWXPaymentMethod *paymentMethod;

@end

/**
 `AWXDisablePaymentMethodResponse` includes the payment method disabled.
 */
@interface AWXDisablePaymentConsentResponse : AWXResponse

/**
 Payment method object.
 */
@property (nonatomic, readonly) AWXPaymentConsent *paymentConsent;

@end

NS_ASSUME_NONNULL_END
