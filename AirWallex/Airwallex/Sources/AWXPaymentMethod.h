//
//  AWXPaymentMethod.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"
#import "AWXPlaceDetails.h"
#import "AWXCard.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXPaymentMethod` includes the information of a payment method.
 */
@interface AWXPaymentMethod : NSObject <AWXJSONEncodable, AWXJSONDecodable>

/**
 Type of the payment method. One of card, wechatpay.
 */
@property (nonatomic, copy) NSString *type;

/**
 Unique identifier for the payment method.
 */
@property (nonatomic, copy, nullable) NSString *Id;

/**
 Billing object.
 */
@property (nonatomic, strong, nullable) AWXPlaceDetails *billing;

/**
 Card object.
 */
@property (nonatomic, strong, nullable) AWXCard *card;

/**
 Additional params  for wechat or redirect type.
 */
@property (nonatomic, strong, nullable) NSDictionary *additionalParams;

/**
 The customer this payment method belongs to.
 */
@property (nonatomic, strong, nullable) NSString *customerId;

- (void)appendAdditionalParams:(NSDictionary *)params;

@end

/**
 `AWXResources` includes the resources of payment method.
 */
@interface AWXResources : NSObject <AWXJSONDecodable>

/**
 Logo url
 */
@property (nonatomic, copy) NSURL *logoURL;

/**
 has_schema
 */
@property (nonatomic) BOOL hasSchema;

@end

/**
 `AWXPaymentMethodType` includes the information of a payment method.
 */
@interface AWXPaymentMethodType : NSObject <AWXJSONDecodable>

/**
 name of the payment method.
 */
@property (nonatomic, copy) NSString *name;

/**
 display name of the payment method.
 */
@property (nonatomic, copy) NSString *displayName;

/**
 transaction_mode of the payment method. One of oneoff, recurring.
 */
@property (nonatomic, copy) NSString *transactionMode;

/**
 flows of the payment method.
 */
@property (nonatomic, copy) NSArray<NSString* > *flows;

/**
 transaction_currencies of the payment method.  "*", "AUD", "CHF", "HKD", "SGD", "JPY", "EUR", "GBP", "USD", "CAD", "NZD", "CNY"
 */
@property (nonatomic, copy) NSArray<NSString* > *transactionCurrencies;

/**
 Whether payment method is active.
 */
@property (nonatomic) BOOL active;

/**
 Resources
 */
@property (nonatomic, strong) AWXResources *resources;

/**
 Whether it has schema
 */
@property (nonatomic, readonly) BOOL hasSchema;

@end

/**
 `AWXSchema` includes the schema of payment method.
 */
@interface AWXSchema : NSObject <AWXJSONDecodable>

@end

NS_ASSUME_NONNULL_END
