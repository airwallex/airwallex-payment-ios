//
//  AWXPaymentMethod.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXCodable.h"
#import <Foundation/Foundation.h>

@class AWXResources;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXCandidate` includes the values of list
 */
@interface AWXCandidate : NSObject<AWXJSONDecodable>

/**
 display name.
 */
@property (nonatomic, copy) NSString *displayName;

/**
 value.
 */
@property (nonatomic, copy) NSString *value;

@end

/**
 `AWXField` includes the field of schema.
 */
@interface AWXField : NSObject<AWXJSONDecodable>

/**
 name of the payment method.
 */
@property (nonatomic, copy) NSString *name;

/**
 display name of the payment method.
 */
@property (nonatomic, copy) NSString *displayName;

/**
 ui type.
 */
@property (nonatomic, copy) NSString *uiType;

/**
 type of field.
 */
@property (nonatomic, copy) NSString *type;

/**
 hidden.
 */
@property (nonatomic) BOOL hidden;

/**
 candidates.
 */
@property (nonatomic, strong) NSArray<AWXCandidate *> *candidates;

@end

/**
 `AWXSchema` includes the schema of payment method.
 */
@interface AWXSchema : NSObject<AWXJSONDecodable>

/**
 transaction_mode of the payment method. One of oneoff, recurring.
 */
@property (nonatomic, copy) NSString *transactionMode;

/**
 Flow.
 */
@property (nonatomic, copy, nullable) NSString *flow;

/**
 Fields.
 */
@property (nonatomic, copy) NSArray<AWXField *> *fields;

@end

/**
 `AWXBank` includes the bank info.
 */
@interface AWXBank : NSObject<AWXJSONDecodable>

/**
 name of the payment method.
 */
@property (nonatomic, copy) NSString *name;

/**
 display name of the payment method.
 */
@property (nonatomic, copy) NSString *displayName;

/**
 Resources
 */
@property (nonatomic, strong) AWXResources *resources;

@end

NS_ASSUME_NONNULL_END
