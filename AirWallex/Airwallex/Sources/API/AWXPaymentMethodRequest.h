//
//  AWXPaymentMethodRequest.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXRequestProtocol.h"
#import "AWXPaymentMethod.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXGetPaymentMethodsRequest` includes all of the parameters needed to get payment methods.
 */
@interface AWXGetPaymentMethodsRequest : NSObject <AWXRequestProtocol>

/**
 Customer ID.
 */
@property (nonatomic, copy, nullable) NSString *customerId;

/**
 Page number starting from 0.
 */
@property (nonatomic) NSInteger pageNum;

/**
 Number of payment methods to be listed per page.
 */
@property (nonatomic) NSInteger pageSize;

/**
 Payment method type.
 */
@property (nonatomic, copy, nullable) NSString *methodType;

/**
 Card type.
 */
@property (nonatomic, copy, nullable) NSString *cardType;

/**
 The start time of created_at in ISO8601 format.
 */
@property (nonatomic, copy, nullable) NSString *fromCreatedAt;

/**
 The end time of created_at in ISO8601 format
 */
@property (nonatomic, copy, nullable) NSString *toCreatedAt;

@end

/**
 `AWXGetPaymentMethodsTypeRequest` includes all of the parameters needed to get payment methods.
 */
@interface AWXGetPaymentMethodsTypeRequest : NSObject <AWXRequestProtocol>

/**
 active .
 */
@property (nonatomic) BOOL active;
/**
 Page number starting from 0.
 */
@property (nonatomic) NSInteger pageNum;

/**
 Number of payment methods to be listed per page.
 */
@property (nonatomic) NSInteger pageSize;

/**
 A currency code.
 */
@property (nonatomic, copy, nullable) NSString *transactionCurrency;


@end

/**
 `AWXCreatePaymentMethodRequest` includes all of the parameters needed to create a payment method.
 */
@interface AWXCreatePaymentMethodRequest : NSObject <AWXRequestProtocol>

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;

/**
 Payment method object.
 */
@property (nonatomic, strong) AWXPaymentMethod *paymentMethod;

@end

/**
 `AWXDisablePaymentMethodRequest` disable a payment method.
 */
@interface AWXDisablePaymentMethodRequest : NSObject <AWXRequestProtocol>

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;

/**
 Payment method id.
 */
@property (nonatomic, strong) NSString *paymentMethodId;

@end

NS_ASSUME_NONNULL_END
