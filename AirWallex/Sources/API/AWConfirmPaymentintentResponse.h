//
//  AWConfirmPaymentintentResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWConfirmPaymentintentResponse : NSObject <AWResponseProtocol>

@property (nonatomic, readonly) NSString *status;

@end

NS_ASSUME_NONNULL_END
