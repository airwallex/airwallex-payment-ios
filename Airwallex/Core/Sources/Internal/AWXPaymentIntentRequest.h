//
//  AWXPaymentIntentRequest.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"

@class AWXPaymentMethod;
@class AWXPaymentMethodOptions;
@class AWXDevice;
@class AWXPaymentConsent;

NS_ASSUME_NONNULL_BEGIN

/**
 `AWXConfirmThreeDSRequest` includes all of the parameters needed to confirm 3ds.
 */
@interface AWXConfirmThreeDSRequest : AWXRequest

/**
 Intent ID.
 */
@property (nonatomic, copy) NSString *intentId;

/**
 Request ID.
 */
@property (nonatomic, copy) NSString *requestId;

/**
 Confirm type.
 */
@property (nonatomic, copy) NSString *type;

/**
 Device data collection response.
 */
@property (nonatomic, copy, nullable) NSString *deviceDataCollectionRes;

/**
 3DS transaction ID.
 */
@property (nonatomic, copy, nullable) NSString *dsTransactionId;

/**
 3DS acs response.
 */
@property (nonatomic, copy, nullable) NSString *acsResponse;

/**
 Return url.
 */
@property (nonatomic, copy, nullable) NSString *returnURL;

/**
 Use dcc.
 */
@property (nonatomic) BOOL useDCC;

/**
 Device object.
 */
@property (nonatomic, strong, nullable) AWXDevice *device;

@end

/**
 `AWXRetrievePaymentIntentRequest` includes all of the parameters needed to get payment intent.
 */
@interface AWXRetrievePaymentIntentRequest : AWXRequest

/**
 Intent ID.
 */
@property (nonatomic, copy) NSString *intentId;

@end

/**
 `AWXRetrievePaymentIntentRequest` includes all of the parameters needed to get payment intent.
 */
@interface AWXGetPaResRequest : AWXRequest

/**
 PaRes ID.
 */
@property (nonatomic, copy) NSString *paResId;

@end

NS_ASSUME_NONNULL_END
