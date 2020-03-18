//
//  AWPaymentMethodResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/2/4.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWResponseProtocol.h"

@class AWPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

@interface AWGetPaymentMethodsResponse : NSObject <AWResponseProtocol>

@property (nonatomic, readonly) NSString *hasMore;
@property (nonatomic, readonly) NSArray *items;

@end

@interface AWCreatePaymentMethodResponse : NSObject <AWResponseProtocol>

@property (nonatomic, readonly) AWPaymentMethod *paymentMethod;

@end

NS_ASSUME_NONNULL_END
