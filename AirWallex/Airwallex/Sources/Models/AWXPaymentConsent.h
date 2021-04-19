//
//  AWXPaymentConsent.h
//  Airwallex
//
//  Created by 秋风木叶下 on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWXPaymentConsent : NSObject <AWXJSONDecodable>

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *next_triggered_by;
@property (nonatomic, copy) NSString *merchant_trigger_reason;
@property (nonatomic, assign) BOOL requires_cvc;

@end

NS_ASSUME_NONNULL_END


