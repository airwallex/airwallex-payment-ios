//
//  AWPaymentMethodOptions.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWJSONifiable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `AWPaymentMethodOptions` includes the information of payment method options
 */
@interface AWPaymentMethodOptions : NSObject <AWJSONifiable>

/**
 Whether to auto capture.
 */
@property (nonatomic) BOOL autoCapture;

/**
 Whether use 3ds.
 */
@property (nonatomic) BOOL threeDsOption;

@end

NS_ASSUME_NONNULL_END
