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
 Customer ID
 */
@property (nonatomic, copy, nullable) NSString *customerId;

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
 Customer ID.
 */
@property (nonatomic, copy, nullable) NSString *customerId;

/**
 Payment method object.
 */
@property (nonatomic, strong) AWPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
