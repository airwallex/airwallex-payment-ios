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

@interface AWPaymentMethodOptions : NSObject <AWJSONifiable>

@property (nonatomic) BOOL autoCapture;
@property (nonatomic) BOOL threeDsOption;

@end

NS_ASSUME_NONNULL_END
