//
//  AWXPaymentConsentRequest.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWXRequestProtocol.h"
#import "AWXConstants.h"

@class AWXPaymentMethod;
@class AWXPaymentMethodOptions;
@class AWXDevice;
@class AWXPaymentConsentVerifyOptions;
@class AWXPaymentConsent;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXCreatePaymentConsentRequest` includes the request of creating payment consent.
 */
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

/**
 Next trigger By type.
 */
@property (nonatomic) AirwallexNextTriggerByType nextTriggerByType;

/**
 Whether it requires CVC.
 */
@property (nonatomic) BOOL requiresCVC;

/**
 Merchant trigger reason
 */
@property (nonatomic) AirwallexMerchantTriggerReason merchantTriggerReason;

@end

/**
 `AWXVerifyPaymentConsentRequest` includes the request of verifying payment consent.
 */
@interface AWXVerifyPaymentConsentRequest : NSObject <AWXRequestProtocol>

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;

/**
 A currency code.
 */
@property (nonatomic, strong, nullable) NSString *currency;

/**
 Amount.
 */
@property (nonatomic, strong) NSDecimalNumber *amount;

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

/**
 `AWXRetrievePaymentConsentRequest` includes the request of payment consent.
 */
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
