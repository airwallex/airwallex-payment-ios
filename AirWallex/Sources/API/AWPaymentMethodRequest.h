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

@interface AWGetPaymentMethodsRequest : NSObject <AWRequestProtocol>

@property (nonatomic, copy, nullable) NSString *customerId;

@end

@interface AWCreatePaymentMethodRequest : NSObject <AWRequestProtocol>

@property (nonatomic, copy) NSString *requestId;
@property (nonatomic, copy, nullable) NSString *customerId;
@property (nonatomic, strong) AWPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
