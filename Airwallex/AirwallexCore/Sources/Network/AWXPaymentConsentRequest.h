//
//  AWXPaymentConsentRequest.h
//  Airwallex
//
//  Created by Victor Zhu on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
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
@interface AWXCreatePaymentConsentRequest : AWXRequest

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
@property (nonatomic, assign) AirwallexNextTriggerByType nextTriggerByType;

/**
 Whether it requires CVC.
 */
@property (nonatomic, assign) BOOL requiresCVC;

/**
 Merchant trigger reason
 */
@property (nonatomic, assign) AirwallexMerchantTriggerReason merchantTriggerReason;

@end

/**
 `AWXVerifyPaymentConsentRequest` includes the request of verifying payment consent.
 */
@interface AWXVerifyPaymentConsentRequest : AWXRequest

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
/**
 Device object.
 */
@property (nonatomic, strong, nullable) AWXDevice *device;

@end

/**
 `AWXRetrievePaymentConsentRequest` includes the request of payment consent.
 */
@interface AWXRetrievePaymentConsentRequest : AWXRequest

/**
 Consent ID.
 */
@property (nonatomic, copy) NSString *consentId;

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;

@end

/**
 `AWXGetPaymentConsentsRequest` includes the request of payment consents.
 */
@interface AWXGetPaymentConsentsRequest : AWXRequest

/**
 Customer ID.
 */
@property (nonatomic, copy) NSString *customerId;

/**
 Consent status.
 */
@property (nonatomic, copy, nullable) NSString *status;

/**
 Next trigger By type.
 */
@property (nonatomic, copy, nullable) NSString *nextTriggeredBy;

/**
 Merchant trigger reason
 */
@property (nonatomic) AirwallexMerchantTriggerReason merchantTriggerReason;

/**
 Page number starting from 0.
 */
@property (nonatomic) NSInteger pageNum;

/**
 Number of payment methods to be listed per page.
 */
@property (nonatomic) NSInteger pageSize;

@end

NS_ASSUME_NONNULL_END
