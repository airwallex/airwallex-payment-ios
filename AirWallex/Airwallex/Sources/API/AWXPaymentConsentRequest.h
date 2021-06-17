//
//  AWXPaymentConsentRequest.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXRequestProtocol.h"

@class AWXPaymentMethod;
@class AWXPaymentMethodOptions;
@class AWXDevice;
@class AWXPaymentConsentVerifyOptions;
@class AWXPaymentConsent;

NS_ASSUME_NONNULL_BEGIN


@interface AWXCreatePaymentConsentRequest : NSObject <AWXRequestProtocol>

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;
/**
 Customer ID.
 */
@property (nonatomic, copy, nullable) NSString *customerId;
/**
 A currency code.
 */
@property (nonatomic, strong, nullable) NSString *currency;
/**
 Payment method object.
 */
@property (nonatomic, strong) AWXPaymentMethod *paymentMethod;

@end

@interface AWXVerifyPaymentConsentRequest : NSObject <AWXRequestProtocol>

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;

/**
 Return url.
 */
@property (nonatomic, copy) NSString *returnURL;
/**
 Payment method object.
 */
@property (nonatomic, strong, nullable) AWXPaymentMethod *options;
/**
 Payment consent object.
 */
@property (nonatomic, strong, nullable) AWXPaymentConsent *consent;

@end

@interface AWXRetrievePaymentConsentRequest : NSObject <AWXRequestProtocol>

/**
 Consent ID.
 */
@property (nonatomic, copy) NSString *consentId;
/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;


@end


NS_ASSUME_NONNULL_END
