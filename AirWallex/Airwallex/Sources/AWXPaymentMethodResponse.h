//
//  AWXPaymentMethodResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXResponseProtocol.h"

@class AWXPaymentMethod, AWXPaymentConsent, AWXPaymentMethodType, AWXSchema, AWXBank;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXGetPaymentMethodsResponse` includes the list of payment methods.
 */
@interface AWXGetPaymentMethodsResponse : NSObject <AWXResponseProtocol>

/**
 Check whether there are more payment methods not loaded.
 */
@property (nonatomic, readonly) BOOL hasMore;

/**
 Payment methods.
 */
@property (nonatomic, readonly) NSArray <AWXPaymentMethod *> *items;

@end

/**
 `AWXGetPaymentMethodTypesResponse` includes the list of payment methods.
 */
@interface AWXGetPaymentMethodTypesResponse : NSObject <AWXResponseProtocol>

/**
 Check whether there are more payment methods not loaded.
 */
@property (nonatomic, readonly) BOOL hasMore;

/**
 Payment methods.
 */
@property (nonatomic, readonly) NSArray <AWXPaymentMethodType *> *items;

@end

/**
 `AWXGetPaymentMethodTypeResponse` includes the list of payment methods.
 */
@interface AWXGetPaymentMethodTypeResponse : NSObject <AWXResponseProtocol>

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
@property (nonatomic, copy) NSURL *logoURL;

/**
 has_schema
 */
@property (nonatomic) BOOL hasSchema;

/**
 Field schemas
 */
@property (nonatomic, strong) NSArray<AWXSchema *> *schemas;

@end

/**
 `AWXGetAvailableBanksResponse` includes the list of banks.
 */
@interface AWXGetAvailableBanksResponse : NSObject <AWXResponseProtocol>

/**
 Check whether there are more payment methods not loaded.
 */
@property (nonatomic, readonly) BOOL hasMore;

/**
 Payment methods.
 */
@property (nonatomic, readonly) NSArray <AWXBank *> *items;

@end

/**
 `AWXCreatePaymentMethodResponse` includes the payment method created.
 */
@interface AWXCreatePaymentMethodResponse : NSObject <AWXResponseProtocol>

/**
 Payment method object.
 */
@property (nonatomic, readonly) AWXPaymentMethod *paymentMethod;

@end

/**
 `AWXDisablePaymentMethodResponse` includes the payment method disabled.
 */
@interface AWXDisablePaymentConsentResponse : NSObject <AWXResponseProtocol>

/**
 Payment method object.
 */
@property (nonatomic, readonly) AWXPaymentConsent *paymentConsent;

@end

NS_ASSUME_NONNULL_END
