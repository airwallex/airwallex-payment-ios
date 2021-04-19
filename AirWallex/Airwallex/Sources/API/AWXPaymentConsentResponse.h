//
//  AWXPaymentConsentResponse.h
//  Airwallex
//
//  Created by 秋风木叶下 on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXResponseProtocol.h"
@class  AWXPaymentConsent;

NS_ASSUME_NONNULL_BEGIN

@interface AWXPaymentConsentResponse : NSObject <AWXResponseProtocol>

/**
 Payment consent object.
 */
@property (nonatomic, readonly) AWXPaymentConsent *consent;

@end


NS_ASSUME_NONNULL_END
