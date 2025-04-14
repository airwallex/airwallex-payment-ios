//
//  AWXPaymentintentResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXAPIClient.h"
#import "AWXCodable.h"

NS_ASSUME_NONNULL_BEGIN

@class AWXConfirmPaymentNextAction, AWXPaymentAttempt, AWXPaymentMethod;

/**
 `AWXConfirmPaymentIntentResponse` includes the result of payment flow.
 */
@interface AWXConfirmPaymentIntentResponse : AWXResponse

/**
 Currency.
 */
@property (nonatomic, readonly) NSString *currency;

/**
 Payment amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *amount;

/**
 Payment status.
 */
@property (nonatomic, readonly) NSString *status;

/**
 Next action.
 */
@property (nonatomic, readonly, nullable) AWXConfirmPaymentNextAction *nextAction;

/**
 The latest payment attempt object.
 */
@property (nonatomic, readonly, nullable) AWXPaymentAttempt *latestPaymentAttempt;

@end

@class AWXWeChatPaySDKResponse, AWXRedirectResponse, AWXDccResponse;

/**
 `AWXConfirmPaymentNextAction` includes the parameters for next action.
 */
@interface AWXConfirmPaymentNextAction : NSObject<AWXJSONDecodable>

/**
 Next action type.
 */
@property (nonatomic, readonly) NSString *type;

/**
 URL.
 */
@property (nonatomic, readonly, nullable) NSString *url;

/**
 Fallback Url
 */
@property (nonatomic, readonly, nullable) NSString *fallbackUrl;

/**
 Method.
 */
@property (nonatomic, readonly, nullable) NSString *method;

/**
 Stage.
 */
@property (nonatomic, readonly, nullable) NSString *stage;

/**
 Payload of next action.
 */
@property (nonatomic, readonly, nullable) NSDictionary *payload;

@end

/**
 `AWXAuthenticationData` includes the parameters for 3ds authentication.
 */
@interface AWXAuthenticationData : NSObject<AWXJSONDecodable>

@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) NSString *score;
@property (nonatomic, readonly) NSString *version;

/**
 Check whether 3ds version is v2.x.
 */
- (BOOL)isThreeDSVersion2;

@end

/**
 `AWXPaymentAttempt` includes the information of payment attempt.
 */
@interface AWXPaymentAttempt : NSObject<AWXJSONDecodable>

/**
 Attempt id.
 */
@property (nonatomic, readonly) NSString *Id;

/**
 Payment amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *amount;

/**
 Payment method.
 */
@property (nonatomic, readonly) AWXPaymentMethod *paymentMethod;

/**
 The status of payment attempt
 */
@property (nonatomic, readonly) NSString *status;

/**
 Captured amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *capturedAmount;

/**
 Refunded amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *refundedAmount;

/**
 3DS authentication data.
 */
@property (nonatomic, readonly) AWXAuthenticationData *authenticationData;

@end

/**
 `AWXGetPaymentIntentResponse` includes the information of payment intent.
 */
@interface AWXGetPaymentIntentResponse : AWXResponse

/**
 Intent id.
 */
@property (nonatomic, readonly) NSString *Id;

/**
 Request id.
 */
@property (nonatomic, readonly) NSString *requestId;

/**
 Payment amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *amount;

/**
 Currency.
 */
@property (nonatomic, readonly) NSString *currency;

/**
 Merchant order id.
 */
@property (nonatomic, readonly) NSString *merchantOrderId;

/**
 Order data.
 */
@property (nonatomic, readonly) NSDictionary *order;

/**
 Customer id.
 */
@property (nonatomic, readonly) NSString *customerId;

/**
 Payment status.
 */
@property (nonatomic, readonly) NSString *status;

/**
 Captured amount.
 */
@property (nonatomic, readonly) NSDecimalNumber *capturedAmount;

/**
 Created date.
 */
@property (nonatomic, readonly) NSString *createdAt;

/**
 Updated date.
 */
@property (nonatomic, readonly) NSString *updatedAt;

/**
 Available payment method types.
 */
@property (nonatomic, readonly) NSArray<NSString *> *availablePaymentMethodTypes;

/**
 Client secret.
 */
@property (nonatomic, readonly) NSString *clientSecret;

@end

/**
 `AWXGetPaResResponse` includes the 3ds information of payment.
 */
@interface AWXGetPaResResponse : AWXResponse

/**
 PaRes
 */
@property (nonatomic, readonly) NSString *paRes;

@end

NS_ASSUME_NONNULL_END
