//
//  AWPaymentMethodRequest.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWRequestProtocol.h"
#import "AWPaymentMethod.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWGetPaymentMethodsRequest` includes all of the parameters needed to get payment methods.
 */
@interface AWGetPaymentMethodsRequest : NSObject <AWRequestProtocol>

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
 The start time of created_at in ISO8601 format.
 */
@property (nonatomic, copy, nullable) NSString *fromCreatedAt;

/**
 The end time of created_at in ISO8601 format
 */
@property (nonatomic, copy, nullable) NSString *toCreatedAt;

@end

/**
 `AWCreatePaymentMethodRequest` includes all of the parameters needed to create a payment method.
 */
@interface AWCreatePaymentMethodRequest : NSObject <AWRequestProtocol>

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;

/**
 Payment method object.
 */
@property (nonatomic, strong) AWPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
