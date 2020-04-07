//
//  AWPaymentMethodOptions.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWCodable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWPaymentMethodOptions` includes the information of payment method options
 */
@interface AWPaymentMethodOptions : NSObject <AWJSONEncodable>

/**
 Should capture automatically when confirm. Default to false. The payment intent will be captured automatically if it is true, and authorized only if it is false.
 */
@property (nonatomic) BOOL autoCapture;

/**
 Enable three domain secure.
 */
@property (nonatomic) BOOL threeDsOption;

/**
 Three domain request.
 */
@property (nonatomic, copy, nullable) NSString *paRes;

@end

NS_ASSUME_NONNULL_END
